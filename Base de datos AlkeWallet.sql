-- ========================================================================================
--                      Lección 1° Las bases de datos relacionales
-- ========================================================================================

-- Creación de la base de datos
CREATE DATABASE AlkeWallet;
USE AlkeWallet;

-- Creación de la tabla moneda
CREATE TABLE moneda (
    currency_id INT PRIMARY KEY AUTO_INCREMENT,
    currency_name VARCHAR(50),
    currency_symbol VARCHAR(10)
);

-- Creación de la tabla usuario
CREATE TABLE usuario (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50),
    correo_electronico VARCHAR(50) UNIQUE,
    contrasena VARCHAR(50),
    saldo DECIMAL(10,2) DEFAULT 0.00,
    currency_id INT,
    FOREIGN KEY (currency_id) REFERENCES moneda(currency_id)
);

-- Creación de la tabla transaccion
CREATE TABLE transaccion (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    sender_user_id INT,
    receiver_user_id INT,
    currency_id INT,
    importe DECIMAL(10,2),
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (sender_user_id) REFERENCES usuario(user_id),
    FOREIGN KEY (receiver_user_id) REFERENCES usuario(user_id),
    FOREIGN KEY (currency_id) REFERENCES moneda(currency_id)
);

-- Datos de prueba en tabla moneda
INSERT INTO moneda (currency_name, currency_symbol) VALUES 
('Peso Chileno', '$'),
('Dolar', 'USD'),
('Euro', 'EUR'),
('Peso Argentino', 'ARS'),
('Libra Esterlina', 'GBP');

-- Datos de prueba en tabla usuario
INSERT INTO usuario (nombre, correo_electronico, contrasena, saldo, currency_id) VALUES
('Ignacio', 'ignacio@email.com', '1234', 100000.00, 1),
('Macarena', 'maca@email.com', '2648', 1000.00, 2),
('Alejandro', 'Alejandro@email.com', '0184', 100000.00, 3),
('Maria', 'maria@email.com', 'abcd', 50000.00, 1),
('Sofia', 'sofi@email.com', 'pass1', 25000.00, 1),
('Diego', 'diego@email.com', 'pass2', 75000.00, 2),
('Valentina', 'vale@email.com', 'pass3', 12000.00, 3),
('Javier', 'javi@email.com', 'pass4', 5000.00, 4),
('Barbara', 'babi@email.com', 'pass5', 90000.00, 5),
('Felipe', 'felipe@email.com', 'pass6', 3000.00, 1);

-- Datos de prueba en tabla transaccion
INSERT INTO transaccion 
(sender_user_id, receiver_user_id, currency_id, importe) VALUES 
(1, 4, 1, 15000),
(4, 1, 1, 5000),
(2, 3, 2, 300),
(5, 6, 1, 2000),
(6, 7, 2, 150),
(7, 8, 3, 50),
(8, 9, 4, 1000),
(9, 10, 5, 20),
(10, 1, 1, 12000),
(3, 2, 2, 450);

-- Lección 1° Verificación de las bases de datos relacionales

-- Usar la base correcta
USE AlkeWallet;

-- Mostrar bases de datos
SHOW DATABASES;

-- Mostrar tablas creadas
SHOW TABLES;

-- Ver estructura de cada tabla
DESCRIBE moneda;
DESCRIBE usuario;
DESCRIBE transaccion;

-- ========================================================================================
--                    Lección 2° Consultas a una o varias tablas
-- ========================================================================================

-- 2.1 Consultas básicas

-- Mostrar todos los usuarios registrados
SELECT * FROM usuario;

-- Mostrar usuarios con saldo mayor a 50.000
SELECT nombre, saldo
FROM usuario
WHERE saldo > 50000;

-- Ordenar usuarios por saldo descendente
SELECT nombre, saldo
FROM usuario
ORDER BY saldo DESC;

-- 2.2 Funciones de agregación

-- Saldo promedio de los usuarios
SELECT AVG(saldo) AS saldo_promedio
FROM usuario;

-- Suma total de dinero en el sistema
SELECT SUM(saldo) AS saldo_total
FROM usuario;

-- Cantidad total de usuarios
SELECT COUNT(*) AS total_usuarios
FROM usuario;

-- 2.3 Consultas con INNER JOIN

-- Mostrar cada usuario con su moneda
SELECT 
    u.nombre,
    m.currency_name AS moneda,
    m.currency_symbol AS simbolo
FROM usuario u
INNER JOIN moneda m ON u.currency_id = m.currency_id;

-- Historial detallado de transacciones y nombres de usuarios
SELECT 
    t.transaction_id,
    u1.nombre AS emisor,
    u2.nombre AS receptor,
    m.currency_name AS moneda,
    t.importe,
    t.transaction_date
FROM transaccion t
INNER JOIN usuario u1 ON t.sender_user_id = u1.user_id
INNER JOIN usuario u2 ON t.receiver_user_id = u2.user_id
INNER JOIN moneda m ON t.currency_id = m.currency_id
ORDER BY t.transaction_date DESC;

-- Transacciones realizadas por un usuario específico, en este caso por Ignacio
SELECT 
    t.transaction_id,
    u2.nombre AS receptor,
    t.importe,
    t.transaction_date
FROM transaccion t
INNER JOIN usuario u2 ON t.receiver_user_id = u2.user_id
WHERE t.sender_user_id = 1;

-- 2.4 Filtros múltiples
-- Transacciones mayores a 1000 en Peso Chileno
SELECT 
    t.transaction_id,
    u1.nombre AS emisor,
    u2.nombre AS receptor,
    t.importe
FROM transaccion t
INNER JOIN usuario u1 ON t.sender_user_id = u1.user_id
INNER JOIN usuario u2 ON t.receiver_user_id = u2.user_id
INNER JOIN moneda m ON t.currency_id = m.currency_id
WHERE t.importe > 3000
AND m.currency_name = 'Peso Chileno';

-- 2.5 Uso de GROUP BY
-- Cantidad de usuarios agrupados por moneda
SELECT 
    m.currency_name AS moneda,
    COUNT(u.user_id) AS cantidad_usuarios
FROM usuario u
INNER JOIN moneda m ON u.currency_id = m.currency_id
GROUP BY m.currency_name;

-- Suma total de saldo agrupado por moneda
SELECT 
    m.currency_name AS moneda,
    SUM(u.saldo) AS saldo_total
FROM usuario u
INNER JOIN moneda m ON u.currency_id = m.currency_id
GROUP BY m.currency_name;

-- Cantidad de transacciones enviadas por cada usuario
SELECT 
    u.nombre AS usuario,
    COUNT(t.transaction_id) AS total_transacciones
FROM usuario u
INNER JOIN transaccion t 
ON u.user_id = t.sender_user_id
GROUP BY u.nombre
ORDER BY total_transacciones DESC;

-- Total de dinero enviado por cada usuario
SELECT 
    u.nombre AS usuario,
    SUM(t.importe) AS total_enviado
FROM usuario u
INNER JOIN transaccion t 
ON u.user_id = t.sender_user_id
GROUP BY u.nombre
ORDER BY total_enviado DESC;

-- ========================================================================================
--          TAREA PLUS - Creación de Vista del Top 5 usuarios con mayor saldo
-- ========================================================================================

-- creación de vista
CREATE VIEW vista_top5_usuarios AS
SELECT 
    nombre,
    correo_electronico,
    saldo
FROM usuario
ORDER BY saldo DESC
LIMIT 5;

-- Consultar la vista creada
SELECT * FROM vista_top5_usuarios;

-- ========================================================================================
--        Lección 3° Sentencias para la Manipulación de Datos y Transaccionalidad
-- ========================================================================================

-- 3.1 (INSERT) Insertar un nuevo usuario en el sistema
INSERT INTO usuario 
(nombre, correo_electronico, contrasena, saldo, currency_id) VALUES 
('Ilonka', 'ilonka@email.com', '12345', 40000.00, 1);
-- Verificación
SELECT * FROM usuario WHERE nombre = 'Ilonka';

-- 3.2 (UPDATE) Actualizar saldo de Ilonka, id=11
-- *Intente realizarlo con el nombre, pero averiguando da error ya que MySQL Workbench tiene un modo activado por defecto de "Safe Update Mode", que evita ejecutar UPDATE o DELETE si no se usa la PK en el WHERE
-- *Destaco que aquí en realidad no estaba ejecutando la buena práctica al no utilizar la PK pero encontré interesante este detalle así que lo realice mediante el id por la buena práctica pero dejo la alternativa comentada
UPDATE usuario
SET saldo = 45000.00
WHERE user_id = 11;
-- Verificación
SELECT nombre, saldo FROM usuario WHERE nombre = 'Ilonka';

-- Aqui versión alternativa desactivando el "Safe Update Mode"
SET SQL_SAFE_UPDATES = 0;
-- UPDATE con nuevo saldo
UPDATE usuario
SET saldo = 50000.00
WHERE nombre = 'Ilonka';
-- La buena práctica es volver a activarlo después de ejecutar el cambio
SET SQL_SAFE_UPDATES = 1;
-- Verificación
SELECT nombre, saldo FROM usuario WHERE nombre = 'Ilonka';

-- Modificar correo electrónico
UPDATE usuario
SET correo_electronico = 'ilonka_actualizado@email.com'
WHERE user_id = 11;
-- Verificación
SELECT nombre, correo_electronico FROM usuario WHERE nombre = 'Ilonka';

-- 3.3 (DELETE) 
-- Eliminar usuario Ilonka, id=11
DELETE FROM usuario
WHERE user_id = 11;
-- Verificación
SELECT * FROM usuario WHERE nombre = 'Ilonka';

-- 3.4 Transaccionalidad con PROCEDURE 

-- Usamos Alkewallet y eliminamos si es que existe el PROCEDURE
USE AlkeWallet;
DROP PROCEDURE IF EXISTS transferir_saldo;

-- Creación del PROCEDURE
DELIMITER $$

CREATE PROCEDURE transferir_saldo (
    IN p_sender_id INT,
    IN p_receiver_id INT,
    IN p_currency_id INT,
    IN p_monto DECIMAL(10,2)
)
BEGIN
    DECLARE filas_afectadas INT;

    START TRANSACTION;

    -- Intentar descontar saldo del emisor si tiene fondos suficientes
    UPDATE usuario
    SET saldo = saldo - p_monto
    WHERE user_id = p_sender_id
    AND saldo >= p_monto;

    SET filas_afectadas = ROW_COUNT();

    -- Si no se afectó ninguna fila, cancelar con el ROLLBACK
    IF filas_afectadas = 0 THEN
        
        ROLLBACK;
        SELECT 'Saldo insuficiente - Transacción cancelada' AS mensaje;

    ELSE

        -- Sumar saldo al receptor
        UPDATE usuario
        SET saldo = saldo + p_monto
        WHERE user_id = p_receiver_id;

        -- Registrar la transacción
        INSERT INTO transaccion 
        (sender_user_id, receiver_user_id, currency_id, importe)
        VALUES 
        (p_sender_id, p_receiver_id, p_currency_id, p_monto);

        COMMIT;
        SELECT 'Transacción realizada con éxito' AS mensaje;

    END IF;

END$$

DELIMITER ;

-- Simulación: Transferencia bancaria desde Ignacio (1) envía 20.000 a María (4) en Peso Chileno (1)

CALL transferir_saldo(1, 4, 1, 20000);

-- Verificación
SELECT user_id, nombre, saldo 
FROM usuario 
WHERE user_id IN (1,4);

SELECT * 
FROM transaccion 
ORDER BY transaction_id DESC;

-- Simulación: Transferencia bancaria desde Ignacio (1) envía 2.000.000 a María (4) en Peso Chileno (1) para que se ejecute el ROLLBACK
CALL transferir_saldo(1, 4, 1, 2000000);


-- ========================================================================================
--        Lección 4° Sentencias para la Definición de Tablas (DDL)
-- ========================================================================================

-- Para la realización de lo solicitado de la lección 4, esto fue realizado inicialmente para la realización de las consultas, las tablas las he ido modificando y mejorando según lo que se fue necesitando, en esta sección aprovechare de formalizar y revisar las tablas

-- 4.1 Verificación formal, la tabla fue creada al inicio para poder realizar las solicitudes

-- Creación de la base de datos (ya creada por ende dara error y no permite crear tabla ya existente)

-- Creación de la tabla si es que no existe para evitar el error
CREATE DATABASE IF NOT EXISTS AlkeWallet;
USE AlkeWallet;

-- Mostrar estructura completa de las tablas
SHOW CREATE TABLE moneda;
SHOW CREATE TABLE usuario;
SHOW CREATE TABLE transaccion;

-- Ver estructura de cada tabla
DESCRIBE moneda;
DESCRIBE usuario;
DESCRIBE transaccion;

-- 4.2 Añadir Índices para optimización

-- Índice para búsquedas por correo (En la creación ya se le habia asignado el UNIQUE)
CREATE INDEX idx_correo_usuario
ON usuario (correo_electronico);

-- Índice compuesto en transacciones para búsquedas frecuentes
CREATE INDEX idx_sender_fecha
ON transaccion (sender_user_id, transaction_date);

-- 4.3 Restricciones NOT NULL
-- Verificar que no existan valores NULL
SELECT * FROM moneda 
WHERE currency_name IS NULL OR currency_symbol IS NULL;

SELECT * FROM usuario 
WHERE nombre IS NULL 
   OR correo_electronico IS NULL 
   OR contrasena IS NULL 
   OR saldo IS NULL 
   OR currency_id IS NULL;

SELECT * FROM transaccion
WHERE sender_user_id IS NULL
   OR receiver_user_id IS NULL
   OR currency_id IS NULL
   OR importe IS NULL;
   
-- 4.3.1 Agregar NOT NULL a tabla moneda
ALTER TABLE moneda
MODIFY currency_name VARCHAR(50) NOT NULL,
MODIFY currency_symbol VARCHAR(10) NOT NULL;

-- 4.3.2 Agregar restricciones NOT NULL a tabla usuario
ALTER TABLE usuario
MODIFY nombre VARCHAR(50) NOT NULL,
MODIFY correo_electronico VARCHAR(50) NOT NULL,
MODIFY contrasena VARCHAR(50) NOT NULL,
MODIFY saldo DECIMAL(10,2) NOT NULL DEFAULT 0.00,
MODIFY currency_id INT NOT NULL;

-- 4.3.3 Agregar restricciones NOT NULL a tabla transaccion
ALTER TABLE transaccion
MODIFY sender_user_id INT NOT NULL,
MODIFY receiver_user_id INT NOT NULL,
MODIFY currency_id INT NOT NULL,
MODIFY importe DECIMAL(10,2) NOT NULL;

-- Verificación 
SHOW CREATE TABLE moneda;
SHOW CREATE TABLE usuario;
SHOW CREATE TABLE transaccion;

-- ========================================================================================
--               TAREA PLUS LECCIÓN 4 - Agregar fecha de creación a usuario
-- ========================================================================================

ALTER TABLE usuario
ADD fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP;

-- Verificación
SELECT user_id, nombre, fecha_creacion
FROM usuario;

-- ========================================================================================
--                          Lección 5° Modelo Entidad-Relación (MER)
-- ========================================================================================
/*
El modelo entidad-relación fue diseñado identificando tres entidades principales: Usuario, Moneda y Transaccion.
Se establecieron claves primarias para identificar de forma única cada registro y claves foráneas para mantener la integridad referencial.
Las relaciones definidas corresponden a cardinalidades 1:N, donde un usuario puede realizar múltiples transacciones y una moneda puede ser utilizada por varios usuarios y transacciones.
Este diseño cumple con los principios de normalización, evitando redundancia de datos y garantizando consistencia en la información.

-- 5.1 Atributos de cada entidad

===================
=     Usuario     =
===================
user_id (PK)
nombre
correo_electronico
contrasena
saldo
currency_id (FK)
fecha_creacion (agregada en Lección 4)

===================
=      Moneda     =
===================
currency_id (PK)
currency_name
currency_symbol

===================
=   Transaccion   =
===================
transaction_id (PK)
sender_user_id (FK)
receiver_user_id (FK)
currency_id (FK)
importe
transaction_date

-- 5.2 Script utilizado para diagrama MER en QuickDBD

usuario
-
user_id int PK
nombre varchar(50)
correo_electronico varchar(50) unique
contrasena varchar(50)
saldo decimal(10,2)
fecha_creacion datetime 
currency_id int FK >- moneda.currency_id


moneda
-
currency_id int PK
currency_name varchar(50)
currency_symbol varchar(10)


transaccion
-
transaction_id int PK
sender_user_id int FK >- usuario.user_id
receiver_user_id int FK >- usuario.user_id
currency_id int FK >- moneda.currency_id
importe decimal(10,2)
transaction_date datetime



-- 5.3 Relaciones y Cardinalidades

Relación 1: Usuario — Moneda

Un usuario usa una moneda
Una moneda puede ser usada por muchos usuarios

Cardinalidad:
Moneda (1) -------- (N) Usuario

Relación 2: Usuario — Transaccion (como emisor)

Un usuario puede enviar muchas transacciones
Cada transacción tiene un solo emisor

Cardinalidad:
Usuario (1) -------- (N) Transaccion

Relación 3: Usuario — Transaccion (como receptor)

Un usuario puede recibir muchas transacciones
Cada transacción tiene un solo receptor

Cardinalidad:
Usuario (1) -------- (N) Transaccion

Relación 4: Moneda — Transaccion

Una moneda puede estar en muchas transacciones
Cada transacción usa una sola moneda

Cardinalidad:
Moneda (1) -------- (N) Transaccion


*/