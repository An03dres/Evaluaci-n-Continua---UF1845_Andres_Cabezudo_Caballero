-- Calcula el total de ventas para cada producto, ordenado de mayor a menor
SELECT PR.id_producto, PR.nombre, SUM(DP.cantidad * PR.precio) AS total_ventas
FROM Productos PR
JOIN Detalles_Pedidos DP ON PR.id_producto = DP.id_producto
GROUP BY PR.id_producto, PR.nombre
ORDER BY total_ventas DESC;


-- Identifica el último pedido realizado por cada cliente
SELECT P.id_cliente, C.nombre, P.id_pedido, P.fecha_pedido
FROM Pedidos P
JOIN Clientes C ON P.id_cliente = C.id_cliente
WHERE P.fecha_pedido = (
    SELECT MAX(P2.fecha_pedido)
    FROM Pedidos P2
    WHERE P2.id_cliente = P.id_cliente
);

-- Total de pedidos realizados por clientes en cada ciudad
SELECT C.ciudad, COUNT(P.id_pedido) AS numero_de_pedidos
FROM Pedidos P
JOIN Clientes C ON P.id_cliente = C.id_cliente
GROUP BY C.ciudad;


-- Lista  de todos los productos que nunca han sido parte de un pedido
SELECT PR.id_producto, PR.nombre
FROM Productos PR
LEFT JOIN Detalles_Pedidos DP ON PR.id_producto = DP.id_producto
WHERE DP.id_producto IS NULL;


-- Encuentra los productos más vendidos en términos de cantidad total vendida
SELECT PR.id_producto, PR.nombre, SUM(DP.cantidad) AS cantidad_vendida
FROM Productos PR
JOIN Detalles_Pedidos DP ON PR.id_producto = DP.id_producto
GROUP BY PR.id_producto, PR.nombre
ORDER BY cantidad_vendida DESC;


-- Los clientes que han realizado compras en más de una categoría de producto
SELECT C.id_cliente, C.nombre, COUNT(DISTINCT PR.categoría) AS categorias_compradas
FROM Pedidos P
JOIN Detalles_Pedidos DP ON P.id_pedido = DP.id_pedido
JOIN Productos PR ON DP.id_producto = PR.id_producto
JOIN Clientes C ON P.id_cliente = C.id_cliente
GROUP BY C.id_cliente, C.nombre
HAVING categorias_compradas > 1;


-- Muestra las ventas totales agrupadas por mes y año
SELECT YEAR(P.fecha_pedido) AS año, MONTH(P.fecha_pedido) AS mes, SUM(DP.cantidad * PR.precio) AS ventas_totales
FROM Pedidos P
JOIN Detalles_Pedidos DP ON P.id_pedido = DP.id_pedido
JOIN Productos PR ON DP.id_producto = PR.id_producto
WHERE P.estado = 'Entregado'
GROUP BY año, mes
ORDER BY año, mes;


-- Calcula la cantidad promedio de productos por pedido
SELECT AVG(cantidad_productos) AS promedio_productos_por_pedido
FROM (
    SELECT P.id_pedido, SUM(DP.cantidad) AS cantidad_productos
    FROM Pedidos P
    JOIN Detalles_Pedidos DP ON P.id_pedido = DP.id_pedido
    GROUP BY P.id_pedido
) subconsulta;


-- Clientes que han realizado pedidos en más de una ocasión
SELECT C.id_cliente, C.nombre, COUNT(P.id_pedido) AS numero_de_pedidos
FROM Clientes C
JOIN Pedidos P ON C.id_cliente = P.id_cliente
GROUP BY C.id_cliente, C.nombre
HAVING numero_de_pedidos > 1;


-- Calcula el tiempo promedio que pasa entre pedidos para cada cliente
SELECT id_cliente, AVG(DATEDIFF(proximo_pedido, fecha_pedido)) AS tiempo_promedio_dias
FROM (
    SELECT id_cliente, fecha_pedido,
           LEAD(fecha_pedido) OVER (PARTITION BY id_cliente ORDER BY fecha_pedido) AS proximo_pedido
    FROM Pedidos
) subconsulta
WHERE proximo_pedido IS NOT NULL
GROUP BY id_cliente;
