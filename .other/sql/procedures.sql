DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `041_checkAvailableRooms`(IN `var_date_in` DATE, IN `var_date_out` DATE)
BEGIN
    SELECT * 
        FROM 041_rooms 
        WHERE room_id NOT IN (
            SELECT reservation_room 
            FROM 041_reservations
            WHERE 
                var_date_in < reservation_date_out AND var_date_out > reservation_date_in
                AND reservation_status <> 'cancelled'
        )         
        AND room_status <>'unavailable'
        ORDER BY rand();
END$$
DELIMITER ;


DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `041_checkOut`(IN `var_reservation_id` INT)
BEGIN
    DECLARE var_client INT;
    DECLARE var_room INT;
    DECLARE var_date_in DATE;
    DECLARE var_date_out DATE;
    DECLARE var_total_days INT; -- calc
    DECLARE var_room_price decimal(10,2);
    DECLARE var_room_total decimal(10,2); -- calc
    DECLARE var_room_extras json;
    DECLARE var_room_extras_total decimal(10,2); -- calc
    DECLARE var_services json;
    DECLARE var_services_total decimal(10,2); -- calc
    DECLARE var_reservation_status VARCHAR(255);
    DECLARE var_subtotal decimal(10,2); -- calc

    DECLARE var_days_before_reservation INT; -- calc

    SELECT reservation_client, reservation_room, reservation_date_in, reservation_date_out, reservation_room_price, reservation_room_extras, reservation_services, reservation_status
    INTO var_client, var_room, var_date_in, var_date_out, var_room_price, var_room_extras, var_services, var_reservation_status
    FROM 041_reservations
    WHERE reservation_id = var_reservation_id;

    IF var_reservation_status IN ("check-out","cancelled") THEN
        SET var_total_days = DATEDIFF(var_date_out, var_date_in);
        SET var_room_extras_total = getRoomExtrasTotal(var_room_extras);
        SET var_services_total = getServicesTotal(var_services);
        SET var_room_total = (var_total_days * var_room_price);

        IF(var_reservation_status = "cancelled") THEN
            SET var_days_before_reservation = DATEDIFF(var_date_in, CURRENT_DATE());
            -- al cancelar le quitamos los extras de la habitacion
            -- los servicios al no haber estado en el hotel seran 0
            SET var_reservation_status = "cancelled";
            SET var_room_extras_total = 0;
            -- si cancela menos de una semana antes paga el 80%
            IF var_days_before_reservation<7 THEN 
                SET var_room_total = var_room_total*0.8;
            -- si cancela menos de un mes paga el 60%
            ELSEIF var_days_before_reservation<30 THEN
                SET var_room_total = var_room_total*0.60;
            -- si cancela menos de 3 meses paga el 30%
            ELSEIF var_days_before_reservation<90 THEN
                SET var_room_total = var_room_total*0.30;
            -- si cancela con mas de 3 meses de antelacion paga el 10 porciento
            ELSE 
                SET var_room_total = var_room_total*0.10;
            END IF;
        ELSE 
                SET var_reservation_status = "completed";    
        END IF;

        SET var_subtotal = var_room_total + var_services_total + var_room_extras_total;
        INSERT INTO 041_invoices 
(
    invoice_reservation_id,
    invoice_client, 
    invoice_room, 
    invoice_date_in,
    invoice_date_out,
    invoice_total_days, 
    invoice_room_price, 
    invoice_room_total, 
    invoice_room_extras,
    invoice_room_extras_total,
    invoice_services,
    invoice_room_services_total,
    invoice_status,
    invoice_subtotal 
)
VALUES 
(
    var_reservation_id,
    var_client,
    var_room,
    var_date_in,
    var_date_out,
    var_total_days,
    var_room_price,
    var_room_total,
    var_room_extras,
    var_room_extras_total,
    var_services,
    var_services_total,
    var_reservation_status,
    var_subtotal
);

     END IF;
END$$
DELIMITER ;


DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `041_insertReservation`(IN `var_date_in` DATE, IN `var_date_out` DATE, IN `var_type` INT, IN `var_customer` INT)
BEGIN
DECLARE var_room_id INT;
DECLARE var_price DECIMAL(10,2);
DECLARE var_room_extras VARCHAR(255);
DECLARE var_reservation_services VARCHAR(255);

DECLARE i INT DEFAULT 0;
DECLARE num_rooms INT;

-- we double check the availability of the rooms (this should first be checked in PHP and thend use this procedure)
IF (041_checkAvailableRooms(var_date_in, var_date_out, var_type) IS NOT NULL) THEN
    -- use the function to get a random available room
    SET var_room_id = (041_checkAvailableRooms(var_date_in, var_date_out, var_type));
    -- we get the current price of that type of room
    SET var_price= (SELECT type_price_per_day  FROM room_types WHERE type_id = var_type);

    -- we inserts the fields into the reservations table
    INSERT INTO 041_reservations (reservation_client, reservation_room, reservation_date_in, reservation_date_out, reservation_room_price, reservation_room_extras, reservation_services, reservation_status)
    VALUES (var_customer, var_room_id, var_date_in, var_date_out, var_price, '{
        "streamingServicesOnTV": [0],
        "airConditioner": [0],
        "tvPremiumSoundbar": [0]
    }', '{
        "prices":{
            "bar":[],
            "dvdRenting":[],
            "gym":[],
            "spa":[]
        },
        "dates":{
            "bar":[],
            "dvdRenting":[],
            "gym":[],
            "spa":[]
        },
        "descriptions":{
            "bar":[],
            "dvdRenting":[],
            "gym":[],
            "spa":[]
        }
    }', 'booked');

    ELSE
        SELECT "Sorry, there are no rooms available of that type. Here's the other types of rooms that are available " AS 'msg';
        SET var_type = (SELECT type_id FROM room_types ORDER BY type_id DESC LIMIT 1);
        WHILE i < var_type DO
            SET i=i+1;
            IF 041_checkAvailableRooms(var_date_in, var_date_out, i) IS NOT NULL THEN
                SELECT type_name, type_description FROM room_types WHERE type_id = i;
            END IF;
        END WHILE;
END IF;

END$$
DELIMITER ;


DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `041_serviceAdd`(IN `var_service` INT, IN `var_description` VARCHAR(255), IN `var_room` INT, IN `var_price` DECIMAL(10,2))
BEGIN
    DECLARE var_reservation_id INT;
    DECLARE json_data JSON;
    DECLARE var_service_string VARCHAR(255);

    IF var_room IN (SELECT room_id FROM rooms WHERE room_status = 'check-in') AND var_service BETWEEN 1 AND 4 THEN
        -- we get the reservation id of the reservation that's currently occupying the room
        SET var_reservation_id = (
        SELECT reservation_id  
        FROM 041_reservations 
        WHERE reservation_room = var_room 
        AND reservation_status='check-in');

        -- we get the json of the services
        SET json_data = (
        SELECT reservation_services  
        FROM reservations 
        WHERE reservation_room = var_room 
        AND reservation_status='check-in');

        -- it will get a key depending on the service we want ot introduce the information to
        IF var_service = 1 THEN
            SET var_service_string = 'bar';
        ELSEIF var_service = 2 THEN
            SET var_service_string = 'dvdRenting';
        ELSEIF var_service = 3 THEN
            SET var_service_string = 'gym';
        ELSEIF var_service = 4 THEN
            SET var_service_string = 'spa';
        END IF;

        -- with the variables and the now() function we introduce the informatiion to the json variable
        SET json_data = JSON_ARRAY_APPEND(json_data, CONCAT('$.prices.',var_service_string), var_price);
        SET json_data = JSON_ARRAY_APPEND(json_data, CONCAT('$.descriptions.',var_service_string), var_description);
        SET json_data = JSON_ARRAY_APPEND(json_data, CONCAT('$.dates.',var_service_string), NOW());

        
        UPDATE 041_reservations
        SET reservation_services = json_data
        WHERE reservation_id = var_reservation_id;
     ELSE 
     SELECT "ERROR - Room/Reservation not found Or incorrect service number";
     END IF;
END$$
DELIMITER ;