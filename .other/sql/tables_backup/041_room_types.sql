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
-- Indexes for table `041_room_types`
--
ALTER TABLE `041_room_types`
  ADD PRIMARY KEY (`type_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `041_room_types`
--
ALTER TABLE `041_room_types`
  MODIFY `type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
