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

--
-- Indexes for dumped tables
--

--
-- Indexes for table `041_rooms`
--
ALTER TABLE `041_rooms`
  ADD PRIMARY KEY (`room_id`),
  ADD KEY `room_type` (`room_type`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `041_rooms`
--
ALTER TABLE `041_rooms`
  MODIFY `room_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `041_rooms`
--
ALTER TABLE `041_rooms`
  ADD CONSTRAINT `041_rooms_ibfk_1` FOREIGN KEY (`room_type`) REFERENCES `041_room_types` (`type_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
