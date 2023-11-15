
CREATE TABLE `041_room_types` (
  `type_id` int(11) NOT NULL AUTO_INCREMENT,
  `type_name` varchar(100) DEFAULT NULL,
  `type_price_per_day` decimal(10,2) DEFAULT NULL,
  `type_description` longtext DEFAULT NULL,
  PRIMARY KEY(`type_id`)
);

CREATE TABLE `041_rooms` (
  `room_id` int(11) NOT NULL,
  `room_number` varchar(5) DEFAULT NULL,
  `room_available_extras` json,
  `room_type` int(11) DEFAULT NULL,
  `room_status` set('ready','check-in','check-out','unavailable') DEFAULT NULL,
  `room_img_main` varchar(255) NOT NULL,
  `room_img_1` varchar(255) NOT NULL,
  `room_img_2` varchar(255) NOT NULL,
  `room_img_3` varchar(255) NOT NULL,
  PRIMARY KEY(`room_id`),
  FOREIGN KEY(`room_type`) REFERENCES `041_room_types`(`type_id`)
);

CREATE TABLE `041_customers` (
  `customer_id` int NOT NULL AUTO_INCREMENT,
  `customer_fname` varchar(100) DEFAULT NULL,
  `customer_lname` varchar(100) DEFAULT NULL,
  `customer_dni` varchar(100) DEFAULT NULL,
  `customer_email` varchar(100) DEFAULT NULL UNIQUE,
  `customer_phone` varchar(100) DEFAULT NULL,
  `customer_birthdate` date DEFAULT NULL,
  `customer_password` varchar(255) DEFAULT NULL,
  `customer_status` set('customer','admin','disabled') NOT NULL DEFAULT 'customer',
  PRIMARY KEY(`customer_id`)
); 

CREATE TABLE `041_reservations` (
  `reservation_id` int(11) NOT NULL,
  `reservation_client` int(11) DEFAULT NULL,
  `reservation_room` int(11) DEFAULT NULL,
  `reservation_date_in` date DEFAULT NULL,
  `reservation_date_out` date DEFAULT NULL,
  `reservation_room_price` decimal(10,2) DEFAULT NULL,
  `reservation_room_extras` json,
  `reservation_services` json,
  `reservation_status` set('booked','check-in','check-out','cancelled') NOT NULL DEFAULT 'booked',
  PRIMARY KEY(`reservation_id`),
  FOREIGN KEY(`reservation_client`) REFERENCES `041_customers`(`customer_id`),
  FOREIGN KEY(`reservation_room`) REFERENCES `041_rooms`(`room_id`)
) ;

CREATE TABLE `041_invoices` (
  `invoice_reservation_id` int(11) NOT NULL,
  `invoice_client` int(11) DEFAULT NULL,
  `invoice_room` int(11) DEFAULT NULL,
  `invoice_date_in` date DEFAULT NULL,
  `invoice_date_out` date DEFAULT NULL,
  `invoice_total_days` int(11) DEFAULT NULL,
  `invoice_room_price` decimal(10,2) DEFAULT NULL,
  `invoice_room_total` decimal(10,2) DEFAULT NULL,
  `invoice_room_extras` json,
  `invoice_room_extras_total` decimal(10,2) DEFAULT NULL,
  `invoice_services` json,
  `invoice_room_services_total` decimal(10,2) DEFAULT NULL,
  `invoice_status`set('completed','cancelled') NOT NULL DEFAULT 'completed',
  `invoice_subtotal` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY(`invoice_reservation_id`),
  FOREIGN KEY(`invoice_reservation_id`) REFERENCES `041_reservations`(`reservation_id`),
  FOREIGN KEY(`invoice_client`) REFERENCES `041_customers`(`customer_id`),
  FOREIGN KEY(`invoice_room`) REFERENCES `041_rooms`(`room_id`)
) ;

