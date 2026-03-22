-- ============================================================
-- ARCHIVO: tienda_online_creacion.sql
-- BASE DE DATOS: TIENDA EN LÍNEA
-- Motor: MySQL 8.0+
-- Descripción: Creación de esquema, tablas, vistas,
--              funciones, stored procedures y triggers
-- ============================================================

DROP DATABASE IF EXISTS tienda_online;
CREATE DATABASE tienda_online
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE tienda_online;

-- ============================================================
-- TABLAS
-- ============================================================

CREATE TABLE categorias (
  cat_id             INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  cat_nombre         VARCHAR(100)  NOT NULL,
  cat_descripcion    TEXT          NULL,
  cat_activa         TINYINT(1)    NOT NULL DEFAULT 1,
  cat_fecha_creacion DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_categorias PRIMARY KEY (cat_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------

CREATE TABLE productos (
  prod_id             INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  cat_id              INT UNSIGNED  NOT NULL,
  prod_nombre         VARCHAR(150)  NOT NULL,
  prod_descripcion    TEXT          NULL,
  prod_precio         DECIMAL(10,2) NOT NULL,
  prod_imagen         VARCHAR(255)  NULL,
  prod_activo         TINYINT(1)    NOT NULL DEFAULT 1,
  prod_fecha_registro DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_productos PRIMARY KEY (prod_id),
  CONSTRAINT fk_prod_cat  FOREIGN KEY (cat_id)
    REFERENCES categorias(cat_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_prod_categoria (cat_id),
  INDEX idx_prod_nombre    (prod_nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------

CREATE TABLE inventario (
  inv_id                   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  prod_id                  INT UNSIGNED NOT NULL,
  inv_stock                INT UNSIGNED NOT NULL DEFAULT 0,
  inv_stock_minimo         INT UNSIGNED NOT NULL DEFAULT 5,
  inv_ultima_actualizacion DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                                        ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT pk_inventario PRIMARY KEY (inv_id),
  CONSTRAINT uq_inv_prod   UNIQUE (prod_id),
  CONSTRAINT fk_inv_prod   FOREIGN KEY (prod_id)
    REFERENCES productos(prod_id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------

CREATE TABLE clientes (
  cli_id             INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  cli_nombre         VARCHAR(100)  NOT NULL,
  cli_apellido       VARCHAR(100)  NOT NULL,
  cli_email          VARCHAR(150)  NOT NULL,
  cli_telefono       VARCHAR(20)   NULL,
  cli_password       VARCHAR(255)  NOT NULL,
  cli_activo         TINYINT(1)    NOT NULL DEFAULT 1,
  cli_fecha_registro DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_clientes  PRIMARY KEY (cli_id),
  CONSTRAINT uq_cli_email UNIQUE (cli_email),
  INDEX idx_cli_email (cli_email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------

CREATE TABLE direcciones (
  dir_id             INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  cli_id             INT UNSIGNED  NOT NULL,
  dir_calle          VARCHAR(200)  NOT NULL,
  dir_ciudad         VARCHAR(100)  NOT NULL,
  dir_estado         VARCHAR(100)  NOT NULL,
  dir_codigo_postal  VARCHAR(10)   NOT NULL,
  dir_pais           VARCHAR(80)   NOT NULL,
  dir_predeterminada TINYINT(1)    NOT NULL DEFAULT 0,
  CONSTRAINT pk_direcciones PRIMARY KEY (dir_id),
  CONSTRAINT fk_dir_cli     FOREIGN KEY (cli_id)
    REFERENCES clientes(cli_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  INDEX idx_dir_cliente (cli_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------

CREATE TABLE pedidos (
  ped_id     INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  cli_id     INT UNSIGNED  NOT NULL,
  dir_id     INT UNSIGNED  NOT NULL,
  ped_fecha  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ped_estado ENUM('pendiente','procesando','enviado','entregado','cancelado')
             NOT NULL DEFAULT 'pendiente',
  ped_total  DECIMAL(10,2) NOT NULL,
  ped_notas  TEXT          NULL,
  CONSTRAINT pk_pedidos PRIMARY KEY (ped_id),
  CONSTRAINT fk_ped_cli FOREIGN KEY (cli_id)
    REFERENCES clientes(cli_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_ped_dir FOREIGN KEY (dir_id)
    REFERENCES direcciones(dir_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_ped_cliente (cli_id),
  INDEX idx_ped_estado  (ped_estado),
  INDEX idx_ped_fecha   (ped_fecha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------

CREATE TABLE detalle_pedidos (
  det_id              INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  ped_id              INT UNSIGNED  NOT NULL,
  prod_id             INT UNSIGNED  NOT NULL,
  det_cantidad        INT UNSIGNED  NOT NULL,
  det_precio_unitario DECIMAL(10,2) NOT NULL,
  det_subtotal        DECIMAL(10,2) NOT NULL,
  CONSTRAINT pk_detalle      PRIMARY KEY (det_id),
  CONSTRAINT fk_det_pedido   FOREIGN KEY (ped_id)
    REFERENCES pedidos(ped_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_det_producto FOREIGN KEY (prod_id)
    REFERENCES productos(prod_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_det_pedido   (ped_id),
  INDEX idx_det_producto (prod_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------

CREATE TABLE metodos_pago (
  mp_id          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  mp_nombre      VARCHAR(80)   NOT NULL,
  mp_descripcion VARCHAR(200)  NULL,
  mp_activo      TINYINT(1)    NOT NULL DEFAULT 1,
  CONSTRAINT pk_metodos_pago PRIMARY KEY (mp_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------

CREATE TABLE pagos (
  pag_id         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  ped_id         INT UNSIGNED  NOT NULL,
  mp_id          INT UNSIGNED  NOT NULL,
  pag_monto      DECIMAL(10,2) NOT NULL,
  pag_fecha      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  pag_referencia VARCHAR(100)  NULL,
  pag_estado     ENUM('pendiente','completado','fallido','reembolsado')
                 NOT NULL DEFAULT 'pendiente',
  CONSTRAINT pk_pagos      PRIMARY KEY (pag_id),
  CONSTRAINT fk_pag_pedido FOREIGN KEY (ped_id)
    REFERENCES pedidos(ped_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_pag_metodo FOREIGN KEY (mp_id)
    REFERENCES metodos_pago(mp_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_pag_pedido (ped_id),
  INDEX idx_pag_estado (pag_estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------

CREATE TABLE envios (
  env_id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  ped_id             INT UNSIGNED NOT NULL,
  env_transportista  VARCHAR(100) NOT NULL,
  env_numero_guia    VARCHAR(100) NULL,
  env_fecha_envio    DATETIME     NULL,
  env_fecha_estimada DATE         NULL,
  env_fecha_entrega  DATETIME     NULL,
  env_estado         ENUM('preparando','en_camino','entregado','devuelto')
                     NOT NULL DEFAULT 'preparando',
  CONSTRAINT pk_envios     PRIMARY KEY (env_id),
  CONSTRAINT uq_env_pedido UNIQUE (ped_id),
  CONSTRAINT fk_env_pedido FOREIGN KEY (ped_id)
    REFERENCES pedidos(ped_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_env_estado (env_estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------

CREATE TABLE auditoria_stock (
  aud_id            INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  prod_id           INT UNSIGNED  NOT NULL,
  aud_stock_anterior INT          NOT NULL,
  aud_stock_nuevo    INT          NOT NULL,
  aud_motivo        VARCHAR(100)  NOT NULL,
  aud_fecha         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_auditoria PRIMARY KEY (aud_id),
  CONSTRAINT fk_aud_prod  FOREIGN KEY (prod_id)
    REFERENCES productos(prod_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  INDEX idx_aud_prod (prod_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- VISTAS
-- ============================================================

CREATE OR REPLACE VIEW vw_productos_catalogo AS
  SELECT
    p.prod_id,
    p.prod_nombre,
    p.prod_precio,
    c.cat_nombre,
    i.inv_stock
  FROM productos p
  INNER JOIN categorias c ON p.cat_id    = c.cat_id
  LEFT  JOIN inventario i ON p.prod_id   = i.prod_id
  WHERE p.prod_activo = 1;

-- ------------------------------------------------------------

CREATE OR REPLACE VIEW vw_pedidos_detalle AS
  SELECT
    pe.ped_id,
    pe.ped_fecha,
    pe.ped_estado,
    pe.ped_total,
    CONCAT(cl.cli_nombre, ' ', cl.cli_apellido) AS cliente_nombre,
    cl.cli_email,
    di.dir_ciudad,
    di.dir_pais
  FROM pedidos pe
  INNER JOIN clientes    cl ON pe.cli_id = cl.cli_id
  INNER JOIN direcciones di ON pe.dir_id = di.dir_id;

-- ------------------------------------------------------------

CREATE OR REPLACE VIEW vw_ventas_por_producto AS
  SELECT
    p.prod_id,
    p.prod_nombre,
    SUM(dp.det_cantidad) AS total_unidades_vendidas,
    SUM(dp.det_subtotal) AS ingreso_total
  FROM detalle_pedidos dp
  INNER JOIN productos p ON dp.prod_id = p.prod_id
  GROUP BY p.prod_id, p.prod_nombre;

-- ------------------------------------------------------------

CREATE OR REPLACE VIEW vw_pagos_completados AS
  SELECT
    pg.pag_id,
    pg.ped_id,
    pg.pag_monto,
    pg.pag_fecha,
    pg.pag_referencia,
    mp.mp_nombre
  FROM pagos pg
  INNER JOIN metodos_pago mp ON pg.mp_id = mp.mp_id
  WHERE pg.pag_estado = 'completado';

-- ------------------------------------------------------------

CREATE OR REPLACE VIEW vw_stock_bajo AS
  SELECT
    p.prod_id,
    p.prod_nombre,
    i.inv_stock,
    i.inv_stock_minimo,
    (i.inv_stock - i.inv_stock_minimo) AS diferencia
  FROM inventario i
  INNER JOIN productos p ON i.prod_id = p.prod_id
  WHERE i.inv_stock <= i.inv_stock_minimo;


-- ============================================================
-- FUNCIONES PERSONALIZADAS
-- ============================================================

DELIMITER $$

CREATE FUNCTION fn_calcular_total_pedido(p_ped_id INT UNSIGNED)
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
  DECLARE v_total DECIMAL(10,2) DEFAULT 0;
  SELECT COALESCE(SUM(det_subtotal), 0)
    INTO v_total
    FROM detalle_pedidos
   WHERE ped_id = p_ped_id;
  RETURN v_total;
END$$

-- ------------------------------------------------------------

CREATE FUNCTION fn_total_compras_cliente(p_cli_id INT UNSIGNED)
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
  DECLARE v_total DECIMAL(10,2) DEFAULT 0;
  SELECT COALESCE(SUM(pg.pag_monto), 0)
    INTO v_total
    FROM pagos pg
   INNER JOIN pedidos pe ON pg.ped_id = pe.ped_id
   WHERE pe.cli_id      = p_cli_id
     AND pg.pag_estado  = 'completado';
  RETURN v_total;
END$$

-- ------------------------------------------------------------

CREATE FUNCTION fn_stock_disponible(p_prod_id INT UNSIGNED)
RETURNS INT UNSIGNED
READS SQL DATA
DETERMINISTIC
BEGIN
  DECLARE v_stock INT UNSIGNED DEFAULT 0;
  SELECT COALESCE(inv_stock, 0)
    INTO v_stock
    FROM inventario
   WHERE prod_id = p_prod_id;
  RETURN v_stock;
END$$

-- ------------------------------------------------------------

CREATE FUNCTION fn_nombre_completo_cliente(p_cli_id INT UNSIGNED)
RETURNS VARCHAR(205)
READS SQL DATA
DETERMINISTIC
BEGIN
  DECLARE v_nombre VARCHAR(205) DEFAULT '';
  SELECT CONCAT(cli_nombre, ' ', cli_apellido)
    INTO v_nombre
    FROM clientes
   WHERE cli_id = p_cli_id;
  RETURN v_nombre;
END$$

DELIMITER ;


-- ============================================================
-- STORED PROCEDURES
-- ============================================================

DELIMITER $$

CREATE PROCEDURE sp_crear_pedido(
  IN p_cli_id   INT UNSIGNED,
  IN p_dir_id   INT UNSIGNED,
  IN p_prod_id  INT UNSIGNED,
  IN p_cantidad INT UNSIGNED
)
BEGIN
  DECLARE v_precio   DECIMAL(10,2);
  DECLARE v_subtotal DECIMAL(10,2);
  DECLARE v_stock    INT UNSIGNED;
  DECLARE v_ped_id   INT UNSIGNED;

  -- Validar stock
  SELECT inv_stock INTO v_stock
    FROM inventario WHERE prod_id = p_prod_id;

  IF v_stock < p_cantidad THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Stock insuficiente para el producto solicitado';
  END IF;

  -- Obtener precio actual
  SELECT prod_precio INTO v_precio
    FROM productos WHERE prod_id = p_prod_id;

  SET v_subtotal = v_precio * p_cantidad;

  -- Crear pedido
  INSERT INTO pedidos (cli_id, dir_id, ped_estado, ped_total)
  VALUES (p_cli_id, p_dir_id, 'pendiente', v_subtotal);

  SET v_ped_id = LAST_INSERT_ID();

  -- Insertar detalle (el trigger descontará el stock)
  INSERT INTO detalle_pedidos
    (ped_id, prod_id, det_cantidad, det_precio_unitario, det_subtotal)
  VALUES
    (v_ped_id, p_prod_id, p_cantidad, v_precio, v_subtotal);

  SELECT v_ped_id AS pedido_creado, v_subtotal AS total;
END$$

-- ------------------------------------------------------------

CREATE PROCEDURE sp_registrar_pago(
  IN p_ped_id      INT UNSIGNED,
  IN p_mp_id       INT UNSIGNED,
  IN p_monto       DECIMAL(10,2),
  IN p_referencia  VARCHAR(100)
)
BEGIN
  INSERT INTO pagos (ped_id, mp_id, pag_monto, pag_referencia, pag_estado)
  VALUES (p_ped_id, p_mp_id, p_monto, p_referencia, 'completado');

  UPDATE pedidos
     SET ped_estado = 'procesando'
   WHERE ped_id     = p_ped_id
     AND ped_estado = 'pendiente';

  SELECT 'Pago registrado correctamente' AS resultado;
END$$

-- ------------------------------------------------------------

CREATE PROCEDURE sp_registrar_envio(
  IN p_ped_id         INT UNSIGNED,
  IN p_transportista  VARCHAR(100),
  IN p_guia           VARCHAR(100),
  IN p_fecha_estimada DATE
)
BEGIN
  INSERT INTO envios
    (ped_id, env_transportista, env_numero_guia,
     env_fecha_envio, env_fecha_estimada, env_estado)
  VALUES
    (p_ped_id, p_transportista, p_guia,
     NOW(), p_fecha_estimada, 'en_camino');

  UPDATE pedidos
     SET ped_estado = 'enviado'
   WHERE ped_id     = p_ped_id;

  SELECT 'Envío registrado correctamente' AS resultado;
END$$

-- ------------------------------------------------------------

CREATE PROCEDURE sp_reporte_ventas_periodo(
  IN p_fecha_inicio DATETIME,
  IN p_fecha_fin    DATETIME
)
BEGIN
  SELECT
    p.prod_id,
    p.prod_nombre,
    SUM(dp.det_cantidad)  AS unidades_vendidas,
    SUM(dp.det_subtotal)  AS ingreso_total
  FROM detalle_pedidos dp
  INNER JOIN productos p  ON dp.prod_id = p.prod_id
  INNER JOIN pedidos   pe ON dp.ped_id  = pe.ped_id
  WHERE pe.ped_fecha BETWEEN p_fecha_inicio AND p_fecha_fin
    AND pe.ped_estado != 'cancelado'
  GROUP BY p.prod_id, p.prod_nombre
  ORDER BY ingreso_total DESC;
END$$

DELIMITER ;


-- ============================================================
-- TRIGGERS
-- ============================================================

DELIMITER $$

-- Trigger 1: Descontar stock al insertar detalle de pedido
CREATE TRIGGER trg_descontar_stock
AFTER INSERT ON detalle_pedidos
FOR EACH ROW
BEGIN
  UPDATE inventario
     SET inv_stock = inv_stock - NEW.det_cantidad
   WHERE prod_id   = NEW.prod_id;
END$$

-- ------------------------------------------------------------

-- Trigger 2: Auditoría automática de cambios en stock
CREATE TRIGGER trg_auditoria_stock
AFTER UPDATE ON inventario
FOR EACH ROW
BEGIN
  IF OLD.inv_stock <> NEW.inv_stock THEN
    INSERT INTO auditoria_stock
      (prod_id, aud_stock_anterior, aud_stock_nuevo, aud_motivo)
    VALUES
      (NEW.prod_id, OLD.inv_stock, NEW.inv_stock, 'Actualización de stock');
  END IF;
END$$

-- ------------------------------------------------------------

-- Trigger 3: Actualizar estado pedido cuando envío es entregado
CREATE TRIGGER trg_estado_entregado
AFTER UPDATE ON envios
FOR EACH ROW
BEGIN
  IF NEW.env_estado = 'entregado' AND OLD.env_estado <> 'entregado' THEN
    UPDATE pedidos
       SET ped_estado = 'entregado'
     WHERE ped_id     = NEW.ped_id;

    UPDATE envios
       SET env_fecha_entrega = NOW()
     WHERE env_id            = NEW.env_id;
  END IF;
END$$

-- ------------------------------------------------------------

-- Trigger 4: Validar que el stock no quede negativo
CREATE TRIGGER trg_validar_stock_minimo
BEFORE UPDATE ON inventario
FOR EACH ROW
BEGIN
  IF NEW.inv_stock < 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Error: el stock no puede ser negativo';
  END IF;
END$$

DELIMITER ;
