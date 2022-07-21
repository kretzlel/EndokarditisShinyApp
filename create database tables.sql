-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jul 21, 2022 at 05:36 PM
-- Server version: 10.4.21-MariaDB
-- PHP Version: 7.4.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `EndocarditisApp`
--

-- --------------------------------------------------------

--
-- Table structure for table `Patients`
--

CREATE TABLE `Patients` (
  `FirstName` varchar(20) NOT NULL,
  `LastName` varchar(30) NOT NULL,
  `Id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `Patients`
--

INSERT INTO `Patients` (`FirstName`, `LastName`, `Id`) VALUES
('Musterpatient', 'Mustermann', 1);

-- --------------------------------------------------------

--
-- Table structure for table `Symptoms`
--

CREATE TABLE `Symptoms` (
  `PatientId` int(11) NOT NULL,
  `Date` date NOT NULL,
  `Fever` tinyint(1) NOT NULL,
  `Headache` tinyint(1) NOT NULL,
  `Malaise` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `Symptoms`
--

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `username` varchar(256) NOT NULL,
  `password` varchar(256) NOT NULL,
  `admin` int(11) NOT NULL,
  `healthCareProvider` int(11) NOT NULL,
  `linkedPatient` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`username`, `password`, `admin`, `healthCareProvider`, `linkedPatient`) VALUES
('admin', '$2a$12$CxIntUf/5mnCYq8CwxGUu.lN0SuqG4GsJj2VljwC/VgxUqrqe6NWe', 1, 1, 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Patients`
--
ALTER TABLE `Patients`
  ADD PRIMARY KEY (`Id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Patients`
--
ALTER TABLE `Patients`
  MODIFY `Id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
