-- ============================================================
-- ARCHIVO: tienda_online_datos_prueba.sql
-- BASE DE DATOS: TIENDA EN LÍNEA
-- Descripción: Inserción de datos de prueba y ejecución
--              de SP, funciones, vistas y triggers
-- ============================================================

USE tienda_online;

-- ============================================================
-- DATOS BASE
-- ============================================================

INSERT INTO categorias (cat_nombre, cat_descripcion) VALUES
  ('Electrónica',  'Dispositivos y gadgets electrónicos'),
  ('Ropa',         'Prendas de vestir para hombre y mujer'),
  ('Hogar',        'Artículos para el hogar y decoración'),
  ('Deportes',     'Equipos y accesorios deportivos'),
  ('Libros',       'Libros físicos y material educativo');

INSERT INTO metodos_pago (mp_nombre, mp_descripcion) VALUES
  ('Tarjeta de Crédito', 'Pago con Visa, MasterCard o Amex'),
  ('Tarjeta de Débito',  'Pago desde cuenta bancaria'),
  ('PayPal',             'Pago mediante cuenta PayPal'),
  ('Transferencia',      'Transferencia bancaria directa');

INSERT INTO productos (cat_id, prod_nombre, prod_precio) VALUES
  (1, 'Audífonos Bluetooth',   799.99),
  (1, 'Teclado Inalámbrico',   450.00),
  (2, 'Playera Deportiva',     250.00),
  (3, 'Lámpara de Escritorio', 380.50),
  (4, 'Balón de Fútbol',       199.00),
  (1, 'Mouse Inalámbrico',     320.00),
  (5, 'Libro de SQL Avanzado', 180.00);

INSERT INTO inventario (prod_id, inv_stock, inv_stock_minimo) VALUES
  (1, 50,  5),
  (2, 30,  5),
  (3, 80, 10),
  (4,  4,  5),  -- intencional: stock bajo para vista vw_stock_bajo
  (5, 60, 10),
  (6,  3,  5),  -- intencional: stock bajo para vista vw_stock_bajo
  (7, 20,  5);

INSERT INTO clientes (cli_nombre, cli_apellido, cli_email, cli_password) VALUES
  ('Ana',     'García',    'ana.garcia@email.com',   SHA2('pass123', 256)),
  ('Carlos',  'Martínez',  'carlos.m@email.com',     SHA2('pass456', 256)),
  ('Laura',   'Rodríguez', 'laura.rod@email.com',    SHA2('pass789', 256)),
  ('Miguel',  'Torres',    'miguel.t@email.com',     SHA2('pass000', 256));

INSERT INTO direcciones
  (cli_id, dir_calle, dir_ciudad, dir_estado, dir_codigo_postal, dir_pais, dir_predeterminada)
VALUES
  (1, 'Av. Reforma 123',   'Ciudad de México', 'CDMX',       '06600', 'México', 1),
  (2, 'Calle Roble 456',   'Guadalajara',      'Jalisco',    '44100', 'México', 1),
  (3, 'Blvd. Torres 789',  'Monterrey',        'Nuevo León', '64000', 'México', 1),
  (4, 'Calle Pino 321',    'Puebla',           'Puebla',     '72000', 'México', 1);


-- ============================================================
-- PRUEBA DE STORED PROCEDURES
-- ============================================================

-- SP 1: Crear pedidos usando sp_crear_pedido
-- Cliente 1 compra 2 Audífonos Bluetooth
CALL sp_crear_pedido(1, 1, 1, 2);

-- Cliente 2 compra 1 Teclado Inalámbrico
CALL sp_crear_pedido(2, 2, 2, 1);

-- Cliente 3 compra 3 Playeras Deportivas
CALL sp_crear_pedido(3, 3, 3, 3);

-- Cliente 4 compra 1 Libro de SQL
CALL sp_crear_pedido(4, 4, 7, 1);

-- SP 2: Registrar pagos
CALL sp_registrar_pago(1, 1, 1599.98, 'REF-001-2025');
CALL sp_registrar_pago(2, 3,  450.00, 'REF-002-2025');
CALL sp_registrar_pago(3, 2,  750.00, 'REF-003-2025');
CALL sp_registrar_pago(4, 4,  180.00, 'REF-004-2025');

-- SP 3: Registrar envíos (activa trigger trg_estado_entregado)
CALL sp_registrar_envio(1, 'FedEx',    'FDX111222333', '2025-02-15');
CALL sp_registrar_envio(2, 'DHL',      'DHL444555666', '2025-02-16');
CALL sp_registrar_envio(3, 'Estafeta', 'EST777888999', '2025-02-17');

-- SP 4: Reporte de ventas del período
CALL sp_reporte_ventas_periodo('2025-01-01', '2025-12-31');


-- ============================================================
-- PRUEBA DE TRIGGERS
-- ============================================================

-- Trigger trg_estado_entregado:
-- Actualizar envío a 'entregado' → cambia estado del pedido automáticamente
UPDATE envios SET env_estado = 'entregado' WHERE ped_id = 1;

-- Verificar que el pedido 1 cambió a 'entregado'
SELECT ped_id, ped_estado FROM pedidos WHERE ped_id = 1;

-- Trigger trg_auditoria_stock:
-- Ver el historial generado automáticamente
SELECT * FROM auditoria_stock;

-- Trigger trg_validar_stock_minimo:
-- Intentar dejar stock negativo (debe lanzar error controlado)
-- UPDATE inventario SET inv_stock = -1 WHERE prod_id = 1;


-- ============================================================
-- PRUEBA DE FUNCIONES PERSONALIZADAS
-- ============================================================

-- fn_calcular_total_pedido
SELECT fn_calcular_total_pedido(1) AS total_pedido_1;
SELECT fn_calcular_total_pedido(2) AS total_pedido_2;

-- fn_total_compras_cliente
SELECT fn_total_compras_cliente(1) AS total_gastado_cliente_1;
SELECT fn_total_compras_cliente(2) AS total_gastado_cliente_2;

-- fn_stock_disponible
SELECT fn_stock_disponible(1) AS stock_audifonos;
SELECT fn_stock_disponible(4) AS stock_lampara;

-- fn_nombre_completo_cliente
SELECT fn_nombre_completo_cliente(1) AS nombre_cliente_1;
SELECT fn_nombre_completo_cliente(3) AS nombre_cliente_3;


-- ============================================================
-- PRUEBA DE VISTAS
-- ============================================================

-- Catálogo de productos activos con stock
SELECT * FROM vw_productos_catalogo;

-- Detalle de todos los pedidos
SELECT * FROM vw_pedidos_detalle;

-- Ventas agrupadas por producto
SELECT * FROM vw_ventas_por_producto ORDER BY ingreso_total DESC;

-- Pagos completados
SELECT * FROM vw_pagos_completados;

-- Productos con stock bajo
SELECT * FROM vw_stock_bajo;

