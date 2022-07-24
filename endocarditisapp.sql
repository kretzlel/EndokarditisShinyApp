-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:8889
-- Generation Time: Jul 24, 2022 at 12:58 PM
-- Server version: 5.7.34
-- PHP Version: 7.4.21

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `endocarditisapp`
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
('Musterpatient', 'Mustermann', 1),
('Margit', 'Mustermann', 2),
('Markus', 'Mustermann', 3);

-- --------------------------------------------------------

--
-- Table structure for table `Symptoms`
--

CREATE TABLE `Symptoms` (
  `entryID` int(11) NOT NULL,
  `PatientId` int(11) NOT NULL,
  `Date` date NOT NULL,
  `Fever` tinyint(1) NOT NULL,
  `Headache` tinyint(1) NOT NULL,
  `Malaise` tinyint(1) NOT NULL,
  `LastEdited` date NOT NULL DEFAULT '2022-07-24'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `username` varchar(256) NOT NULL,
  `password` varchar(256) NOT NULL,
  `admin` int(11) NOT NULL,
  `healthcareProvider` int(11) NOT NULL,
  `linkedPatient` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`username`, `password`, `admin`, `healthcareProvider`, `linkedPatient`) VALUES
('admin', '$2a$12$CxIntUf/5mnCYq8CwxGUu.lN0SuqG4GsJj2VljwC/VgxUqrqe6NWe', 1, 1, 1),
('arzt1', '$2a$12$H7vMT1.mvN1HjKslGwEvVeL5.9n8lj1ZXcgunG5zhQc/J.r392tla', 0, 1, 1),
('arzt2', '$2a$12$PZ3cQXBcHGUQyZ56F8.OMOJTXvlfsvLGWKxee1zpLNFwMHhM1KusC', 0, 1, 2),
('arzt3', '$2a$12$Is2xTvRvbKU9wln1hK.8meYCgvXTpdxkziDBOnwSVgxmB8wo8GmoG', 0, 1, 3),
('pat1', '$2a$12$6xvracpVQKXUyFPc4dTHzOVoKNYRvhYpmcn0nqa3LvfMk1Wfrn7sm', 0, 0, 1),
('pat2', '$2a$12$HNDJFU3/Z8cEe/eE/08KzuR/15wDg1oc2HSGtHr9XrxVdOsm3BG1C', 0, 0, 2),
('pat3', '$2a$12$hfggXhBRZAr.OmyhFy3KW.Ml6ZSrJwikv0zpq.v04/3buZiVLp4xq', 0, 0, 3);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Patients`
--
ALTER TABLE `Patients`
  ADD PRIMARY KEY (`Id`);

--
-- Indexes for table `Symptoms`
--
ALTER TABLE `Symptoms`
  ADD UNIQUE KEY `entryID` (`entryID`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Patients`
--
ALTER TABLE `Patients`
  MODIFY `Id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
