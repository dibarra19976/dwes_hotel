-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 17, 2023 at 12:37 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `041_hotel`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `041_checkAvailableRooms` (IN `var_date_in` DATE, IN `var_date_out` DATE)   BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `041_checkOut` (IN `var_reservation_id` INT)   BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `041_insertReservation` (IN `var_date_in` DATE, IN `var_date_out` DATE, IN `var_type` INT, IN `var_customer` INT)   BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `041_serviceAdd` (IN `var_service` INT, IN `var_description` VARCHAR(255), IN `var_room` INT, IN `var_price` DECIMAL(10,2))   BEGIN
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

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `041_checkAvailableRooms` (`var_date_in` DATE, `var_date_out` DATE, `var_type` INT) RETURNS INT(11)  BEGIN
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

CREATE DEFINER=`root`@`localhost` FUNCTION `041_fullName` (`var_fname` VARCHAR(255), `var_lname` VARCHAR(255)) RETURNS VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    -- simplifies the concat function, when we want to put the first and last name of a person in a row together
    RETURN concat(var_fname," ", var_lname);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `041_getRoomExtrasTotal` (`json_data` JSON) RETURNS DECIMAL(10,2)  BEGIN
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

CREATE DEFINER=`root`@`localhost` FUNCTION `041_getServicesTotal` (`json_data` JSON) RETURNS DECIMAL(10,2)  BEGIN
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

-- --------------------------------------------------------

--
-- Table structure for table `041_customers`
--

CREATE TABLE `041_customers` (
  `customer_id` int(11) NOT NULL,
  `customer_fname` varchar(100) DEFAULT NULL,
  `customer_lname` varchar(100) DEFAULT NULL,
  `customer_dni` varchar(100) DEFAULT NULL,
  `customer_email` varchar(100) DEFAULT NULL,
  `customer_phone` varchar(100) DEFAULT NULL,
  `customer_birthdate` date DEFAULT NULL,
  `customer_password` varchar(255) DEFAULT NULL,
  `customer_status` set('customer','admin','disabled') NOT NULL DEFAULT 'customer'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `041_customers`
--

INSERT INTO `041_customers` (`customer_id`, `customer_fname`, `customer_lname`, `customer_dni`, `customer_email`, `customer_phone`, `customer_birthdate`, `customer_password`, `customer_status`) VALUES
(1, 'Ana    ', 'RodríguezS', '135792468', 'anarodriguez@gmail.com', '123-456-7890', '2023-10-04', '21312', 'disabled'),
(2, 'Javier', 'García', '246813579', 'javiergarcia@gmail.com', '234-567-8901', NULL, NULL, 'disabled'),
(3, 'Isabel', 'Fernández', '987654321', 'isabelfernandez@gmail.com', '345-678-9012', NULL, NULL, 'customer'),
(4, 'Sergio', 'González', '864209753', 'sergiogonzalez@gmail.com', '456-789-0123', NULL, NULL, 'customer'),
(5, 'Carmen', 'Torres', '147258369', 'carmentorres@gmail.com', '567-890-1234', NULL, NULL, 'disabled'),
(6, 'Miguel', 'Ortega', '258369147', 'miguelortega@gmail.com', '678-901-2345', NULL, NULL, 'customer'),
(7, 'Sofía  ', 'Navarro', '369258147', 'sofianavarro@gmail.com', '789-012-3456', '2023-10-16', '123132', 'disabled'),
(8, 'Daniel', 'Hernández', '852741963', 'danielhernandez@gmail.com', '890-123-4567', NULL, NULL, 'customer'),
(9, 'Luisa', 'Pérez', '963258741', 'luisaperez@gmail.com', '901-234-5678', NULL, NULL, 'customer'),
(10, 'Andrés', 'Romero', '741852963', 'andresromero@gmail.com', '012-345-6789', NULL, NULL, 'disabled'),
(11, 'Elena', 'Soto', '321654987', 'elenasoto@gmail.com', '123-456-7890', NULL, NULL, 'customer'),
(12, 'Hugo', 'Guerrero', '987321654', 'hugoguerrero@gmail.com', '234-567-8901', NULL, NULL, 'customer'),
(13, 'Valeria', 'Molina', '654987321', 'valeriamolina@gmail.com', '345-678-9012', NULL, NULL, 'customer'),
(14, 'Alejandro', 'Rojas', '789456123', 'alejandrorojas@gmail.com', '456-789-0123', NULL, NULL, 'customer'),
(15, 'Carolina', 'Vargas', '456123789', 'carolinavargas@gmail.com', '567-890-1234', NULL, NULL, 'disabled'),
(16, 'Gabriel', 'Silva', '321654987', 'gabrielsilva@gmail.com', '678-901-2345', NULL, NULL, 'customer'),
(17, 'Fernanda', 'Mendoza', '987654321', 'fernandamendoza@gmail.com', '789-012-3456', NULL, NULL, 'disabled'),
(18, 'Diego', 'Olivares', '123456789', 'diegoolivares@gmail.com', '890-123-4567', NULL, NULL, 'disabled'),
(19, 'Lorena ', 'Guzmán', '987654321', 'lorenaguzman@gmail.com', '901-234-5678', '2003-11-05', '1234', 'admin'),
(20, 'Jorge', 'Cortés', '369852147', 'jorgecortes@gmail.com', '012-345-6789', NULL, NULL, 'disabled'),
(21, 'Pedro', 'Pascal', '1414312F', 'pedroPascal@gmail.com', '675917274', NULL, 'pedro', 'admin'),
(53, 'Peter ', 'Pons', '7892327923', 'dasdasdasdas@mgail.cpm', '1231313213214', '1969-10-28', '123131', 'customer'),
(54, 'Enrique  ', 'Vizcaíno ', '11111', 'dwesteacher', '11111', '2001-11-17', 'enrique', 'admin');

-- --------------------------------------------------------

--
-- Table structure for table `041_invoices`
--

CREATE TABLE `041_invoices` (
  `invoice_reservation_id` int(11) NOT NULL,
  `invoice_client` int(11) DEFAULT NULL,
  `invoice_room` int(11) DEFAULT NULL,
  `invoice_date_in` date DEFAULT NULL,
  `invoice_date_out` date DEFAULT NULL,
  `invoice_total_days` int(11) DEFAULT NULL,
  `invoice_room_price` decimal(10,2) DEFAULT NULL,
  `invoice_room_total` decimal(10,2) DEFAULT NULL,
  `invoice_room_extras` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`invoice_room_extras`)),
  `invoice_room_extras_total` decimal(10,2) DEFAULT NULL,
  `invoice_services` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`invoice_services`)),
  `invoice_room_services_total` decimal(10,2) DEFAULT NULL,
  `invoice_status` set('completed','cancelled') NOT NULL DEFAULT 'completed',
  `invoice_subtotal` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `041_invoices`
--

INSERT INTO `041_invoices` (`invoice_reservation_id`, `invoice_client`, `invoice_room`, `invoice_date_in`, `invoice_date_out`, `invoice_total_days`, `invoice_room_price`, `invoice_room_total`, `invoice_room_extras`, `invoice_room_extras_total`, `invoice_services`, `invoice_room_services_total`, `invoice_status`, `invoice_subtotal`) VALUES
(1, 1, 1, '2023-07-01', '2023-07-28', 27, 111.00, 1798.20, '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 0.00, '{\"prices\": {\"bar\": [1.00, 1.00, 1.00, 12.00], \"dvdRenting\": [], \"gym\": [], \"spa\": []}, \"dates\": {\"bar\": [\"2023-06-05\", \"2023-06-05\", \"2023-06-05\", \"2023-06-06\"], \"dvdRenting\": [], \"gym\": [], \"spa\": []}, \"descriptions\": {\"bar\": [\"1\", \"1\", \"1\", \"Pan con queso\"], \"dvdRenting\": [], \"gym\": [], \"spa\": []}}', 15.00, 'cancelled', 1813.20),
(2, 3, 10, '2023-03-21', '2023-03-22', 1, 250.00, 250.00, '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 0.00, '{\"prices\": {\"bar\": [122.00, 122.00], \"dvdRenting\": [], \"gym\": [], \"spa\": []}, \"dates\": {\"bar\": [\"2023-06-08 11:12:57\", \"2023-06-08 11:13:02\"], \"dvdRenting\": [], \"gym\": [], \"spa\": []}, \"descriptions\": {\"bar\": [\"Prueba\", \"Prueba\"], \"dvdRenting\": [], \"gym\": [], \"spa\": []}}', 244.00, 'completed', 494.00),
(8, 5, 20, '2023-10-10', '2023-10-11', 1, 350.00, 35.00, '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 0.00, '{\n        \"prices\":{\n            \"bar\":[],\n            \"dvdRenting\":[],\n            \"gym\":[],\n            \"spa\":[]\n        },\n        \"dates\":{\n            \"bar\":[],\n            \"dvdRenting\":[],\n            \"gym\":[],\n            \"spa\":[]\n        },\n        \"descriptions\":{\n            \"bar\":[],\n            \"dvdRenting\":[],\n            \"gym\":[],\n            \"spa\":[]\n        }\n    }', 0.00, 'cancelled', 35.00),
(10, 5, 19, '2023-10-08', '2023-10-09', 1, 350.00, 350.00, '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 0.00, '{\"prices\": {\"bar\": [1231.00], \"dvdRenting\": [], \"gym\": [], \"spa\": []}, \"dates\": {\"bar\": [\"2023-06-06\"], \"dvdRenting\": [], \"gym\": [], \"spa\": []}, \"descriptions\": {\"bar\": [\"morbius\"], \"dvdRenting\": [], \"gym\": [], \"spa\": []}}', 1231.00, 'completed', 1581.00),
(11, 12, 9, '2023-06-10', '2023-06-11', 1, 50.00, 50.00, '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 0.00, '{\"prices\": {\"bar\": [1.00], \"dvdRenting\": [], \"gym\": [], \"spa\": []}, \"dates\": {\"bar\": [\"2023-06-08 12:16:12\"], \"dvdRenting\": [], \"gym\": [], \"spa\": []}, \"descriptions\": {\"bar\": [\"1\"], \"dvdRenting\": [], \"gym\": [], \"spa\": []}}', 1.00, 'completed', 51.00),
(12, 1, 16, '2023-05-10', '2023-05-21', 11, 200.00, 2200.00, '{\n        \n\n  \"streamingServicesOnTV\": [0],\n  \"airConditioner\": [0],\n  \"tvPremiumSoundbar\": [0]\n}\n', 0.00, '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 0.00, 'completed', 2200.00);

-- --------------------------------------------------------

--
-- Table structure for table `041_reservations`
--

CREATE TABLE `041_reservations` (
  `reservation_id` int(11) NOT NULL,
  `reservation_client` int(11) DEFAULT NULL,
  `reservation_room` int(11) DEFAULT NULL,
  `reservation_date_in` date DEFAULT NULL,
  `reservation_date_out` date DEFAULT NULL,
  `reservation_room_price` decimal(10,2) DEFAULT NULL,
  `reservation_room_extras` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`reservation_room_extras`)),
  `reservation_services` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`reservation_services`)),
  `reservation_status` set('booked','check-in','check-out','cancelled') NOT NULL DEFAULT 'booked'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `041_reservations`
--

INSERT INTO `041_reservations` (`reservation_id`, `reservation_client`, `reservation_room`, `reservation_date_in`, `reservation_date_out`, `reservation_room_price`, `reservation_room_extras`, `reservation_services`, `reservation_status`) VALUES
(1, 1, 1, '2023-07-01', '2023-07-28', 111.00, '\n{\n  \"streamingServicesOnTV\": [0],\n  \"airConditioner\": [0],\n  \"tvPremiumSoundbar\": [0]\n}\n', '{\"prices\": {\"bar\": [1.00, 1.00, 1.00, 12.00], \"dvdRenting\": [], \"gym\": [], \"spa\": []}, \"dates\": {\"bar\": [\"2023-06-05\", \"2023-06-05\", \"2023-06-05\", \"2023-06-06\"], \"dvdRenting\": [], \"gym\": [], \"spa\": []}, \"descriptions\": {\"bar\": [\"1\", \"1\", \"1\", \"Pan con queso\"], \"dvdRenting\": [], \"gym\": [], \"spa\": []}}', 'cancelled'),
(2, 3, 10, '2023-03-21', '2023-03-22', 250.00, '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\"prices\": {\"bar\": [122.00, 122.00], \"dvdRenting\": [], \"gym\": [], \"spa\": []}, \"dates\": {\"bar\": [\"2023-06-08 11:12:57\", \"2023-06-08 11:13:02\"], \"dvdRenting\": [], \"gym\": [], \"spa\": []}, \"descriptions\": {\"bar\": [\"Prueba\", \"Prueba\"], \"dvdRenting\": [], \"gym\": [], \"spa\": []}}', 'check-out'),
(3, 1, 7, '2023-10-10', '2023-10-11', 12.00, '{\"streamingServicesOnTV\":[15],\"airConditioner\":[0],\"tvPremiumSoundbar\":[12]}', '{\n        \"prices\":{\n            \"bar\":[11,12,15.5],\n            \"dvdRenting\":[],\n            \"gym\":[],\n            \"spa\":[]\n        },\n        \"dates\":{\n            \"bar\":[],\n            \"dvdRenting\":[],\n            \"gym\":[],\n            \"spa\":[]\n        },\n        \"descriptions\":{\n            \"bar\":[],\n            \"dvdRenting\":[],\n            \"gym\":[],\n            \"spa\":[]\n        }\n    }', 'booked'),
(8, 5, 20, '2023-10-10', '2023-10-11', 350.00, '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\n        \"prices\":{\n            \"bar\":[],\n            \"dvdRenting\":[],\n            \"gym\":[],\n            \"spa\":[]\n        },\n        \"dates\":{\n            \"bar\":[],\n            \"dvdRenting\":[],\n            \"gym\":[],\n            \"spa\":[]\n        },\n        \"descriptions\":{\n            \"bar\":[],\n            \"dvdRenting\":[],\n            \"gym\":[],\n            \"spa\":[]\n        }\n    }', 'cancelled'),
(9, 5, 18, '2023-10-10', '2023-10-11', 350.00, '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\"prices\": {\"bar\": [18.00], \"dvdRenting\": [], \"gym\": [], \"spa\": [1.00]}, \"dates\": {\"bar\": [\"2023-06-11 15:23:09\"], \"dvdRenting\": [], \"gym\": [], \"spa\": [\"2023-06-11 16:02:45\"]}, \"descriptions\": {\"bar\": [\"18\"], \"dvdRenting\": [], \"gym\": [], \"spa\": [\"Prueba\"]}}', 'check-in'),
(10, 5, 19, '2023-10-08', '2023-10-09', 350.00, '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\"prices\": {\"bar\": [1231.00], \"dvdRenting\": [], \"gym\": [], \"spa\": []}, \"dates\": {\"bar\": [\"2023-06-06\"], \"dvdRenting\": [], \"gym\": [], \"spa\": []}, \"descriptions\": {\"bar\": [\"morbius\"], \"dvdRenting\": [], \"gym\": [], \"spa\": []}}', 'check-out'),
(11, 12, 9, '2023-06-10', '2023-06-11', 50.00, '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\"prices\": {\"bar\": [1.00], \"dvdRenting\": [], \"gym\": [], \"spa\": []}, \"dates\": {\"bar\": [\"2023-06-08 12:16:12\"], \"dvdRenting\": [], \"gym\": [], \"spa\": []}, \"descriptions\": {\"bar\": [\"1\"], \"dvdRenting\": [], \"gym\": [], \"spa\": []}}', 'check-out'),
(12, 1, 16, '2023-05-10', '2023-05-21', 200.00, '{\n        \n\n  \"streamingServicesOnTV\": [0],\n  \"airConditioner\": [0],\n  \"tvPremiumSoundbar\": [0]\n}\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'check-out'),
(13, 4, 19, '2023-07-08', '2023-08-03', 350.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(14, 6, 10, '2023-07-27', '2023-08-29', 250.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(15, 3, 5, '2023-08-15', '2023-09-11', 70.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(16, 6, 19, '2023-08-23', '2023-09-16', 350.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(17, 9, 11, '2023-07-07', '2023-07-28', 250.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(18, 15, 12, '2023-07-26', '2023-08-25', 250.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(19, 14, 16, '2023-07-02', '2023-08-01', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(20, 12, 10, '2023-06-30', '2023-07-27', 250.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(21, 17, 11, '2023-08-04', '2023-08-31', 250.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(22, 20, 4, '2023-08-12', '2023-09-14', 70.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(23, 13, 8, '2023-07-18', '2023-08-15', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(24, 19, 17, '2023-08-25', '2023-09-26', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(25, 1, 6, '2023-07-22', '2023-08-19', 70.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(26, 19, 18, '2023-08-27', '2023-09-25', 350.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(27, 19, 14, '2023-08-05', '2023-08-27', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(28, 8, 15, '2023-08-11', '2023-09-13', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(29, 12, 16, '2023-08-23', '2023-09-14', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(30, 6, 5, '2023-07-15', '2023-08-11', 70.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(31, 18, 18, '2023-07-23', '2023-08-23', 350.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(32, 12, 4, '2023-07-15', '2023-08-05', 70.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(33, 7, 17, '2023-07-08', '2023-08-05', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(34, 2, 9, '2023-08-20', '2023-09-20', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(35, 18, 13, '2023-07-14', '2023-08-10', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(36, 10, 15, '2023-07-03', '2023-07-26', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(37, 5, 8, '2023-08-25', '2023-09-17', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(38, 19, 3, '2023-07-29', '2023-08-30', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(39, 3, 1, '2023-07-29', '2023-08-18', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(40, 18, 1, '2023-08-23', '2023-09-20', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(41, 15, 6, '2023-08-23', '2023-09-20', 70.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(42, 14, 2, '2023-07-14', '2023-08-09', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(43, 13, 14, '2023-07-01', '2023-08-02', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(44, 9, 7, '2023-07-20', '2023-08-12', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(45, 12, 9, '2023-07-07', '2023-08-01', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(46, 8, 2, '2023-08-23', '2023-09-14', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(47, 5, 13, '2023-08-22', '2023-09-18', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(48, 12, 7, '2023-08-19', '2023-09-10', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(49, 16, 3, '2023-08-30', '2023-09-24', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(50, 15, 1, '2023-07-05', '2023-07-28', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(51, 16, 18, '2023-07-01', '2023-07-21', 350.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(52, 13, 14, '2023-08-28', '2023-09-20', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(53, 14, 12, '2023-08-29', '2023-09-18', 250.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(54, 5, 3, '2023-07-03', '2023-07-25', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(55, 1, 10, '2023-08-30', '2023-09-22', 250.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(56, 12, 12, '2023-07-05', '2023-07-25', 250.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(57, 5, 6, '2023-07-01', '2023-07-21', 70.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(58, 2, 16, '2023-08-01', '2023-08-22', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(59, 1, 17, '2023-08-05', '2023-08-25', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(60, 3, 19, '2023-08-03', '2023-08-23', 350.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(61, 13, 18, '2024-06-16', '2024-07-17', 350.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(62, 11, 18, '2024-04-05', '2024-04-26', 350.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(63, 15, 3, '2024-07-07', '2024-08-07', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(82, 4, 11, '2023-09-06', '2023-10-12', 250.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(83, 3, 12, '2023-09-21', '2023-10-16', 250.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(84, 1, 15, '2023-09-20', '2023-10-25', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(85, 4, 4, '2023-10-01', '2023-11-12', 70.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(86, 18, 7, '2023-09-10', '2023-10-02', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(87, 1, 16, '2023-09-17', '2023-10-22', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(88, 13, 10, '2023-09-24', '2023-10-27', 250.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(89, 5, 13, '2023-09-18', '2023-10-18', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(90, 15, 19, '2023-10-17', '2023-11-18', 350.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(91, 18, 14, '2023-09-22', '2023-10-23', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(92, 5, 11, '2023-10-12', '2023-11-19', 250.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(93, 20, 12, '2023-10-16', '2023-11-22', 250.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(94, 2, 3, '2023-09-24', '2023-10-28', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(95, 4, 5, '2023-11-08', '2023-12-02', 70.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(96, 15, 6, '2023-09-29', '2023-10-20', 70.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(97, 14, 6, '2023-11-11', '2023-12-01', 70.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(98, 12, 18, '2023-12-05', '2024-01-12', 350.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(99, 2, 13, '2023-12-29', '2024-01-28', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked');
INSERT INTO `041_reservations` (`reservation_id`, `reservation_client`, `reservation_room`, `reservation_date_in`, `reservation_date_out`, `reservation_room_price`, `reservation_room_extras`, `reservation_services`, `reservation_status`) VALUES
(100, 16, 18, '2024-01-20', '2024-02-26', 350.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(101, 2, 5, '2023-09-22', '2023-11-01', 70.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(102, 14, 17, '2023-10-02', '2023-10-30', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(103, 19, 16, '2023-11-13', '2023-12-15', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(104, 10, 19, '2024-02-29', '2024-03-28', 350.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(105, 19, 10, '2023-11-01', '2023-11-23', 250.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(106, 3, 17, '2024-01-08', '2024-02-08', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(107, 10, 15, '2023-11-24', '2024-01-02', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(108, 10, 18, '2023-10-15', '2023-11-11', 350.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(109, 5, 2, '2023-09-23', '2023-10-25', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(110, 10, 17, '2023-11-20', '2023-12-17', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(111, 20, 11, '2023-12-03', '2023-12-31', 250.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(112, 10, 3, '2023-11-14', '2023-12-08', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(113, 19, 7, '2023-10-22', '2023-11-17', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(114, 4, 9, '2023-10-04', '2023-11-16', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(115, 11, 8, '2023-10-19', '2023-11-26', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(116, 13, 14, '2023-11-18', '2023-12-15', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(117, 8, 2, '2024-01-13', '2024-02-03', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(118, 17, 13, '2023-10-29', '2023-11-25', 200.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(119, 7, 1, '2023-09-25', '2023-11-02', 50.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(120, 13, 4, '2023-11-30', '2024-01-01', 70.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(121, 13, 19, '2023-09-17', '2023-10-08', 350.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(122, 3, 5, '2023-12-04', '2024-01-02', 70.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(123, 17, 6, '2023-12-08', '2024-01-12', 70.00, '{\r\n        \r\n\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(124, 16, 9, '2023-11-25', '2023-12-26', 50.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(125, 1, 11, '2023-06-01', '2023-06-15', 250.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(126, 1, 18, '2023-06-01', '2023-06-15', 350.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(127, 17, 8, '2024-01-07', '2024-02-16', 50.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(128, 5, 19, '2050-04-05', '2050-04-10', 350.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(129, 5, 18, '2050-04-05', '2050-04-10', 350.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(130, 15, 8, '2023-09-19', '2023-10-12', 50.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(131, 5, 18, '2050-04-10', '2050-04-26', 350.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(132, 5, 19, '2050-04-10', '2050-04-26', 350.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(133, 19, 2, '2023-11-07', '2023-12-17', 50.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(134, 11, 7, '2023-11-22', '2023-12-20', 50.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(135, 8, 1, '2023-11-02', '2023-12-03', 50.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(136, 14, 19, '2023-11-23', '2023-12-20', 350.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(137, 4, 3, '2023-12-08', '2024-01-09', 50.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(138, 17, 12, '2023-12-04', '2024-01-08', 250.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(139, 19, 19, '2024-01-08', '2024-01-31', 350.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(140, 1, 16, '2024-04-10', '2024-05-13', 200.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(141, 6, 13, '2024-05-18', '2024-06-22', 200.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(142, 5, 5, '2024-05-11', '2024-06-09', 70.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(143, 12, 15, '2024-04-15', '2024-05-12', 200.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(144, 11, 13, '2024-04-20', '2024-05-10', 200.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(145, 20, 19, '2024-06-06', '2024-07-19', 350.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(146, 18, 12, '2024-02-14', '2024-03-20', 250.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(147, 12, 6, '2024-07-02', '2024-07-30', 70.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(148, 16, 10, '2023-12-29', '2024-01-26', 250.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(149, 16, 1, '2023-12-24', '2024-01-19', 50.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(150, 5, 5, '2024-03-07', '2024-04-14', 70.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(151, 9, 11, '2024-01-03', '2024-02-09', 250.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(152, 12, 9, '2024-02-04', '2024-03-18', 50.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(153, 20, 16, '2024-02-26', '2024-03-24', 200.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(154, 4, 10, '2023-11-30', '2023-12-24', 250.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(155, 14, 12, '2024-01-16', '2024-02-08', 250.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(156, 17, 8, '2023-12-15', '2024-01-06', 50.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(157, 16, 14, '2023-12-22', '2024-02-03', 200.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(158, 7, 9, '2024-01-10', '2024-02-03', 50.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(159, 16, 7, '2024-01-09', '2024-02-06', 50.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(160, 3, 11, '2024-03-03', '2024-04-06', 250.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(161, 11, 4, '2024-02-23', '2024-03-17', 70.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(162, 8, 16, '2023-12-23', '2024-01-12', 200.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(163, 14, 2, '2024-04-17', '2024-05-11', 50.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(164, 19, 15, '2024-02-17', '2024-03-18', 200.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(165, 1, 8, '2024-02-27', '2024-03-28', 50.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(166, 9, 4, '2024-01-17', '2024-02-20', 70.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(167, 11, 5, '2024-01-05', '2024-02-04', 70.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(168, 10, 12, '2024-04-01', '2024-04-21', 250.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(169, 8, 3, '2024-01-17', '2024-02-17', 50.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(170, 2, 15, '2023-10-31', '2023-11-23', 200.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(171, 1, 17, '2024-03-11', '2024-04-21', 200.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(172, 13, 16, '2024-01-16', '2024-02-15', 200.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(173, 21, 19, '2025-01-01', '2025-12-31', 350.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(174, 21, 18, '2025-01-01', '2025-12-31', 350.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked');
INSERT INTO `041_reservations` (`reservation_id`, `reservation_client`, `reservation_room`, `reservation_date_in`, `reservation_date_out`, `reservation_room_price`, `reservation_room_extras`, `reservation_services`, `reservation_status`) VALUES
(175, 21, 6, '2024-02-20', '2024-03-18', 70.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(176, 14, 13, '2024-02-21', '2024-03-19', 200.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\"prices\": {\"bar\": [15.99], \"dvdRenting\": [], \"gym\": [], \"spa\": []}, \"dates\": {\"bar\": [\"2023-06-11 18:16:10\"], \"dvdRenting\": [], \"gym\": [], \"spa\": []}, \"descriptions\": {\"bar\": [\"3 Coca-Cola Cans\"], \"dvdRenting\": [], \"gym\": [], \"spa\": []}}', 'check-in'),
(177, 5, 13, '2023-11-27', '2023-12-20', 200.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(178, 13, 4, '2024-06-02', '2024-07-15', 70.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(179, 21, 11, '2024-06-12', '2024-07-11', 250.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(180, 20, 7, '2024-03-13', '2024-04-25', 50.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(181, 2, 16, '2024-05-29', '2024-06-23', 200.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(182, 13, 14, '2024-10-30', '2024-12-05', 200.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(183, 13, 12, '2024-05-31', '2024-06-28', 250.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(184, 12, 7, '2024-02-20', '2024-03-13', 50.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(185, 4, 5, '2024-08-01', '2024-08-26', 70.00, '{\n        \"streamingServicesOnTV\": [0],\n        \"airConditioner\": [0],\n        \"tvPremiumSoundbar\": [0]\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(186, 13, 2, '2024-11-19', '2024-12-16', 50.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(187, 8, 6, '2024-12-26', '2025-01-27', 70.00, '{\n        \"streamingServicesOnTV\": [0],\n        \"airConditioner\": [0],\n        \"tvPremiumSoundbar\": [0]\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(188, 3, 10, '2024-08-23', '2024-09-25', 250.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\r\n        \"prices\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"dates\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        },\r\n        \"descriptions\":{\r\n            \"bar\":[],\r\n            \"dvdRenting\":[],\r\n            \"gym\":[],\r\n            \"spa\":[]\r\n        }\r\n    }', 'booked'),
(189, 3, 10, '2025-01-09', '2025-01-29', 250.00, '{\r\n        \"streamingServicesOnTV\": [0],\r\n        \"airConditioner\": [0],\r\n        \"tvPremiumSoundbar\": [0]\r\n    }', '{\n        \"prices\":{\n            \"bar\":[],\n            \"dvdRenting\":[],\n            \"gym\":[],\n            \"spa\":[]\n        },\n        \"dates\":{\n            \"bar\":[],\n            \"dvdRenting\":[],\n            \"gym\":[],\n            \"spa\":[]\n        },\n        \"descriptions\":{\n            \"bar\":[],\n            \"dvdRenting\":[],\n            \"gym\":[],\n            \"spa\":[]\n        }\n    }', 'booked'),
(190, 3, 24, '2023-12-01', '2023-12-03', 50.00, '{\"streamingServicesOnTV\":[1],\"airConditioner\":[899000],\"tvPremiumSoundbar\":[0]}', '{\r\n            \"prices\":{\r\n                \"bar\":[],\r\n                \"dvdRenting\":[],\r\n                \"gym\":[],\r\n                \"spa\":[]\r\n            },\r\n            \"dates\":{\r\n                \"bar\":[],\r\n                \"dvdRenting\":[],\r\n                \"gym\":[],\r\n                \"spa\":[]\r\n            },\r\n            \"descriptions\":{\r\n                \"bar\":[],\r\n                \"dvdRenting\":[],\r\n                \"gym\":[],\r\n                \"spa\":[]\r\n            }\r\n        }', 'booked');

-- --------------------------------------------------------

--
-- Table structure for table `041_rooms`
--

CREATE TABLE `041_rooms` (
  `room_id` int(11) NOT NULL,
  `room_number` varchar(5) DEFAULT NULL,
  `room_available_extras` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`room_available_extras`)),
  `room_type` int(11) DEFAULT NULL,
  `room_status` set('ready','check-in','check-out','unavailable') DEFAULT NULL,
  `room_img_main` varchar(255) NOT NULL,
  `room_img_1` varchar(255) NOT NULL,
  `room_img_2` varchar(255) NOT NULL,
  `room_img_3` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `041_rooms`
--

INSERT INTO `041_rooms` (`room_id`, `room_number`, `room_available_extras`, `room_type`, `room_status`, `room_img_main`, `room_img_1`, `room_img_2`, `room_img_3`) VALUES
(1, '101', '\n{\n  \"streamingServicesOnTV\": [0],\n  \"airConditioner\": [0],\n  \"tvPremiumSoundbar\": [0]\n}\n', 1, 'check-in', 'a', '', '', ''),
(2, '102', '\n{\n  \"streamingServicesOnTV\": [0],\n  \"airConditioner\": [0],\n  \"tvPremiumSoundbar\": [0]\n}\n', 1, 'ready', '', '', '', ''),
(3, '103', '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 1, 'ready', '', '', '', ''),
(4, '104', '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 2, 'unavailable', '', '', '', ''),
(5, '105', '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 2, 'unavailable', '', '', '', ''),
(6, '201', '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 2, 'ready', '', '', '', ''),
(7, '202', '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 1, 'ready', '', '', '', ''),
(8, '203', '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 1, 'ready', '', '', '', ''),
(9, '204', '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 1, 'unavailable', '', '', '', ''),
(10, '205', '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 3, 'check-out', '', '', '', ''),
(11, '301', '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 3, 'ready', '', '', '', ''),
(12, '302', '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 3, 'ready', '', '', '', ''),
(13, '303', '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 4, 'unavailable', '', '', '', ''),
(14, '304', '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 4, 'ready', '', '', '', ''),
(15, '305', '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 4, 'ready', '', '', '', ''),
(16, '401', '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 4, 'ready', '', '', '', ''),
(17, '402', '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 4, 'ready', '', '', '', ''),
(18, '403', '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 5, 'check-in', '', '', '', ''),
(19, '404', '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 5, 'unavailable', '', '', '', ''),
(20, '405', '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 5, 'unavailable', '', '', '', ''),
(21, '407', '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 1, 'unavailable', '4', '', '', ''),
(22, '406 ', '\r\n{\r\n  \"streamingServicesOnTV\": [0],\r\n  \"airConditioner\": [0],\r\n  \"tvPremiumSoundbar\": [0]\r\n}\r\n', 1, 'unavailable', '1', '2', '3', '4'),
(23, '124 ', '\n{\n  \"streamingServicesOnTV\": [0],\n  \"airConditioner\": [0],\n  \"tvPremiumSoundbar\": [0]\n}\n', 1, 'unavailable', '1', '2', '3', '4'),
(24, '450  ', '{\"streamingServicesOnTV\":[1],\"airConditioner\":[899000],\"tvPremiumSoundbar\":[0]}', 1, 'ready', '2', '1', '3', '4');

-- --------------------------------------------------------

--
-- Table structure for table `041_room_types`
--

CREATE TABLE `041_room_types` (
  `type_id` int(11) NOT NULL,
  `type_name` varchar(100) DEFAULT NULL,
  `type_price_per_day` decimal(10,2) DEFAULT NULL,
  `type_description` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `041_room_types`
--

INSERT INTO `041_room_types` (`type_id`, `type_name`, `type_price_per_day`, `type_description`) VALUES
(1, 'Single Room', 50.00, 'Room with a single bed.'),
(2, 'Double Room', 70.00, 'Spacious room with a double bed.'),
(3, 'Suite', 250.00, 'Luxurious suite with a separate living area and a king-size bed.'),
(4, 'Family Room', 200.00, 'Large room suitable for families, with multiple beds.'),
(5, 'Executive Suite', 350.00, 'Executive suite with a private balcony and stunning views.');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `041_customers`
--
ALTER TABLE `041_customers`
  ADD PRIMARY KEY (`customer_id`),
  ADD UNIQUE KEY `customer_email` (`customer_email`);

--
-- Indexes for table `041_invoices`
--
ALTER TABLE `041_invoices`
  ADD PRIMARY KEY (`invoice_reservation_id`),
  ADD KEY `invoice_client` (`invoice_client`),
  ADD KEY `invoice_room` (`invoice_room`);

--
-- Indexes for table `041_reservations`
--
ALTER TABLE `041_reservations`
  ADD PRIMARY KEY (`reservation_id`),
  ADD KEY `reservation_client` (`reservation_client`),
  ADD KEY `reservation_room` (`reservation_room`);

--
-- Indexes for table `041_rooms`
--
ALTER TABLE `041_rooms`
  ADD PRIMARY KEY (`room_id`),
  ADD KEY `room_type` (`room_type`);

--
-- Indexes for table `041_room_types`
--
ALTER TABLE `041_room_types`
  ADD PRIMARY KEY (`type_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `041_customers`
--
ALTER TABLE `041_customers`
  MODIFY `customer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT for table `041_reservations`
--
ALTER TABLE `041_reservations`
  MODIFY `reservation_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=191;

--
-- AUTO_INCREMENT for table `041_rooms`
--
ALTER TABLE `041_rooms`
  MODIFY `room_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `041_room_types`
--
ALTER TABLE `041_room_types`
  MODIFY `type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `041_invoices`
--
ALTER TABLE `041_invoices`
  ADD CONSTRAINT `041_invoices_ibfk_1` FOREIGN KEY (`invoice_reservation_id`) REFERENCES `041_reservations` (`reservation_id`),
  ADD CONSTRAINT `041_invoices_ibfk_2` FOREIGN KEY (`invoice_client`) REFERENCES `041_customers` (`customer_id`),
  ADD CONSTRAINT `041_invoices_ibfk_3` FOREIGN KEY (`invoice_room`) REFERENCES `041_rooms` (`room_id`);

--
-- Constraints for table `041_reservations`
--
ALTER TABLE `041_reservations`
  ADD CONSTRAINT `041_reservations_ibfk_1` FOREIGN KEY (`reservation_client`) REFERENCES `041_customers` (`customer_id`),
  ADD CONSTRAINT `041_reservations_ibfk_2` FOREIGN KEY (`reservation_room`) REFERENCES `041_rooms` (`room_id`);

--
-- Constraints for table `041_rooms`
--
ALTER TABLE `041_rooms`
  ADD CONSTRAINT `041_rooms_ibfk_1` FOREIGN KEY (`room_type`) REFERENCES `041_room_types` (`type_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
