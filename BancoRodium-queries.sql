-- Obtener el nombre y el apellido de los empleados cuyo jefe sea “Isidore”
SELECT e.nombre, e.apellidos 
FROM empleado e 
WHERE e.es_jefe = 
(SELECT e.nºEmpleado FROM empleado e WHERE e.nombre = "Isidore");

-- Obtener los clientes que no tienen préstamos registrados
SELECT c.id_cliente, c.Nombre, c.Apellidos
FROM Cliente c
LEFT JOIN Prestamo p ON c.id_cliente = p.id_cliente
WHERE p.id_prestamo IS NULL;

-- Listar los clientes del banco que aún no se han abierto una cuenta
select c.Nombre, c.Apellidos 
from cliente c 
left join cuenta c2 on c.id_cliente = c2.id_cliente
where c2.nºcuenta is null;

-- Obtener los clientes que no tienen un empleado responsable asignado
SELECT c.id_cliente, c.Nombre, c.Apellidos, c.telefono
FROM Cliente c
LEFT JOIN Empleado e ON c.nºempleado = e.nºEmpleado
WHERE e.nºEmpleado IS NULL;

-- Obtener la cantidad total de clientes que son responsabilidad de cada empleado: 	 
SELECT e.nºEmpleado, e.Nombre, e.apellidos, COUNT(c.id_cliente) AS total_clientes
FROM Empleado e
LEFT JOIN Cliente c ON e.nºEmpleado = c.nºempleado 
GROUP BY e.nºEmpleado, e.Nombre, e.Apellidos;

-- Vista de empleados con sus nombres completos y el nombre completo de su jefe
CREATE VIEW empleados_con_jefe AS 
SELECT e.nºempleado, CONCAT(e.nombre, ' ', e.apellidos) AS nombre_completo
, CONCAT(j.nombre, ' ', j.apellidos) AS nombre_completo_jefe 
FROM empleado e 
INNER JOIN empleado j ON e.es_jefe = j.nºempleado;

-- Vista de cuentas con información de los clientes
CREATE VIEW cuentas_con_clientes AS 
SELECT c.nºcuenta, cl.nombre AS nombre_cliente,
cl.Apellidos AS apellido_cliente
FROM cuenta c INNER JOIN cliente cl ON c.id_cliente = cl.id_cliente;

-- FUNCION que devuelve el numero de clientes al cargo de un empleado a traves de su numero de empleado
DELIMITER &&
CREATE FUNCTION clientes_por_nºempleado (num INT)
RETURNS VARCHAR(150)
DETERMINISTIC
BEGIN
  DECLARE mensaje VARCHAR(150);
  DECLARE nombre_empleado VARCHAR(100);
  DECLARE apellidos_empleado VARCHAR(100);
  DECLARE num_clientes INT;

  SELECT e.nombre, e.apellidos, COUNT(c.id_cliente) INTO nombre_empleado, apellidos_empleado, num_clientes
  FROM cliente c INNER JOIN empleado e ON c.nºempleado = e.nºEmpleado 
  WHERE e.nºEmpleado = num
  GROUP BY e.nombre, e.apellidos;

  IF nombre_empleado IS NOT NULL THEN
    SET mensaje = CONCAT('El empleado ', nombre_empleado, ' ', apellidos_empleado, ' tiene ', num_clientes, ' clientes a su cargo.');
  ELSE
    SET mensaje = 'No se encontró ningún empleado con ese número.';
  END IF;

  RETURN mensaje;
END &&
DELIMITER ;
SELECT clientes_por_nºempleado(35);

-- FUNCION que devuelve el total del saldo entre todas las cuentas asociadas a un cliente por su id
DELIMITER &&
CREATE FUNCTION obtener_saldo_total_cliente(cliente_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE saldo_total INT;

  SELECT SUM(saldo) INTO saldo_total
  FROM cuenta
  WHERE id_cliente = cliente_id;

  RETURN saldo_total;
end&&
DELIMITER ;
select obtener_saldo_total_cliente(65);

-- PROCEDIMIENTO que devuelve toda la informacion de un cliente a traves de su id y el numero de
-- prestamos que ha pedido.
delimiter &&
create procedure mostrar_info_cliente(in id INT)
begin
select c.id_cliente, c.Nombre , c.Apellidos, count(p.id_prestamo)
from prestamo p inner join cliente c on p.id_cliente = c.id_cliente where c.id_cliente = id
group by c.id_cliente, c.Nombre, c.Apellidos;
end &&
delimiter ;
call mostrar_info_cliente(57);

-- PROCEDIMIENTO para generar una tabla con la carga de trabajo que tiene cada empleado.
DELIMITER &&
CREATE PROCEDURE generar_informe_carga_trabajo()
BEGIN
  DECLARE empleado_id INT;
  DECLARE empleado_nombre VARCHAR(100);
  DECLARE num_clientes INT;
  DECLARE done INT DEFAULT FALSE;

  -- Crear cursor para recorrer la tabla de empleados
  DECLARE cur CURSOR FOR SELECT e.nºEmpleado, e.nombre FROM empleado e;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  -- Crear tabla temporal para almacenar el informe
  CREATE TEMPORARY TABLE informe_carga_trabajo (
    empleado_id INT,
    empleado_nombre VARCHAR(100),
    num_clientes INT
  );

  -- Abrir cursor y recorrer la tabla de empleados
  OPEN cur;

  read_loop: LOOP
    FETCH cur INTO empleado_id, empleado_nombre;
    IF done THEN
      LEAVE read_loop;
    END IF;

    -- Contar el número de clientes asociados al empleado
    SET num_clientes = (SELECT COUNT(*) FROM cliente c WHERE c.nºempleado = empleado_id);

    -- Insertar datos en la tabla temporal
    INSERT INTO informe_carga_trabajo (empleado_id, empleado_nombre, num_clientes)
    VALUES (empleado_id, empleado_nombre, num_clientes);
  END LOOP;

  -- Cerrar cursor
  CLOSE cur;

  -- Mostrar el informe de carga de trabajo
  SELECT * FROM informe_carga_trabajo;

  -- Eliminar la tabla temporal
  DROP TABLE informe_carga_trabajo;
end&&
DELIMITER ;
CALL generar_informe_carga_trabajo();
-- PROCEDIMIENTO que usa la funcion obtener_saldo_total_cliente() para devolver una tabla temporal que nos dice
-- el id del cliente y el saldo total de todas sus cuentas.
DELIMITER &&
CREATE PROCEDURE generar_informe_saldos_totales()
BEGIN
  DECLARE cliente_id INT;
  DECLARE saldo_total INT;
  DECLARE done INT DEFAULT FALSE;

  -- Crear cursor para recorrer la tabla de clientes
  DECLARE cur CURSOR FOR SELECT id_cliente FROM cliente;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  -- Crear tabla temporal para almacenar el informe
  CREATE TABLE informe_saldos_totales (
    cliente_id INT,
    saldo_total INT
  );

  -- Abrir cursor y recorrer la tabla de clientes
  OPEN cur;

  read_loop: LOOP
    FETCH cur INTO cliente_id;
    IF done THEN
      LEAVE read_loop;
    END IF;

    -- Obtener el saldo total del cliente utilizando la función obtener_saldo_total_cliente
    SET saldo_total = obtener_saldo_total_cliente(cliente_id);

    -- Insertar datos en la tabla temporal
    INSERT INTO informe_saldos_totales (cliente_id, saldo_total)
    VALUES (cliente_id, saldo_total);
  END LOOP;

  -- Cerrar cursor
  CLOSE cur;

  -- Mostrar el informe de saldos totales
  SELECT * FROM informe_saldos_totales;

  -- Eliminar la tabla temporal
  DROP TABLE informe_saldos_totales;
end&&
DELIMITER ;
call generar_informe_saldos_totales();

-- TRIGGER para copiar los datos al insertar una nueva transsaccio en una tabla historial
DELIMITER &&
DROP TRIGGER IF EXISTS trigger_notificar_pago&&
CREATE TRIGGER trigger_notificar_pago
AFTER INSERT 
ON transaccion FOR EACH ROW
begin
	insert into historial_transacciones (codigo_cuenta_paga ,fecha_pago, total, codigo_cuenta_recibe) values
	(new.codigo_cuenta_paga, new.fecha_pago, new.total, new.cod_cuenta_destino);
end&&
-- TRIGGER para hacer una copia de los datos al borrar un prestamo en una tabla historial
Delimiter &&
DROP TRIGGER IF EXISTS trigger_historico&&
CREATE TRIGGER trigger_historico
AFTER DELETE  
ON prestamo FOR EACH ROW
begin
	insert into historial_prestamo values
	(old.id_cliente, old.plazo, old.id_prestamo, old.cantidad, now());
end&&