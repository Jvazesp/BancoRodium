CREATE DATABASE `bancorodium` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

CREATE TABLE `cliente` (
  `id_cliente` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `Apellidos` varchar(60) DEFAULT NULL,
  `telefono` int DEFAULT NULL,
  `nºempleado` int DEFAULT NULL,
  PRIMARY KEY (`id_cliente`),
  KEY `cliente_FK` (`nºempleado`),
  CONSTRAINT `cliente_FK` FOREIGN KEY (`nºempleado`) REFERENCES `empleado` (`nºEmpleado`)
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `cuenta` (
  `nºcuenta` int NOT NULL AUTO_INCREMENT,
  `id_cliente` int DEFAULT NULL,
  `Saldo` int DEFAULT NULL,
  PRIMARY KEY (`nºcuenta`),
  KEY `cuenta_FK_2` (`id_cliente`),
  CONSTRAINT `cuenta_FK_2` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`)
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `empleado` (
  `nºEmpleado` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `apellidos` varchar(60) DEFAULT NULL,
  `es_jefe` int DEFAULT NULL,
  PRIMARY KEY (`nºEmpleado`),
  KEY `empleado_FK` (`es_jefe`),
  CONSTRAINT `empleado_FK` FOREIGN KEY (`es_jefe`) REFERENCES `empleado` (`nºEmpleado`)
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `historial_prestamo` (
  `id_cliente` int NOT NULL,
  `plazo` date DEFAULT NULL,
  `id_prestamo` int NOT NULL,
  `cantidad` int DEFAULT NULL,
  `fecha` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `historial_transacciones` (
  `codigo_cuenta_paga` int NOT NULL,
  `fecha_pago` datetime DEFAULT NULL,
  `total` int DEFAULT NULL,
  `codigo_cuenta_recibe` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `prestamo` (
  `id_prestamo` int NOT NULL AUTO_INCREMENT,
  `id_cliente` int DEFAULT NULL,
  `plazo` date DEFAULT NULL,
  `cantidad` int NOT NULL,
  PRIMARY KEY (`id_prestamo`),
  KEY `prestamo_FK` (`id_cliente`),
  CONSTRAINT `prestamo_FK` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`)
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `transaccion` (
  `codigo_cuenta_paga` int NOT NULL,
  `fecha_pago` datetime DEFAULT NULL,
  `total` int DEFAULT NULL,
  `cod_cuenta_destino` int NOT NULL,
  `id_transaccion` int NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id_transaccion`),
  KEY `transaccion_FK` (`codigo_cuenta_paga`),
  KEY `transaccion_FK_1` (`cod_cuenta_destino`),
  CONSTRAINT `transaccion_FK` FOREIGN KEY (`codigo_cuenta_paga`) REFERENCES `cuenta` (`nºcuenta`),
  CONSTRAINT `transaccion_FK_1` FOREIGN KEY (`cod_cuenta_destino`) REFERENCES `cuenta` (`nºcuenta`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
