-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 17, 2023 at 12:38 PM
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

--
-- Indexes for dumped tables
--

--
-- Indexes for table `041_invoices`
--
ALTER TABLE `041_invoices`
  ADD PRIMARY KEY (`invoice_reservation_id`),
  ADD KEY `invoice_client` (`invoice_client`),
  ADD KEY `invoice_room` (`invoice_room`);

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
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
