DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `041_checkAvailableRooms`(`var_date_in` DATE, `var_date_out` DATE, `var_type` INT) RETURNS int(11)
BEGIN
    DECLARE available_room_id INT;
    
    SET available_room_id = (
         SELECT room_id 
        FROM 041_rooms 
        WHERE room_id NOT IN (
            SELECT reservation_room 
            FROM 041_reservations
            WHERE 
                var_date_in < reservation_date_out AND var_date_out > reservation_date_in
                AND reservation_status <> 'cancelled'
        )         
        AND var_type = room_type
        AND room_status <>'unavailable'
        ORDER BY rand()
        LIMIT 1
    );
    
    RETURN available_room_id;
END$$
DELIMITER ;


DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `041_fullName`(var_fname VARCHAR(255), var_lname VARCHAR(255)) RETURNS varchar(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
BEGIN
    -- simplifies the concat function, when we want to put the first and last name of a person in a row together
    RETURN concat(var_fname," ", var_lname);
END$$
DELIMITER ;


DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `041_getRoomExtrasTotal`(`json_data` JSON) RETURNS decimal(10,2)
BEGIN
    DECLARE total_price DECIMAL(10, 2) DEFAULT 0;
    DECLARE i INT DEFAULT 0;
    DECLARE keys_array JSON;
    DECLARE temp_key VARCHAR(255);

    SET keys_array = JSON_KEYS(json_data); 

    WHILE i < JSON_LENGTH(keys_array) DO
        SET temp_key = JSON_UNQUOTE(JSON_EXTRACT(keys_array, CONCAT('$[', i, ']')));
        SET total_price = total_price + JSON_EXTRACT(json_data, CONCAT('$.', temp_key, '[0]'));
        SET i = i + 1;
    END WHILE;

    RETURN total_price;
END$$
DELIMITER ;



DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `041_getServicesTotal`(`json_data` JSON) RETURNS decimal(10,2)
BEGIN
    DECLARE total_price DECIMAL(10, 2) DEFAULT 0;
    DECLARE i INT DEFAULT 0;
    DECLARE j INT DEFAULT 0;
    DECLARE keys_array JSON;
    DECLARE temp_key VARCHAR(255);
    DECLARE iterations INT;

    SET keys_array = JSON_KEYS(json_data,'$.prices'); 

    WHILE i < JSON_LENGTH(keys_array) DO
        SET temp_key = JSON_UNQUOTE(JSON_EXTRACT(keys_array, CONCAT('$[', i, ']')));
        SET iterations = JSON_LENGTH(json_data, CONCAT('$.prices.',temp_key)); 
        SET j = 0; 
        WHILE j < iterations DO
            SET total_price = total_price + JSON_EXTRACT(json_data, CONCAT('$.prices.', temp_key, '[', j, ']'));
            SET j= j + 1;
        END WHILE;
        SET i = i + 1;
    END WHILE;

    RETURN total_price;
END$$
DELIMITER ;