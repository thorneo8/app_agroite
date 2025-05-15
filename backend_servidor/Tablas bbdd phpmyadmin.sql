-- Script para crear las tablas de la base de datos

-- Tabla empresas
CREATE TABLE IF NOT EXISTS `empresas` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `nombre` VARCHAR(255) NOT NULL,
  `razon_social` VARCHAR(255) NOT NULL,
  `cif` VARCHAR(50) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla tecnicos
CREATE TABLE IF NOT EXISTS `tecnicos` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `empresa_id` INT NOT NULL,
  `nombre_apellido` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `telefono` VARCHAR(20) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  FOREIGN KEY (`empresa_id`) REFERENCES `empresas`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla clientes
CREATE TABLE IF NOT EXISTS `clientes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `empresa_id` INT NOT NULL,
  `tecnico_id` INT NOT NULL,
  `nombre_apellido` VARCHAR(255) NOT NULL,
  `telefono` VARCHAR(20) NOT NULL,
  `email` VARCHAR(255) NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `ubicacion` VARCHAR(255) NULL,
  FOREIGN KEY (`empresa_id`) REFERENCES `empresas`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`tecnico_id`) REFERENCES `tecnicos`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla fincas
CREATE TABLE IF NOT EXISTS `fincas` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `cliente_id` INT NOT NULL,
  `nombre` VARCHAR(255) NOT NULL,
  FOREIGN KEY (`cliente_id`) REFERENCES `clientes`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla parcelas
CREATE TABLE IF NOT EXISTS `parcelas` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `finca_id` INT NOT NULL,
  `nombre` VARCHAR(255) NOT NULL,
  FOREIGN KEY (`finca_id`) REFERENCES `fincas`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla cultivos
CREATE TABLE IF NOT EXISTS `cultivos` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `nombre` VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla variedades
CREATE TABLE IF NOT EXISTS `variedades` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `cultivo_id` INT NOT NULL,
  `nombre` VARCHAR(255) NOT NULL,
  FOREIGN KEY (`cultivo_id`) REFERENCES `cultivos`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Supremo

CREATE TABLE IF NOT EXISTS `admin_supremo` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(255) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Usuario por defecto con contraseña encriptada (SHA-256)
INSERT INTO `admin_supremo` (`username`, `password_hash`)
VALUES ('supremo', 'd5df8e1b1b845a70d820ee4da8db36805b97d2519d8cb12c325a4e497d18237b');

