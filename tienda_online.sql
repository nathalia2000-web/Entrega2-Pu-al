-- ============================================================
-- BASE DE DATOS: TIENDA EN LÍNEA
-- Motor: MySQL 8.0+
-- Autor: [Natalia Puñalter]
-- Fecha: 2026
-- Descripción: Sistema de gestión de e-commerce completo
-- ============================================================

-- Eliminar y crear la base de datos
DROP DATABASE IF EXISTS tienda_online;
CREATE DATABASE tienda_online
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE tienda_online;

-- ============================================================
-- TABLA 1: categorias
-- ============================================================
CREATE TABLE categorias (
  cat_id            INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  cat_nombre        VARCHAR(100)     NOT NULL,
  cat_descripcion   TEXT             NULL,
  cat_activa        TINYINT(1)       NOT NULL DEFAULT 1,
  cat_fecha_creacion DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_categorias PRIMARY KEY (cat_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLA 2: productos
-- ============================================================
CREATE TABLE productos (
  prod_id             INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  cat_id              INT UNSIGNED     NOT NULL,
  prod_nombre         VARCHAR(150)     NOT NULL,
  prod_descripcion    TEXT             NULL,
  prod_precio         DECIMAL(10,2)    NOT NULL,
  prod_imagen         VARCHAR(255)     NULL,
  prod_activo         TINYINT(1)       NOT NULL DEFAULT 1,
  prod_fecha_registro DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_productos  PRIMARY KEY (prod_id),
  CONSTRAINT fk_prod_cat   FOREIGN KEY (cat_id)
    REFERENCES categorias(cat_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  INDEX idx_prod_categoria (cat_id),
  INDEX idx_prod_nombre    (prod_nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLA 3: inventario
-- ============================================================
CREATE TABLE inventario (
  inv_id                   INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  prod_id                  INT UNSIGNED  NOT NULL,
  inv_stock                INT UNSIGNED  NOT NULL DEFAULT 0,
  inv_stock_minimo         INT UNSIGNED  NOT NULL DEFAULT 5,
  inv_ultima_actualizacion DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
                                         ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT pk_inventario  PRIMARY KEY (inv_id),
  CONSTRAINT uq_inv_prod    UNIQUE (prod_id),
  CONSTRAINT fk_inv_prod    FOREIGN KEY (prod_id)
    REFERENCES productos(prod_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLA 4: clientes
-- ============================================================
CREATE TABLE clientes (
  cli_id             INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  cli_nombre         VARCHAR(100)   NOT NULL,
  cli_apellido       VARCHAR(100)   NOT NULL,
  cli_email          VARCHAR(150)   NOT NULL,
  cli_telefono       VARCHAR(20)    NULL,
  cli_password       VARCHAR(255)   NOT NULL,
  cli_activo         TINYINT(1)     NOT NULL DEFAULT 1,
  cli_fecha_registro DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_clientes    PRIMARY KEY (cli_id),
  CONSTRAINT uq_cli_email   UNIQUE (cli_email),
  INDEX idx_cli_email (cli_email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLA 5: direcciones
-- ============================================================
CREATE TABLE direcciones (
  dir_id              INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  cli_id              INT UNSIGNED   NOT NULL,
  dir_calle           VARCHAR(200)   NOT NULL,
  dir_ciudad          VARCHAR(100)   NOT NULL,
  dir_estado          VARCHAR(100)   NOT NULL,
  dir_codigo_postal   VARCHAR(10)    NOT NULL,
  dir_pais            VARCHAR(80)    NOT NULL,
  dir_predeterminada  TINYINT(1)     NOT NULL DEFAULT 0,
  CONSTRAINT pk_direcciones PRIMARY KEY (dir_id),
  CONSTRAINT fk_dir_cli     FOREIGN KEY (cli_id)
    REFERENCES clientes(cli_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  INDEX idx_dir_cliente (cli_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLA 6: pedidos
-- ============================================================
CREATE TABLE pedidos (
  ped_id     INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  cli_id     INT UNSIGNED    NOT NULL,
  dir_id     INT UNSIGNED    NOT NULL,
  ped_fecha  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ped_estado ENUM(
               'pendiente',
               'procesando',
               'enviado',
               'entregado',
               'cancelado'
             )               NOT NULL DEFAULT 'pendiente',
  ped_total  DECIMAL(10,2)   NOT NULL,
  ped_notas  TEXT            NULL,
  CONSTRAINT pk_pedidos     PRIMARY KEY (ped_id),
  CONSTRAINT fk_ped_cli     FOREIGN KEY (cli_id)
    REFERENCES clientes(cli_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_ped_dir     FOREIGN KEY (dir_id)
    REFERENCES direcciones(dir_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  INDEX idx_ped_cliente (cli_id),
  INDEX idx_ped_estado  (ped_estado),
  INDEX idx_ped_fecha   (ped_fecha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLA 7: detalle_pedidos
-- ============================================================
CREATE TABLE detalle_pedidos (
  det_id              INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  ped_id              INT UNSIGNED   NOT NULL,
  prod_id             INT UNSIGNED   NOT NULL,
  det_cantidad        INT UNSIGNED   NOT NULL,
  det_precio_unitario DECIMAL(10,2)  NOT NULL,
  det_subtotal        DECIMAL(10,2)  NOT NULL,
  CONSTRAINT pk_detalle      PRIMARY KEY (det_id),
  CONSTRAINT fk_det_pedido   FOREIGN KEY (ped_id)
    REFERENCES pedidos(ped_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_det_producto FOREIGN KEY (prod_id)
    REFERENCES productos(prod_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  INDEX idx_det_pedido   (ped_id),
  INDEX idx_det_producto (prod_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLA 8: metodos_pago
-- ============================================================
CREATE TABLE metodos_pago (
  mp_id          INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  mp_nombre      VARCHAR(80)    NOT NULL,
  mp_descripcion VARCHAR(200)   NULL,
  mp_activo      TINYINT(1)     NOT NULL DEFAULT 1,
  CONSTRAINT pk_metodos_pago PRIMARY KEY (mp_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLA 9: pagos
-- ============================================================
CREATE TABLE pagos (
  pag_id         INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  ped_id         INT UNSIGNED   NOT NULL,
  mp_id          INT UNSIGNED   NOT NULL,
  pag_monto      DECIMAL(10,2)  NOT NULL,
  pag_fecha      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  pag_referencia VARCHAR(100)   NULL,
  pag_estado     ENUM(
                   'pendiente',
                   'completado',
                   'fallido',
                   'reembolsado'
                 )              NOT NULL DEFAULT 'pendiente',
  CONSTRAINT pk_pagos       PRIMARY KEY (pag_id),
  CONSTRAINT fk_pag_pedido  FOREIGN KEY (ped_id)
    REFERENCES pedidos(ped_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_pag_metodo  FOREIGN KEY (mp_id)
    REFERENCES metodos_pago(mp_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  INDEX idx_pag_pedido (ped_id),
  INDEX idx_pag_estado (pag_estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLA 10: envios
-- ============================================================
CREATE TABLE envios (
  env_id              INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  ped_id              INT UNSIGNED   NOT NULL,
  env_transportista   VARCHAR(100)   NOT NULL,
  env_numero_guia     VARCHAR(100)   NULL,
  env_fecha_envio     DATETIME       NULL,
  env_fecha_estimada  DATE           NULL,
  env_fecha_entrega   DATETIME       NULL,
  env_estado          ENUM(
                        'preparando',
                        'en_camino',
                        'entregado',
                        'devuelto'
                      )              NOT NULL DEFAULT 'preparando',
  CONSTRAINT pk_envios      PRIMARY KEY (env_id),
  CONSTRAINT uq_env_pedido  UNIQUE (ped_id),
  CONSTRAINT fk_env_pedido  FOREIGN KEY (ped_id)
    REFERENCES pedidos(ped_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  INDEX idx_env_estado (env_estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- DATOS DE PRUEBA (INSERT)
-- ============================================================

-- Categorías
INSERT INTO categorias (cat_nombre, cat_descripcion) VALUES
  ('Electrónica',    'Dispositivos y gadgets electrónicos'),
  ('Ropa',           'Prendas de vestir para hombre y mujer'),
  ('Hogar',          'Artículos para el hogar y decoración'),
  ('Deportes',       'Equipos y accesorios deportivos'),
  ('Libros',         'Libros físicos y material educativo');

-- Métodos de pago
INSERT INTO metodos_pago (mp_nombre, mp_descripcion) VALUES
  ('Tarjeta de Crédito', 'Pago con tarjeta Visa, MasterCard o Amex'),
  ('Tarjeta de Débito',  'Pago directo desde cuenta bancaria'),
  ('PayPal',             'Pago mediante cuenta PayPal'),
  ('Transferencia',      'Transferencia bancaria directa');

-- Productos
INSERT INTO productos (cat_id, prod_nombre, prod_precio) VALUES
  (1, 'Audífonos Bluetooth',    799.99),
  (1, 'Teclado Inalámbrico',    450.00),
  (2, 'Playera Deportiva',      250.00),
  (3, 'Lámpara de Escritorio',  380.50),
  (4, 'Balón de Fútbol',        199.00);

-- Inventario
INSERT INTO inventario (prod_id, inv_stock, inv_stock_minimo) VALUES
  (1, 50, 5),
  (2, 30, 5),
  (3, 80, 10),
  (4, 25, 5),
  (5, 60, 10);

-- Clientes
INSERT INTO clientes (cli_nombre, cli_apellido, cli_email, cli_password) VALUES
  ('Ana',    'García',    'ana.garcia@email.com',    SHA2('password123', 256)),
  ('Carlos', 'Martínez',  'carlos.m@email.com',      SHA2('miClave456', 256)),
  ('Laura',  'Rodríguez', 'laura.rod@email.com',     SHA2('securePass789', 256));

-- Direcciones
INSERT INTO direcciones (cli_id, dir_calle, dir_ciudad, dir_estado, dir_codigo_postal, dir_pais, dir_predeterminada) VALUES
  (1, 'Av. Reforma 123',  'Ciudad de México', 'CDMX',       '06600', 'México', 1),
  (2, 'Calle Roble 456',  'Guadalajara',      'Jalisco',    '44100', 'México', 1),
  (3, 'Blvd. Torres 789', 'Monterrey',        'Nuevo León', '64000', 'México', 1);

-- Pedidos
INSERT INTO pedidos (cli_id, dir_id, ped_estado, ped_total) VALUES
  (1, 1, 'entregado',  1049.99),
  (2, 2, 'procesando',  450.00),
  (3, 3, 'pendiente',   449.00);

-- Detalle de pedidos
INSERT INTO detalle_pedidos (ped_id, prod_id, det_cantidad, det_precio_unitario, det_subtotal) VALUES
  (1, 1, 1, 799.99, 799.99),
  (1, 3, 1, 250.00, 250.00),
  (2, 2, 1, 450.00, 450.00),
  (3, 3, 1, 250.00, 250.00),
  (3, 5, 1, 199.00, 199.00);

-- Pagos
INSERT INTO pagos (ped_id, mp_id, pag_monto, pag_referencia, pag_estado) VALUES
  (1, 1, 1049.99, 'REF-001-2025', 'completado'),
  (2, 3,  450.00, 'REF-002-2025', 'completado'),
  (3, 2,  449.00,  NULL,          'pendiente');

-- Envíos
INSERT INTO envios (ped_id, env_transportista, env_numero_guia, env_fecha_envio, env_fecha_estimada, env_fecha_entrega, env_estado) VALUES
  (1, 'FedEx',  'FDX123456789', '2025-01-10 10:00:00', '2025-01-13', '2025-01-12 15:30:00', 'entregado'),
  (2, 'DHL',    'DHL987654321', '2025-01-15 09:00:00', '2025-01-18', NULL,                  'en_camino'),
  (3, 'Estafeta', NULL,          NULL,                  NULL,         NULL,                  'preparando');
  USE tienda_online;

-- Ver todas las tablas
SHOW TABLES;

-- Ver registros de cada tabla
SELECT * FROM categorias;
SELECT * FROM productos;
SELECT * FROM clientes;
SELECT * FROM pedidos;
SELECT * FROM detalle_pedidos;
SELECT * FROM pagos;
SELECT * FROM envios;
