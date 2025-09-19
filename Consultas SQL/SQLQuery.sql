
-- EXPLORACION BÁSICA

-- Listar cantidad total de clientes
SELECT COUNT(CustomerID) AS Recuento_Clientes
FROM dbo.Customers;


-- Agrupar clientes por país y contar cuantos hay por cada uno
SELECT COUNT(CustomerID) AS Recuento_Clientes, Country 
FROM dbo.Customers
GROUP BY Country;


-- Agrupar TOP 5 clientes por país y hacer recuento de ellos
SELECT TOP 5 COUNT(CustomerID) AS Recuento_Clientes, Country
FROM dbo.Customers
GROUP BY Country
ORDER BY Recuento_Clientes DESC;


-- Contar cantidad de productos activos (no discontinuados) vs discontinuados

SELECT COUNT(Discontinued) AS CONTINUADOS
FROM dbo.Products
WHERE (Discontinued = 0);

SELECT COUNT(Discontinued) AS DISCONTINUADOS
FROM dbo.Products
WHERE (Discontinued = 1);

-- Ver productos agrupados por categoría y cuántos hay en cada una.

SELECT 
    dbo.Categories.CategoryName,
    COUNT(dbo.Products.ProductID) AS CantProductos
FROM dbo.Products
INNER JOIN dbo.Categories ON dbo.Categories.CategoryID = dbo.Products.CategoryID
GROUP BY dbo.Categories.CategoryName;

-- Promedio de precios por categoría

SELECT
    AVG(dbo.Products.UnitPrice) AS AVG_Precio,
    dbo.Categories.CategoryName,
    COUNT(dbo.Products.ProductID) AS CantProductos
FROM dbo.Products
INNER JOIN dbo.Categories ON dbo.Categories.CategoryID = dbo.Products.CategoryID
GROUP BY dbo.Categories.CategoryName

-- Cantidad de empleados activos.

SELECT COUNT(EmployeeID) AS Cant_Empleados
FROM dbo.Employees;

-- distribución de empleados por país/ciudad

SELECT
    COUNT(EmployeeID) AS Cant_Empleados,
    Country
FROM dbo.Employees
GROUP BY Country;

SELECT
    COUNT(EmployeeID) AS Cant_Empleados,
    City
FROM dbo.Employees
GROUP BY City;

-- Identificar la estructura jerárquica (quién reporta a quién).

SELECT
    EmployeeID,
    FirstName,
    ReportsTo
FROM dbo.Employees;


-- Rango de fechas de pedidos (pedido más antiguo y más reciente).

SELECT 
    TOP 1 LEFT(OrderDate,11)
FROM dbo.Orders;

SELECT 
    TOP 1 LEFT(OrderDate,11)
FROM dbo.Orders
ORDER BY OrderDate DESC;

-- Contar cuántos pedidos se hicieron por año.

SELECT
    YEAR(OrderDate) AS año,
    COUNT(OrderID) AS tot_Pedidos
FROM dbo.Orders
GROUP BY YEAR(OrderDate)
ORDER BY año;

-----------------------------------------------------

-- ANÁLISIS DE VENTAS

-- Ventas

SELECT 
    YEAR(O.ShippedDate) AS Año,
    ROUND(SUM(OD.UnitPrice * OD.Quantity * (1 - OD.Discount)),2,2) AS VentasTotales
FROM dbo.[Order Details] OD
INNER JOIN dbo.Orders O ON O.OrderID = OD.OrderID
WHERE O.ShippedDate IS NOT NULL
GROUP BY YEAR(O.ShippedDate)
ORDER BY Año;

-- Clientes

SELECT 
    TOP 10 C.CompanyName,
    ROUND(SUM(OD.UnitPrice * OD.Quantity * (1 - OD.Discount)),2,2) AS VentasTotales
FROM dbo.Customers C
INNER JOIN dbo.Orders O ON C.CustomerID = O.CustomerID
INNER JOIN dbo.[Order Details] OD ON O.OrderID = OD.OrderID
WHERE O.ShippedDate IS NOT NULL
GROUP BY C.CompanyName
ORDER BY VentasTotales DESC;

-- Productos

SELECT TOP 10 
    P.ProductName,
    SUM(OD.UnitPrice * OD.Quantity * (1 - OD.Discount)) AS TotalIngresos
FROM dbo.[Order Details] OD
INNER JOIN dbo.Products P ON P.ProductID = OD.ProductID
GROUP BY P.ProductName
ORDER BY TotalIngresos DESC;

-- Descuentos

SELECT 
    YEAR(O.OrderDate) AS Año,
    SUM(OD.UnitPrice * OD.Quantity * OD.Discount) AS TotalDescuentos
FROM dbo.[Order Details] OD
INNER JOIN dbo.Orders O ON O.OrderID = OD.OrderID
GROUP BY YEAR(O.OrderDate)
ORDER BY Año;

-- Porcentaje promedio de descuento por pedido.

SELECT 
    O.OrderID,
    AVG(OD.Discount) * 100 AS PromedioDescuento_PorPedido
FROM dbo.[Order Details] OD
INNER JOIN dbo.Orders O ON O.OrderID = OD.OrderID
GROUP BY O.OrderID
ORDER BY PromedioDescuento_PorPedido DESC;

-- porcentaje promedio de descuento por producto.

SELECT 
    P.ProductName,
    AVG(OD.Discount) * 100 AS PromedioDescuento_PorProducto
FROM dbo.[Order Details] OD
INNER JOIN dbo.Products P ON P.ProductID = OD.ProductID
GROUP BY P.ProductName
ORDER BY PromedioDescuento_PorProducto DESC;

-- Tiempo de entrega de pedidos (OrderDate vs ShippedDate).

SELECT 
    O.OrderID,
    DATEDIFF(DAY, O.OrderDate, O.ShippedDate) AS DiasEntrega
FROM dbo.Orders O
WHERE O.ShippedDate IS NOT NULL;

-- Obtener promedio y máximo de días de entrega por año.

SELECT 
    YEAR(O.OrderDate) AS Año,
    AVG(DATEDIFF(DAY, O.OrderDate, O.ShippedDate)) AS PromedioDias,
    MAX(DATEDIFF(DAY, O.OrderDate, O.ShippedDate)) AS MaximoDias
FROM dbo.Orders O
WHERE O.ShippedDate IS NOT NULL
GROUP BY YEAR(O.OrderDate)
ORDER BY Año;
