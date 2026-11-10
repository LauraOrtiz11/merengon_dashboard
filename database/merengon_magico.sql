CREATE DATABASE  IF NOT EXISTS `merengon_magico` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `merengon_magico`;
-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: merengon_magico
-- ------------------------------------------------------
-- Server version	8.0.43

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cliente`
--

DROP TABLE IF EXISTS `cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cliente` (
  `id_cliente` int NOT NULL AUTO_INCREMENT,
  `nombre_c` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_cliente`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cliente`
--

LOCK TABLES `cliente` WRITE;
/*!40000 ALTER TABLE `cliente` DISABLE KEYS */;
INSERT INTO `cliente` VALUES (1,'Ana María Gómez','3101112233'),(2,'Carlos Andrés Pérez','3204445566'),(3,'María Fernanda Rodríguez','3157778899'),(4,'Juan David Torres','3115556677'),(5,'Laura Sofía Sánchez','3228889900'),(6,'Andrés Felipe Vargas','3102223344'),(7,'Camila Andrea Rojas','3186667788'),(8,'Diego Alejandro Herrera','3199990011'),(9,'Valentina Ortiz','3101234567'),(10,'Julián Esteban Peña','3212345678'),(11,'Natalia Guzmán','3123456789'),(12,'Felipe Ríos','3134567890'),(13,'Daniela Martínez','3145678901'),(14,'Santiago Castro','3156789012'),(15,'Isabella Ramírez','3167890123'),(16,'Sebastián Moreno','3178901234'),(17,'Gabriela Jiménez','3189012345'),(18,'Nicolás Cardona','3190123456'),(19,'Mariana Restrepo','3201234567'),(20,'Alejandro Salazar','3212345670'),(21,'Paula Cárdenas','3223456781'),(22,'Juan Pablo Mejía','3234567892'),(23,'Sara Zapata','3245678903'),(24,'Mateo Quintero','3256789014'),(25,'Lucía Betancur','3267890125'),(26,'Tomás Arango','3278901236'),(27,'Manuela Villegas','3289012347'),(28,'Samuel Ospina','3290123458'),(29,'Valeria Agudelo','3301234569'),(30,'Emiliano Zapata','3312345680'),(31,'Juliana Pineda','3323456791'),(32,'Martín Correa','3334567802'),(33,'Sara Echeverri','3345678913'),(34,'Simón Gallego','3356789024'),(35,'Antonella Hoyos','3367890135'),(36,'Emilio Duque','3378901246'),(37,'Renata Palacio','3389012357'),(38,'Joaquín Espinal','3390123468'),(39,'Emma Zuluaga','3401234579'),(40,'Thiago Montoya','3412345680');
/*!40000 ALTER TABLE `cliente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `compra`
--

DROP TABLE IF EXISTS `compra`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `compra` (
  `id_compra` int NOT NULL AUTO_INCREMENT,
  `id_proveedor` int NOT NULL,
  `id_empleado` int NOT NULL,
  `fecha_compra` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `subtotal` decimal(12,2) DEFAULT '0.00',
  `descuento` decimal(12,2) DEFAULT '0.00',
  `impuesto` decimal(12,2) DEFAULT '0.00',
  `total` decimal(12,2) DEFAULT '0.00',
  `metodo` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado` enum('Recibida','Pendiente','Anulada') COLLATE utf8mb4_unicode_ci DEFAULT 'Pendiente',
  PRIMARY KEY (`id_compra`),
  KEY `fk_compra_proveedor` (`id_proveedor`),
  KEY `fk_compra_empleado` (`id_empleado`),
  CONSTRAINT `fk_compra_empleado` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`) ON UPDATE CASCADE,
  CONSTRAINT `fk_compra_proveedor` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compra`
--

LOCK TABLES `compra` WRITE;
/*!40000 ALTER TABLE `compra` DISABLE KEYS */;
INSERT INTO `compra` VALUES (1,1,1,'2026-09-15 08:00:00',250000.00,0.00,47500.00,297500.00,'Transferencia','Recibida'),(2,3,2,'2026-09-16 08:30:00',180000.00,5000.00,33250.00,208250.00,'Efectivo','Recibida'),(3,5,10,'2026-09-17 09:00:00',320000.00,0.00,60800.00,380800.00,'Transferencia','Recibida'),(4,4,1,'2026-09-18 08:15:00',95000.00,0.00,18050.00,113050.00,'Efectivo','Recibida'),(5,8,18,'2026-09-19 09:30:00',145000.00,0.00,27550.00,172550.00,'Transferencia','Recibida'),(6,10,2,'2026-09-20 08:00:00',210000.00,0.00,39900.00,249900.00,'Efectivo','Recibida'),(7,11,10,'2026-09-21 08:45:00',165000.00,0.00,31350.00,196350.00,'Transferencia','Recibida'),(8,1,1,'2026-09-22 08:00:00',230000.00,0.00,43700.00,273700.00,'Efectivo','Recibida'),(9,3,2,'2026-09-23 08:30:00',190000.00,3000.00,35530.00,222530.00,'Transferencia','Recibida'),(10,5,10,'2026-09-24 09:00:00',275000.00,0.00,52250.00,327250.00,'Efectivo','Recibida'),(11,4,1,'2026-09-25 08:15:00',105000.00,0.00,19950.00,124950.00,'Transferencia','Recibida'),(12,8,18,'2026-09-26 09:30:00',155000.00,0.00,29450.00,184450.00,'Efectivo','Recibida'),(13,10,2,'2026-09-27 08:00:00',220000.00,0.00,41800.00,261800.00,'Transferencia','Recibida'),(14,11,10,'2026-09-28 08:45:00',175000.00,0.00,33250.00,208250.00,'Efectivo','Recibida'),(15,1,1,'2026-09-29 08:00:00',240000.00,0.00,45600.00,285600.00,'Transferencia','Recibida'),(16,3,2,'2026-09-30 08:30:00',200000.00,5000.00,37050.00,232050.00,'Efectivo','Recibida'),(17,5,10,'2026-10-01 09:00:00',285000.00,0.00,54150.00,339150.00,'Transferencia','Recibida'),(18,4,1,'2026-10-02 08:15:00',110000.00,0.00,20900.00,130900.00,'Efectivo','Recibida'),(19,8,18,'2026-10-03 09:30:00',160000.00,0.00,30400.00,190400.00,'Transferencia','Recibida'),(20,10,2,'2026-10-04 08:00:00',225000.00,0.00,42750.00,267750.00,'Efectivo','Recibida'),(21,11,10,'2026-10-04 08:45:00',180000.00,0.00,34200.00,214200.00,'Transferencia','Recibida'),(22,2,1,'2026-10-05 08:00:00',98000.00,0.00,18620.00,116620.00,'Efectivo','Recibida'),(23,6,2,'2026-10-05 08:30:00',72000.00,0.00,13680.00,85680.00,'Transferencia','Recibida'),(24,7,10,'2026-10-05 09:00:00',85000.00,0.00,16150.00,101150.00,'Efectivo','Recibida'),(25,12,18,'2026-10-05 09:30:00',95000.00,0.00,18050.00,113050.00,'Transferencia','Recibida');
/*!40000 ALTER TABLE `compra` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalle_compra`
--

DROP TABLE IF EXISTS `detalle_compra`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detalle_compra` (
  `id_detalleC` int NOT NULL AUTO_INCREMENT,
  `id_compra` int NOT NULL,
  `id_insumo` int NOT NULL,
  `cantidad` decimal(12,2) NOT NULL,
  `costo_und` decimal(12,2) NOT NULL,
  `descuento` decimal(12,2) DEFAULT '0.00',
  `subtotal` decimal(12,2) DEFAULT '0.00',
  PRIMARY KEY (`id_detalleC`),
  KEY `fk_dc_compra` (`id_compra`),
  KEY `fk_dc_insumo` (`id_insumo`),
  CONSTRAINT `fk_dc_compra` FOREIGN KEY (`id_compra`) REFERENCES `compra` (`id_compra`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_dc_insumo` FOREIGN KEY (`id_insumo`) REFERENCES `insumo` (`id_insumo`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalle_compra`
--

LOCK TABLES `detalle_compra` WRITE;
/*!40000 ALTER TABLE `detalle_compra` DISABLE KEYS */;
INSERT INTO `detalle_compra` VALUES (1,1,1,30000.00,3.50,0.00,105000.00),(2,1,2,15000.00,7.20,0.00,108000.00),(3,1,3,10000.00,6.00,0.00,60000.00),(4,2,12,10000.00,12.00,0.00,120000.00),(5,2,13,7000.00,9.00,0.00,63000.00),(6,3,6,25000.00,2.50,0.00,62500.00),(7,3,7,15000.00,4.80,0.00,72000.00),(8,3,8,20000.00,2.20,0.00,44000.00),(9,3,9,8000.00,3.90,0.00,31200.00),(10,4,4,12000.00,8.00,0.00,96000.00),(11,5,10,6000.00,15.00,0.00,90000.00),(12,5,11,5000.00,22.00,0.00,110000.00),(13,6,1,25000.00,3.50,0.00,87500.00),(14,6,17,8000.00,25.00,0.00,200000.00),(15,7,11,4000.00,10.00,0.00,40000.00),(16,7,13,6000.00,9.00,0.00,54000.00),(17,7,14,6000.00,7.00,0.00,42000.00),(18,8,2,12000.00,7.20,0.00,86400.00),(19,8,3,8000.00,6.00,0.00,48000.00),(20,8,20,6000.00,8.50,0.00,51000.00),(21,9,12,12000.00,12.00,3000.00,141000.00),(22,9,15,5000.00,11.00,0.00,55000.00),(23,10,6,25000.00,2.50,0.00,62500.00),(24,10,7,18000.00,4.80,0.00,86400.00),(25,10,22,10000.00,12.50,0.00,125000.00),(26,11,4,15000.00,8.00,0.00,120000.00),(27,12,10,7000.00,15.00,0.00,105000.00),(28,12,18,6000.00,14.00,0.00,84000.00),(29,13,1,28000.00,3.50,0.00,98000.00),(30,13,17,9000.00,25.00,0.00,225000.00),(31,14,11,5000.00,10.00,0.00,50000.00),(32,14,13,7000.00,9.00,0.00,63000.00),(33,14,16,5000.00,10.00,0.00,50000.00),(34,15,2,14000.00,7.20,0.00,100800.00),(35,15,3,10000.00,6.00,0.00,60000.00),(36,16,12,11000.00,12.00,5000.00,127000.00),(37,16,14,6000.00,7.00,0.00,42000.00),(38,17,6,28000.00,2.50,0.00,70000.00),(39,17,7,20000.00,4.80,0.00,96000.00),(40,17,8,22000.00,2.20,0.00,48400.00),(41,18,4,16000.00,8.00,0.00,128000.00),(42,19,10,8000.00,15.00,0.00,120000.00),(43,19,11,6000.00,22.00,0.00,132000.00),(44,20,1,30000.00,3.50,0.00,105000.00),(45,20,17,10000.00,25.00,0.00,250000.00),(46,21,23,3000.00,25.00,0.00,75000.00),(47,21,24,4000.00,9.00,0.00,36000.00),(48,22,25,2500.00,30.00,0.00,75000.00),(49,23,20,5000.00,8.50,0.00,42500.00),(50,24,7,12000.00,4.80,0.00,57600.00),(51,25,3,10000.00,6.00,0.00,60000.00);
/*!40000 ALTER TABLE `detalle_compra` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalle_venta`
--

DROP TABLE IF EXISTS `detalle_venta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detalle_venta` (
  `id_detalle` int NOT NULL AUTO_INCREMENT,
  `id_venta` int NOT NULL,
  `id_producto` int NOT NULL,
  `cantidad` int NOT NULL DEFAULT '1',
  `precio_und` decimal(12,2) NOT NULL,
  `descuento` decimal(12,2) DEFAULT '0.00',
  `subtotal` decimal(12,2) DEFAULT '0.00',
  PRIMARY KEY (`id_detalle`),
  KEY `fk_dv_venta` (`id_venta`),
  KEY `fk_dv_producto` (`id_producto`),
  CONSTRAINT `fk_dv_producto` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`) ON UPDATE CASCADE,
  CONSTRAINT `fk_dv_venta` FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=87 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalle_venta`
--

LOCK TABLES `detalle_venta` WRITE;
/*!40000 ALTER TABLE `detalle_venta` DISABLE KEYS */;
INSERT INTO `detalle_venta` VALUES (1,1,1,2,10000.00,0.00,20000.00),(2,2,2,1,12000.00,0.00,12000.00),(3,2,8,1,6000.00,500.00,5500.00),(4,3,3,1,13000.00,0.00,13000.00),(5,3,5,1,13500.00,0.00,13500.00),(6,3,15,1,12500.00,0.00,12500.00),(7,4,6,2,11000.00,0.00,22000.00),(8,5,4,1,12500.00,0.00,12500.00),(9,5,8,1,6000.00,0.00,6000.00),(10,6,7,1,13500.00,0.00,13500.00),(11,6,11,1,7500.00,0.00,7500.00),(12,7,9,1,8000.00,0.00,8000.00),(13,7,20,1,6500.00,0.00,6500.00),(14,8,1,3,10000.00,0.00,30000.00),(15,9,12,1,8500.00,0.00,8500.00),(16,9,17,1,7000.00,0.00,7000.00),(17,10,2,1,12000.00,0.00,12000.00),(18,10,13,1,9500.00,0.00,9500.00),(19,10,20,1,6500.00,0.00,6500.00),(20,11,5,1,13500.00,0.00,13500.00),(21,11,8,1,6000.00,0.00,6000.00),(22,12,6,2,11000.00,0.00,22000.00),(23,12,8,0,6000.00,0.00,2000.00),(24,13,9,2,8000.00,0.00,16000.00),(25,14,3,1,13000.00,0.00,13000.00),(26,14,15,1,12500.00,0.00,12500.00),(27,14,13,1,9500.00,0.00,9500.00),(28,15,4,1,12500.00,0.00,12500.00),(29,15,10,1,9000.00,0.00,9000.00),(30,16,14,1,10500.00,0.00,10500.00),(31,16,17,1,7000.00,0.00,3500.00),(32,17,7,2,13500.00,0.00,27000.00),(33,18,11,1,7500.00,0.00,7500.00),(34,18,12,1,8500.00,0.00,8500.00),(35,18,8,1,6000.00,0.00,2000.00),(36,19,16,1,12000.00,0.00,12000.00),(37,19,3,1,13000.00,0.00,13000.00),(38,19,9,1,8000.00,0.00,8000.00),(39,20,6,1,11000.00,0.00,11000.00),(40,20,10,1,9000.00,0.00,9000.00),(41,21,8,2,6000.00,0.00,12000.00),(42,21,17,0,7000.00,0.00,3500.00),(43,22,1,2,10000.00,0.00,20000.00),(44,22,8,1,6000.00,0.00,6000.00),(45,23,19,2,9500.00,0.00,19000.00),(46,24,5,1,13500.00,0.00,13500.00),(47,24,15,1,12500.00,0.00,12500.00),(48,24,8,1,6000.00,0.00,6000.00),(49,25,2,1,12000.00,0.00,12000.00),(50,25,8,1,6000.00,0.00,6000.00),(51,26,7,1,13500.00,0.00,13500.00),(52,26,13,1,9500.00,0.00,9500.00),(53,26,20,1,6500.00,0.00,6500.00),(54,27,6,1,11000.00,0.00,11000.00),(55,27,16,1,12000.00,0.00,12000.00),(56,28,11,1,7500.00,0.00,7500.00),(57,28,12,1,8500.00,0.00,8500.00),(58,29,1,2,10000.00,0.00,20000.00),(59,29,4,1,12500.00,0.00,12500.00),(60,29,8,0,6000.00,0.00,1500.00),(61,30,9,1,8000.00,0.00,8000.00),(62,30,10,1,9000.00,0.00,9000.00),(63,30,17,1,7000.00,0.00,7000.00),(64,31,3,1,13000.00,0.00,13000.00),(65,31,14,1,10500.00,0.00,10500.00),(66,31,8,1,6000.00,0.00,6000.00),(67,32,20,2,6500.00,0.00,13000.00),(68,32,17,0,7000.00,0.00,1500.00),(69,33,2,1,12000.00,0.00,12000.00),(70,33,5,1,13500.00,0.00,13500.00),(71,33,20,1,6500.00,0.00,6500.00),(72,34,6,1,11000.00,0.00,11000.00),(73,34,9,1,8000.00,0.00,8000.00),(74,35,7,1,13500.00,0.00,13500.00),(75,35,11,1,7500.00,0.00,7500.00),(76,35,8,0,6000.00,0.00,3500.00),(77,36,12,2,8500.00,0.00,17000.00),(78,37,4,1,12500.00,0.00,12500.00),(79,37,15,1,12500.00,0.00,12500.00),(80,37,8,0,6000.00,0.00,4500.00),(81,38,10,1,9000.00,0.00,9000.00),(82,38,19,1,9500.00,0.00,9500.00),(83,39,3,1,13000.00,0.00,13000.00),(84,39,16,1,12000.00,0.00,12000.00),(85,39,6,1,11000.00,0.00,11000.00),(86,40,14,2,10500.00,0.00,21000.00);
/*!40000 ALTER TABLE `detalle_venta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `empleado`
--

DROP TABLE IF EXISTS `empleado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `empleado` (
  `id_empleado` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellido` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cargo` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `salario` decimal(12,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id_empleado`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `empleado`
--

LOCK TABLES `empleado` WRITE;
/*!40000 ALTER TABLE `empleado` DISABLE KEYS */;
INSERT INTO `empleado` VALUES (1,'Luis Alberto','Martínez','Chef','3001112222',2800000.00),(2,'Sofía','Ramírez','Repostera','3003334444',2400000.00),(3,'Pedro','Castro','Auxiliar','3005556666',1500000.00),(4,'Andrés','Mora','Mesero','3011112233',1600000.00),(5,'Valentina','Ortiz','Cajera','3022223344',1700000.00),(6,'Julián','Peña','Auxiliar','3033334455',1500000.00),(7,'Natalia','Guzmán','Repostera','3044445566',2300000.00),(8,'Felipe','Ríos','Domiciliario','3055556677',1400000.00),(9,'Daniela','Martínez','Mesera','3066667788',1600000.00),(10,'Santiago','Castro','Chef','3077778899',2700000.00),(11,'Isabella','Ramírez','Cajera','3088889900',1700000.00),(12,'Sebastián','Moreno','Auxiliar','3099990011',1500000.00),(13,'Gabriela','Jiménez','Repostera','3101010101',2400000.00),(14,'Nicolás','Cardona','Mesero','3112020202',1600000.00),(15,'Mariana','Restrepo','Cajera','3123030303',1700000.00),(16,'Alejandro','Salazar','Domiciliario','3134040404',1400000.00),(17,'Paula','Cárdenas','Auxiliar','3145050505',1500000.00),(18,'Juan Pablo','Mejía','Chef','3156060606',2800000.00),(19,'Sara','Zapata','Repostera','3167070707',2400000.00),(20,'Mateo','Quintero','Mesero','3178080808',1600000.00);
/*!40000 ALTER TABLE `empleado` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gasto`
--

DROP TABLE IF EXISTS `gasto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gasto` (
  `id_gasto` int NOT NULL AUTO_INCREMENT,
  `id_empleado` int NOT NULL,
  `descripcion` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `metodo_pago` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `valor` decimal(12,2) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_gasto`),
  KEY `fk_gasto_empleado` (`id_empleado`),
  CONSTRAINT `fk_gasto_empleado` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gasto`
--

LOCK TABLES `gasto` WRITE;
/*!40000 ALTER TABLE `gasto` DISABLE KEYS */;
INSERT INTO `gasto` VALUES (1,1,'Compra de fresas frescas del día','Efectivo',45000.00,'2026-09-15 08:00:00'),(2,2,'Reparación de batidora industrial','Transferencia',180000.00,'2026-09-16 10:30:00'),(3,8,'Domicilios del día','Efectivo',25000.00,'2026-09-16 18:00:00'),(4,5,'Publicidad en redes sociales','Tarjeta',120000.00,'2026-09-17 09:00:00'),(5,3,'Insumos de aseo','Efectivo',38000.00,'2026-09-17 15:00:00'),(6,10,'Mantenimiento de nevera exhibidora','Transferencia',250000.00,'2026-09-18 11:00:00'),(7,1,'Compra de empaques para domicilio','Efectivo',85000.00,'2026-09-19 08:30:00'),(8,4,'Transporte de insumos','Efectivo',30000.00,'2026-09-19 14:00:00'),(9,2,'Servicio de gas','Transferencia',95000.00,'2026-09-20 10:00:00'),(10,8,'Domicilios del día','Efectivo',22000.00,'2026-09-20 18:00:00'),(11,5,'Uniformes nuevos para el personal','Tarjeta',350000.00,'2026-09-21 09:30:00'),(12,7,'Mantenimiento de vitrina','Transferencia',150000.00,'2026-09-21 11:00:00'),(13,3,'Insumos de cocina (utensilios)','Efectivo',62000.00,'2026-09-22 10:00:00'),(14,10,'Reparación de horno','Transferencia',320000.00,'2026-09-23 08:00:00'),(15,1,'Compra de fresas para la semana','Efectivo',95000.00,'2026-09-24 07:30:00'),(16,18,'Publicidad en radio local','Transferencia',200000.00,'2026-09-24 16:00:00'),(17,4,'Domicilios del día','Efectivo',28000.00,'2026-09-25 18:00:00'),(18,2,'Mantenimiento de licuadora','Efectivo',45000.00,'2026-09-26 10:00:00'),(19,5,'Papelería y facturación','Efectivo',32000.00,'2026-09-26 14:00:00'),(20,3,'Productos de limpieza','Efectivo',41000.00,'2026-09-27 09:00:00'),(21,10,'Servicio de internet','Transferencia',120000.00,'2026-09-27 11:00:00'),(22,7,'Reparación de vitrina exhibidora','Transferencia',180000.00,'2026-09-28 09:00:00'),(23,8,'Domicilios del día','Efectivo',24000.00,'2026-09-28 18:00:00'),(24,1,'Compra de insumos para recetas','Efectivo',150000.00,'2026-09-29 08:00:00'),(25,5,'Publicidad en Instagram','Tarjeta',80000.00,'2026-09-29 10:00:00'),(26,4,'Transporte de personal','Efectivo',35000.00,'2026-09-30 07:00:00'),(27,18,'Mantenimiento de computador','Transferencia',95000.00,'2026-09-30 15:00:00'),(28,3,'Insumos de cafetería','Efectivo',55000.00,'2026-10-01 09:00:00'),(29,2,'Reparación de mesas','Efectivo',75000.00,'2026-10-02 11:00:00'),(30,10,'Servicio de agua','Transferencia',85000.00,'2026-10-03 10:00:00');
/*!40000 ALTER TABLE `gasto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `insumo`
--

DROP TABLE IF EXISTS `insumo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `insumo` (
  `id_insumo` int NOT NULL AUTO_INCREMENT,
  `id_proveedor` int DEFAULT NULL,
  `nombre_insumo` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `und_medida` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cantidadDisp` decimal(12,2) DEFAULT '0.00',
  `stock` decimal(12,2) DEFAULT '0.00',
  `costo_und` decimal(12,2) DEFAULT '0.00',
  `fecha_venc` date DEFAULT NULL,
  PRIMARY KEY (`id_insumo`),
  KEY `fk_insumo_proveedor` (`id_proveedor`),
  CONSTRAINT `fk_insumo_proveedor` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `insumo`
--

LOCK TABLES `insumo` WRITE;
/*!40000 ALTER TABLE `insumo` DISABLE KEYS */;
INSERT INTO `insumo` VALUES (1,1,'Leche entera','ml',20000.00,5000.00,3.50,'2025-11-15'),(2,1,'Crema de leche','ml',10000.00,3000.00,7.20,'2025-11-20'),(3,1,'Leche condensada','ml',8000.00,2500.00,6.00,'2026-05-20'),(4,4,'Claras de huevo','g',15000.00,4000.00,8.00,'2025-11-10'),(5,4,'Huevos enteros','und',500.00,200.00,500.00,'2025-11-08'),(6,5,'Azúcar','g',25000.00,8000.00,2.50,'2026-12-01'),(7,5,'Azúcar glass','g',10000.00,3000.00,4.80,'2026-10-15'),(8,5,'Harina de trigo','g',20000.00,6000.00,2.20,'2026-06-30'),(9,5,'Maicena','g',8000.00,2500.00,3.90,'2026-08-10'),(10,8,'Chocolate en polvo','g',6000.00,2000.00,15.00,'2026-03-10'),(11,8,'Cacao amargo','g',5000.00,1500.00,22.00,'2026-04-05'),(12,3,'Fresas frescas','g',10000.00,3000.00,12.00,'2025-11-12'),(13,11,'Maracuyá','g',7000.00,2000.00,9.00,'2025-11-25'),(14,11,'Mango de azúcar','g',6000.00,1800.00,7.00,'2025-11-28'),(15,3,'Guanábana','g',5000.00,1500.00,11.00,'2025-12-05'),(16,3,'Mora','g',4000.00,1200.00,10.00,'2025-11-18'),(17,7,'Vainilla','ml',1000.00,300.00,18.00,'2026-08-15'),(18,1,'Mantequilla','g',8000.00,2500.00,25.00,'2025-12-20'),(19,1,'Queso crema','g',5000.00,1500.00,14.00,'2025-11-30'),(20,6,'Galletas base','g',6000.00,2000.00,8.50,'2026-03-15'),(21,9,'Panela','g',10000.00,3000.00,4.00,'2026-09-01'),(22,1,'Leche en polvo','g',5000.00,1500.00,12.50,'2026-07-10'),(23,9,'Canela en polvo','g',1000.00,400.00,25.00,'2026-11-20'),(24,3,'Coco rallado','g',3000.00,1000.00,9.00,'2026-02-28'),(25,12,'Gelatina sin sabor','g',2000.00,800.00,30.00,'2026-10-05');
/*!40000 ALTER TABLE `insumo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pago`
--

DROP TABLE IF EXISTS `pago`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pago` (
  `id_pago` int NOT NULL AUTO_INCREMENT,
  `id_venta` int NOT NULL,
  `fecha_pago` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `metodo_pago` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `valor` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id_pago`),
  KEY `fk_pago_venta` (`id_venta`),
  CONSTRAINT `fk_pago_venta` FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pago`
--

LOCK TABLES `pago` WRITE;
/*!40000 ALTER TABLE `pago` DISABLE KEYS */;
INSERT INTO `pago` VALUES (1,1,'2026-10-05 22:10:03','Efectivo',23800.00),(2,2,'2026-10-05 22:10:03','Tarjeta',14875.00),(3,3,'2026-10-05 22:10:03','Transferencia',40460.00),(4,4,'2026-10-05 22:10:03','Efectivo',26180.00),(5,5,'2026-10-05 22:10:03','Tarjeta',21420.00),(6,6,'2026-10-05 22:10:03','Efectivo',29750.00),(7,7,'2026-10-05 22:10:03','Transferencia',15470.00),(8,8,'2026-10-05 22:10:03','Tarjeta',35700.00),(9,9,'2026-10-05 22:10:03','Efectivo',17850.00),(10,10,'2026-10-05 22:10:03','Tarjeta',32130.00),(11,11,'2026-10-05 22:10:03','Efectivo',23205.00),(12,12,'2026-10-05 22:10:03','Transferencia',28560.00),(13,13,'2026-10-05 22:10:03','Efectivo',19040.00),(14,14,'2026-10-05 22:10:03','Tarjeta',41650.00),(15,15,'2026-10-05 22:10:03','Efectivo',26180.00),(16,16,'2026-10-05 22:10:03','Transferencia',16660.00),(17,17,'2026-10-05 22:10:03','Tarjeta',32130.00),(18,18,'2026-10-05 22:10:03','Efectivo',21420.00),(19,19,'2026-10-05 22:10:03','Tarjeta',38080.00),(20,20,'2026-10-05 22:10:03','Transferencia',24990.00),(21,21,'2026-10-05 22:10:03','Efectivo',18445.00),(22,22,'2026-10-05 22:10:03','Tarjeta',30940.00),(23,23,'2026-10-05 22:10:03','Efectivo',22015.00),(24,24,'2026-10-05 22:10:03','Transferencia',36890.00),(25,25,'2026-10-05 22:10:03','Efectivo',20825.00),(26,26,'2026-10-05 22:10:03','Tarjeta',33320.00),(27,27,'2026-10-05 22:10:03','Efectivo',27370.00),(28,28,'2026-10-05 22:10:03','Transferencia',19635.00),(29,29,'2026-10-05 22:10:03','Tarjeta',40460.00),(30,30,'2026-10-05 22:10:03','Efectivo',23800.00),(31,31,'2026-10-05 22:10:03','Transferencia',32725.00),(32,32,'2026-10-05 22:10:03','Efectivo',17255.00),(33,33,'2026-10-05 22:10:03','Tarjeta',36890.00),(34,34,'2026-10-05 22:10:03','Efectivo',23800.00),(35,35,'2026-10-05 22:10:03','Transferencia',29155.00),(36,36,'2026-10-05 22:10:03','Tarjeta',20230.00),(37,37,'2026-10-05 22:10:03','Efectivo',35105.00),(38,38,'2026-10-05 22:10:03','Tarjeta',21420.00),(39,39,'2026-10-05 22:10:03','Transferencia',42840.00),(40,40,'2026-10-05 22:10:03','Efectivo',24990.00);
/*!40000 ALTER TABLE `pago` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `producto`
--

DROP TABLE IF EXISTS `producto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `producto` (
  `id_producto` int NOT NULL AUTO_INCREMENT,
  `id_proveedor` int DEFAULT NULL,
  `nombre_prod` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `precio_venta` decimal(12,2) NOT NULL,
  `estado` enum('Activo','Inactivo') COLLATE utf8mb4_unicode_ci DEFAULT 'Activo',
  PRIMARY KEY (`id_producto`),
  KEY `fk_producto_proveedor` (`id_proveedor`),
  CONSTRAINT `fk_producto_proveedor` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `producto`
--

LOCK TABLES `producto` WRITE;
/*!40000 ALTER TABLE `producto` DISABLE KEYS */;
INSERT INTO `producto` VALUES (1,2,'Merengón clásico','Merengón tradicional con crema chantilly',10000.00,'Activo'),(2,3,'Merengón de fresa','Merengón con fresas frescas y crema',12000.00,'Activo'),(3,8,'Merengón de chocolate','Merengón con crema de chocolate amargo',13000.00,'Activo'),(4,3,'Merengón de maracuyá','Merengón con salsa natural de maracuyá',12500.00,'Activo'),(5,3,'Merengón de guanábana','Merengón con pulpa de guanábana',13500.00,'Activo'),(6,3,'Fresas con crema','Postre de fresas con crema chantilly',11000.00,'Activo'),(7,3,'Maracumango','Merengón con maracuyá y mango',13500.00,'Activo'),(8,2,'Oblea rellena','Oblea artesanal con arequipe',6000.00,'Activo'),(9,10,'Cuajada con melado','Cuajada fresca con melado de panela',8000.00,'Activo'),(10,10,'Postre de natas','Postre tradicional de natas con melado',9000.00,'Activo'),(11,1,'Arroz con leche','Arroz con leche y canela',7500.00,'Activo'),(12,1,'Flan de caramelo','Flan casero con caramelo',8500.00,'Activo'),(13,8,'Torta de chocolate','Porción de torta húmeda de chocolate',9500.00,'Activo'),(14,1,'Tres leches','Porción de torta tres leches',10500.00,'Activo'),(15,3,'Cheesecake de maracuyá','Cheesecake con salsa de maracuyá',12500.00,'Activo'),(16,8,'Brownie con helado','Brownie caliente con helado de vainilla',12000.00,'Activo'),(17,11,'Mazamorra','Mazamorra con panela y maíz',7000.00,'Activo'),(18,11,'Salpicón de frutas','Salpicón con frutas de temporada',9000.00,'Activo'),(19,11,'Ensalada de frutas','Ensalada de frutas con crema',9500.00,'Activo'),(20,10,'Gelatina de pata','Gelatina de pata tradicional',6500.00,'Activo');
/*!40000 ALTER TABLE `producto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proveedor`
--

DROP TABLE IF EXISTS `proveedor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `proveedor` (
  `id_proveedor` int NOT NULL AUTO_INCREMENT,
  `nombre_prov` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `direccion` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_proveedor`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedor`
--

LOCK TABLES `proveedor` WRITE;
/*!40000 ALTER TABLE `proveedor` DISABLE KEYS */;
INSERT INTO `proveedor` VALUES (1,'Lácteos del Valle SAS','Av. Sur #45-10, Bogotá','6019876543'),(2,'Distribuidora Dulces del Trópico','Cra 50 #12-45, Medellín','6043334444'),(3,'Frutas Frescas del Campo','Km 5 Vía La Calera, Bogotá','6011112222'),(4,'Huevos y Más','Calle 80 #45-67, Bogotá','6015556666'),(5,'Harinas y Cereales de Colombia','Zona Industrial Bodega 7, Cali','6029990000'),(6,'Empaques y Desechables La 14','Cra 14 #20-30, Bogotá','6012345678'),(7,'Café de Origen','Manzana 3, Salento, Quindío','6067778888'),(8,'Chocolates Nacionales','Cra 43 #18-11, Medellín','6043339999'),(9,'Distribuidora La Cosecha','Calle 13 #23-33, Bogotá','6013330000'),(10,'Lácteos La Pradera','Vía Ubaté-Chiquinquirá Km 8','6018887777'),(11,'Frutas del Eje Cafetero','Av. Bolívar #22-10, Pereira','6064445555'),(12,'Insumos Repostería Gourmet','Cra 7 #45-89, Bogotá','6012221111');
/*!40000 ALTER TABLE `proveedor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `receta`
--

DROP TABLE IF EXISTS `receta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `receta` (
  `id_receta` int NOT NULL AUTO_INCREMENT,
  `id_producto` int NOT NULL,
  `und_medida` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cantidad_insumo` decimal(12,2) DEFAULT NULL,
  `costo_insumo` decimal(12,2) DEFAULT NULL,
  PRIMARY KEY (`id_receta`),
  UNIQUE KEY `id_producto` (`id_producto`),
  CONSTRAINT `fk_receta_producto` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `receta`
--

LOCK TABLES `receta` WRITE;
/*!40000 ALTER TABLE `receta` DISABLE KEYS */;
INSERT INTO `receta` VALUES (1,1,'g',150.00,1200.00),(2,2,'g',180.00,1500.00),(3,3,'g',170.00,1900.00),(4,4,'g',160.00,1600.00),(5,5,'g',165.00,1750.00),(6,6,'g',180.00,1700.00),(7,7,'g',175.00,1850.00),(8,8,'g',100.00,900.00),(9,9,'g',140.00,1100.00),(10,10,'g',150.00,1300.00),(11,11,'g',130.00,950.00),(12,12,'g',140.00,1050.00),(13,13,'g',120.00,1500.00),(14,14,'g',160.00,1350.00),(15,15,'g',150.00,1800.00),(16,16,'g',130.00,1600.00),(17,17,'g',140.00,850.00),(18,18,'g',160.00,1000.00),(19,19,'g',170.00,1100.00),(20,20,'g',130.00,780.00);
/*!40000 ALTER TABLE `receta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `receta_insumo`
--

DROP TABLE IF EXISTS `receta_insumo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `receta_insumo` (
  `id_receta` int NOT NULL,
  `id_insumo` int NOT NULL,
  `cantidad` decimal(12,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id_receta`,`id_insumo`),
  KEY `fk_ri_insumo` (`id_insumo`),
  CONSTRAINT `fk_ri_insumo` FOREIGN KEY (`id_insumo`) REFERENCES `insumo` (`id_insumo`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ri_receta` FOREIGN KEY (`id_receta`) REFERENCES `receta` (`id_receta`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `receta_insumo`
--

LOCK TABLES `receta_insumo` WRITE;
/*!40000 ALTER TABLE `receta_insumo` DISABLE KEYS */;
INSERT INTO `receta_insumo` VALUES (1,2,80.00),(1,4,100.00),(1,6,120.00),(1,17,15.00),(2,2,80.00),(2,4,100.00),(2,6,120.00),(2,12,80.00),(3,2,80.00),(3,4,100.00),(3,6,120.00),(3,10,50.00),(4,2,80.00),(4,4,100.00),(4,6,120.00),(4,13,60.00),(5,2,80.00),(5,4,100.00),(5,6,120.00),(5,15,70.00),(6,2,150.00),(6,6,80.00),(6,12,100.00),(6,17,10.00),(7,2,80.00),(7,4,100.00),(7,6,120.00),(7,13,50.00),(7,14,50.00),(8,8,80.00),(8,9,40.00),(8,17,10.00),(9,1,200.00),(9,3,80.00),(9,21,100.00),(10,1,250.00),(10,21,80.00),(10,23,5.00),(11,1,300.00),(11,6,100.00),(11,22,20.00),(11,23,5.00),(12,1,200.00),(12,5,60.00),(12,6,100.00),(12,17,10.00),(13,5,80.00),(13,7,120.00),(13,10,40.00),(13,18,60.00),(13,20,30.00),(14,1,150.00),(14,2,80.00),(14,3,100.00),(14,7,100.00),(15,6,80.00),(15,13,60.00),(15,19,150.00),(15,20,50.00),(16,7,60.00),(16,10,80.00),(16,17,30.00),(16,18,80.00),(17,1,200.00),(17,21,100.00),(17,23,5.00),(18,6,60.00),(18,11,80.00),(18,14,80.00),(18,16,60.00),(19,2,60.00),(19,11,80.00),(19,12,60.00),(19,14,80.00),(20,1,200.00),(20,6,80.00),(20,24,30.00),(20,25,20.00);
/*!40000 ALTER TABLE `receta_insumo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `venta`
--

DROP TABLE IF EXISTS `venta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `venta` (
  `id_venta` int NOT NULL AUTO_INCREMENT,
  `id_cliente` int NOT NULL,
  `id_empleado` int NOT NULL,
  `fecha_venta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `subtotal` decimal(12,2) DEFAULT '0.00',
  `descuento` decimal(12,2) DEFAULT '0.00',
  `impuesto` decimal(12,2) DEFAULT '0.00',
  `total_venta` decimal(12,2) DEFAULT '0.00',
  `metodo` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado` enum('Pagada','Pendiente','Anulada') COLLATE utf8mb4_unicode_ci DEFAULT 'Pendiente',
  PRIMARY KEY (`id_venta`),
  KEY `fk_venta_cliente` (`id_cliente`),
  KEY `fk_venta_empleado` (`id_empleado`),
  CONSTRAINT `fk_venta_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`) ON UPDATE CASCADE,
  CONSTRAINT `fk_venta_empleado` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venta`
--

LOCK TABLES `venta` WRITE;
/*!40000 ALTER TABLE `venta` DISABLE KEYS */;
INSERT INTO `venta` VALUES (1,1,4,'2026-09-28 10:15:00',20000.00,0.00,3800.00,23800.00,'Efectivo','Pagada'),(2,2,4,'2026-09-28 11:30:00',12500.00,0.00,2375.00,14875.00,'Tarjeta','Pagada'),(3,3,5,'2026-09-28 12:45:00',35000.00,1000.00,6460.00,40460.00,'Transferencia','Pagada'),(4,4,6,'2026-09-28 14:00:00',22000.00,0.00,4180.00,26180.00,'Efectivo','Pagada'),(5,5,9,'2026-09-28 15:30:00',18500.00,500.00,3420.00,21420.00,'Tarjeta','Pagada'),(6,6,14,'2026-09-28 16:45:00',25000.00,0.00,4750.00,29750.00,'Efectivo','Pagada'),(7,7,20,'2026-09-28 17:20:00',13000.00,0.00,2470.00,15470.00,'Transferencia','Pagada'),(8,8,4,'2026-09-29 09:00:00',30000.00,0.00,5700.00,35700.00,'Tarjeta','Pagada'),(9,9,6,'2026-09-29 10:20:00',15000.00,0.00,2850.00,17850.00,'Efectivo','Pagada'),(10,10,9,'2026-09-29 11:45:00',28000.00,1000.00,5130.00,32130.00,'Tarjeta','Pagada'),(11,11,14,'2026-09-29 12:30:00',19500.00,0.00,3705.00,23205.00,'Efectivo','Pagada'),(12,12,20,'2026-09-29 13:15:00',24000.00,0.00,4560.00,28560.00,'Transferencia','Pagada'),(13,13,4,'2026-09-29 14:50:00',16000.00,0.00,3040.00,19040.00,'Efectivo','Pagada'),(14,14,5,'2026-09-29 15:30:00',35000.00,0.00,6650.00,41650.00,'Tarjeta','Pendiente'),(15,15,6,'2026-09-29 16:00:00',22500.00,500.00,4180.00,26180.00,'Efectivo','Pagada'),(16,16,9,'2026-09-29 16:40:00',14000.00,0.00,2660.00,16660.00,'Transferencia','Pagada'),(17,17,14,'2026-09-30 09:30:00',27000.00,0.00,5130.00,32130.00,'Tarjeta','Pagada'),(18,18,20,'2026-09-30 10:15:00',18000.00,0.00,3420.00,21420.00,'Efectivo','Pagada'),(19,19,4,'2026-09-30 11:00:00',33000.00,1000.00,6080.00,38080.00,'Tarjeta','Pagada'),(20,20,5,'2026-09-30 12:30:00',21000.00,0.00,3990.00,24990.00,'Transferencia','Pagada'),(21,21,6,'2026-09-30 13:45:00',15500.00,0.00,2945.00,18445.00,'Efectivo','Pagada'),(22,22,9,'2026-09-30 15:00:00',26000.00,0.00,4940.00,30940.00,'Tarjeta','Pendiente'),(23,23,14,'2026-09-30 16:20:00',19000.00,500.00,3515.00,22015.00,'Efectivo','Pagada'),(24,24,20,'2026-10-01 09:15:00',31000.00,0.00,5890.00,36890.00,'Transferencia','Pagada'),(25,25,4,'2026-10-01 10:30:00',17500.00,0.00,3325.00,20825.00,'Efectivo','Pagada'),(26,26,5,'2026-10-01 11:45:00',29000.00,1000.00,5320.00,33320.00,'Tarjeta','Pagada'),(27,27,6,'2026-10-01 13:00:00',23000.00,0.00,4370.00,27370.00,'Efectivo','Pagada'),(28,28,9,'2026-10-01 14:15:00',16500.00,0.00,3135.00,19635.00,'Transferencia','Pagada'),(29,29,14,'2026-10-01 15:30:00',34000.00,0.00,6460.00,40460.00,'Tarjeta','Pagada'),(30,30,20,'2026-10-01 16:45:00',20500.00,500.00,3800.00,23800.00,'Efectivo','Pagada'),(31,31,4,'2026-10-02 09:00:00',27500.00,0.00,5225.00,32725.00,'Transferencia','Pagada'),(32,32,5,'2026-10-02 10:20:00',14500.00,0.00,2755.00,17255.00,'Efectivo','Pagada'),(33,33,6,'2026-10-02 11:40:00',32000.00,1000.00,5890.00,36890.00,'Tarjeta','Pagada'),(34,34,9,'2026-10-02 13:00:00',20000.00,0.00,3800.00,23800.00,'Efectivo','Pagada'),(35,35,14,'2026-10-02 14:30:00',24500.00,0.00,4655.00,29155.00,'Transferencia','Pendiente'),(36,36,20,'2026-10-02 15:45:00',17000.00,0.00,3230.00,20230.00,'Tarjeta','Pagada'),(37,37,4,'2026-10-03 09:30:00',29500.00,0.00,5605.00,35105.00,'Efectivo','Pagada'),(38,38,5,'2026-10-03 10:50:00',18500.00,500.00,3420.00,21420.00,'Tarjeta','Pagada'),(39,39,6,'2026-10-03 12:10:00',36000.00,0.00,6840.00,42840.00,'Transferencia','Pagada'),(40,40,9,'2026-10-03 13:30:00',21000.00,0.00,3990.00,24990.00,'Efectivo','Pagada');
/*!40000 ALTER TABLE `venta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vista_mejor_insumo_proveedor`
--

DROP TABLE IF EXISTS `vista_mejor_insumo_proveedor`;
/*!50001 DROP VIEW IF EXISTS `vista_mejor_insumo_proveedor`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vista_mejor_insumo_proveedor` AS SELECT 
 1 AS `id_proveedor`,
 1 AS `nombre_prov`,
 1 AS `id_insumo`,
 1 AS `nombre_insumo`,
 1 AS `costo_und`,
 1 AS `total_comprado`,
 1 AS `total_gastado`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vista_stock_insumo`
--

DROP TABLE IF EXISTS `vista_stock_insumo`;
/*!50001 DROP VIEW IF EXISTS `vista_stock_insumo`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vista_stock_insumo` AS SELECT 
 1 AS `id_insumo`,
 1 AS `nombre_insumo`,
 1 AS `und_medida`,
 1 AS `stock_inicial`,
 1 AS `entradas_compras`,
 1 AS `salidas_por_ventas`,
 1 AS `stock_actual`,
 1 AS `costo_und`,
 1 AS `valor_inventario`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vista_mejor_insumo_proveedor`
--

/*!50001 DROP VIEW IF EXISTS `vista_mejor_insumo_proveedor`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vista_mejor_insumo_proveedor` AS select `p`.`id_proveedor` AS `id_proveedor`,`p`.`nombre_prov` AS `nombre_prov`,`i`.`id_insumo` AS `id_insumo`,`i`.`nombre_insumo` AS `nombre_insumo`,`i`.`costo_und` AS `costo_und`,ifnull(sum(`dc`.`cantidad`),0) AS `total_comprado`,ifnull(sum(`dc`.`subtotal`),0) AS `total_gastado` from (((`proveedor` `p` join `insumo` `i` on((`i`.`id_proveedor` = `p`.`id_proveedor`))) left join `detalle_compra` `dc` on((`dc`.`id_insumo` = `i`.`id_insumo`))) left join `compra` `c` on(((`c`.`id_compra` = `dc`.`id_compra`) and (`c`.`id_proveedor` = `p`.`id_proveedor`)))) group by `p`.`id_proveedor`,`p`.`nombre_prov`,`i`.`id_insumo`,`i`.`nombre_insumo`,`i`.`costo_und` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vista_stock_insumo`
--

/*!50001 DROP VIEW IF EXISTS `vista_stock_insumo`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vista_stock_insumo` AS select `i`.`id_insumo` AS `id_insumo`,`i`.`nombre_insumo` AS `nombre_insumo`,`i`.`und_medida` AS `und_medida`,`i`.`stock` AS `stock_inicial`,ifnull(`ent`.`total_entradas`,0) AS `entradas_compras`,ifnull(`sal`.`total_salidas`,0) AS `salidas_por_ventas`,((`i`.`stock` + ifnull(`ent`.`total_entradas`,0)) - ifnull(`sal`.`total_salidas`,0)) AS `stock_actual`,`i`.`costo_und` AS `costo_und`,(((`i`.`stock` + ifnull(`ent`.`total_entradas`,0)) - ifnull(`sal`.`total_salidas`,0)) * `i`.`costo_und`) AS `valor_inventario` from ((`insumo` `i` left join (select `detalle_compra`.`id_insumo` AS `id_insumo`,sum(`detalle_compra`.`cantidad`) AS `total_entradas` from `detalle_compra` group by `detalle_compra`.`id_insumo`) `ent` on((`ent`.`id_insumo` = `i`.`id_insumo`))) left join (select `ri`.`id_insumo` AS `id_insumo`,sum((`ri`.`cantidad` * `dv`.`cantidad`)) AS `total_salidas` from ((`receta_insumo` `ri` join `receta` `r` on((`r`.`id_receta` = `ri`.`id_receta`))) join `detalle_venta` `dv` on((`dv`.`id_producto` = `r`.`id_producto`))) group by `ri`.`id_insumo`) `sal` on((`sal`.`id_insumo` = `i`.`id_insumo`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-05 22:11:39
