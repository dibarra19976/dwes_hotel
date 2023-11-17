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
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `041_customers`
--
ALTER TABLE `041_customers`
  MODIFY `customer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
