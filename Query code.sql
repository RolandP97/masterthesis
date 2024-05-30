-- Q1 STD
SELECT
	fs.SalesOrderNumber,
	fs.OrderDateKey,
	fs.DueDateKey,
	fs.ShipDateKey,
	fs.SalesAmount,
	fs.TaxAmt,
	fs.Freight,
	fs.TotalProductCost,
	fs.UnitPriceDiscountPct,
	c.FirstName AS CustomerFirstName,
	c.LastName AS CustomerLastName,
	c.EmailAddress AS CustomerEmail,
	c.Phone AS CustomerPhone,
	e.FirstName AS SalesPersonFirstName,
	e.LastName AS SalesPersonLastName,
	e.Title AS SalesPersonTitle,
	p.ProductKey,
	p.EnglishProductName,
	ps.EnglishProductSubcategoryName AS ProductSubcategoryName,
	pc.EnglishProductCategoryName,
	g.City AS ShipToCity,
	g.StateProvinceName AS ShipToState,
	d.FullDateAlternateKey AS OrderDate,
	d.CalendarYear AS OrderYear
FROM
	FactResellerSales fs
JOIN 
    DimEmployee e ON
	fs.EmployeeKey = e.EmployeeKey
JOIN 
    DimProduct p ON
	fs.ProductKey = p.ProductKey
JOIN 
    DimProductSubcategory ps ON
	p.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN 
    DimProductCategory pc ON
	ps.ProductCategoryKey = pc.ProductCategoryKey
JOIN 
    DimReseller dr ON
	fs.ResellerKey = dr.ResellerKey
JOIN 
    DimGeography g ON
	dr.GeographyKey = g.GeographyKey
JOIN 
    DimDate d ON
	fs.OrderDateKey = d.DateKey
JOIN 
    DimCustomer c ON
	g.GeographyKey = c.GeographyKey
WHERE
	fs.OrderDate >= '2012-12-29 00:00:00.000'
	AND fs.SalesAmount > 1000
ORDER BY
	fs.SalesOrderNumber;

-- Q1 OBT
SELECT
	SalesOrderNumber,
	ShipDateKey,
	SalesAmount,
	TaxAmt,
	Freight,
	TotalProductCost,
	UnitPriceDiscountPct,
	c.FirstName AS CustomerFirstName,
	c.LastName AS CustomerLastName,
	c.EmailAddress AS CustomerEmail,
	c.Phone AS CustomerPhone,
	e.FirstName AS SalesPersonFirstName,
	e.LastName AS SalesPersonLastName,
	e.Title AS SalesPersonTitle,
	ProductKey,
	EnglishProductName,
	EnglishProductSubcategoryName AS ProductSubcategoryName,
	EnglishProductCategoryName,
	City AS ShipToCity,
	StateProvinceName AS ShipToState,
	FullDateAlternateKey AS OrderDate,
	CalendarYear AS OrderYear
FROM
	FactResellerSales_OBT fs
JOIN 
    DimEmployee e ON
	fs.EmployeeKey = e.EmployeeKey
JOIN 
    DimReseller dr ON
	fs.ResellerKey = dr.ResellerKey
JOIN 
    DimGeography g ON
	dr.GeographyKey = g.GeographyKey
JOIN 
    DimDate d ON
	fs.ShipDateKey = d.DateKey
JOIN 
    DimCustomer c ON
	g.GeographyKey = c.GeographyKey
WHERE
	fs.OrderDate >= '2012-12-29 00:00:00.000'
	AND fs.SalesAmount > 1000
ORDER BY
	fs.SalesOrderNumber;
	
-- Q1 CIS
USE [AdventureWorksDW2022]
GO
CREATE NONCLUSTERED INDEX [q1obt]
ON [dbo].[FactResellerSales_OBT] ([SalesAmount],[OrderDate])
INCLUDE ([EmployeeKey],[ResellerKey],[ShipDateKey],[ProductKey],[SalesOrderNumber],[UnitPriceDiscountPct],[TotalProductCost],[TaxAmt],[Freight],[EnglishProductName],[EnglishProductSubcategoryName],[EnglishProductCategoryName])
GO

-- Q2 STD
WITH SalesSummary AS (
    SELECT 
        fs.OrderDateKey,
        fs.SalesAmount,
        pc.EnglishProductCategoryName,
        SUM(fs.SalesAmount) OVER (PARTITION BY pc.EnglishProductCategoryName ORDER BY fs.OrderDateKey) AS RunningTotalSales,
        AVG(fs.SalesAmount) OVER (PARTITION BY pc.EnglishProductCategoryName ORDER BY fs.OrderDateKey) AS RunningAverageSales,
        ROW_NUMBER() OVER (PARTITION BY pc.EnglishProductCategoryName ORDER BY fs.OrderDateKey) AS RowNum
    FROM 
        FactResellerSales fs
    JOIN 
        DimProduct p ON fs.ProductKey = p.ProductKey
    JOIN 
        DimProductSubcategory ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
    JOIN 
        DimProductCategory pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
)
SELECT 
    OrderDateKey,
    EnglishProductCategoryName,
    SalesAmount,
    RunningTotalSales,
    RunningAverageSales,
    RowNum,
    MAX(SalesAmount) OVER (PARTITION BY EnglishProductCategoryName) AS MaxSalesAmount,
    MIN(SalesAmount) OVER (PARTITION BY EnglishProductCategoryName) AS MinSalesAmount
FROM 
    SalesSummary
WHERE 
    OrderDateKey > '20121229'
ORDER BY 
    EnglishProductCategoryName, OrderDateKey;


-- Q2 OBT

set statistics time on;
WITH SalesSummary AS (
    SELECT 
		ShipDateKey,
        SalesAmount,
        EnglishProductCategoryName,
        SUM(SalesAmount) OVER (PARTITION BY EnglishProductCategoryName ORDER BY ShipDateKey) AS RunningTotalSales,
        AVG(SalesAmount) OVER (PARTITION BY EnglishProductCategoryName ORDER BY ShipDateKey) AS RunningAverageSales,
        ROW_NUMBER() OVER (PARTITION BY EnglishProductCategoryName ORDER BY ShipDateKey) AS RowNum
    FROM 
        FactResellerSales_OBT fs
)
SELECT 
    ShipDateKey,
    EnglishProductCategoryName,
    SalesAmount,
    RunningTotalSales,
    RunningAverageSales,
    RowNum,
    MAX(SalesAmount) OVER (PARTITION BY EnglishProductCategoryName) AS MaxSalesAmount,
    MIN(SalesAmount) OVER (PARTITION BY EnglishProductCategoryName) AS MinSalesAmount
FROM 
    SalesSummary
WHERE 
    ShipDateKey > '20121229'
ORDER BY 
    EnglishProductCategoryName, ShipDateKey;
	
-- Q3 STD

WITH MonthlySales AS (
    SELECT 
        pc.EnglishProductCategoryName,
        YEAR(d.FullDateAlternateKey) AS SalesYear,
        MONTH(d.FullDateAlternateKey) AS SalesMonth,
        SUM(fs.SalesAmount) AS MonthlySales,
        AVG(SUM(fs.SalesAmount)) OVER (PARTITION BY pc.EnglishProductCategoryName, YEAR(d.FullDateAlternateKey)) AS AvgMonthlySales
    FROM 
        FactResellerSales fs
    JOIN 
        DimProduct p ON fs.ProductKey = p.ProductKey
    JOIN 
        DimProductSubcategory ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
    JOIN 
        DimProductCategory pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
    JOIN 
        DimDate d ON fs.OrderDateKey = d.DateKey
    WHERE 
        YEAR(d.FullDateAlternateKey) = 2012
    GROUP BY 
        pc.EnglishProductCategoryName, YEAR(d.FullDateAlternateKey), MONTH(d.FullDateAlternateKey)
),
Deviations AS (
    SELECT 
        EnglishProductCategoryName,
        SalesYear,
        SalesMonth,
        MonthlySales,
        AvgMonthlySales,
        ABS(MonthlySales - AvgMonthlySales) / AvgMonthlySales AS SalesDeviation
    FROM 
        MonthlySales
    WHERE 
        ABS(MonthlySales - AvgMonthlySales) / AvgMonthlySales > 0.1
)
SELECT 
    EnglishProductCategoryName,
    SalesYear,
    SalesMonth,
    MonthlySales,
    AvgMonthlySales,
    SalesDeviation
FROM 
    Deviations
ORDER BY 
    SalesDeviation DESC;
	
	
-- Q3 OBT

WITH MonthlySales AS (
    SELECT 
        EnglishProductCategoryName,
        YEAR(d.FullDateAlternateKey) AS SalesYear,
        MONTH(d.FullDateAlternateKey) AS SalesMonth,
        SUM(SalesAmount) AS MonthlySales,
        AVG(SUM(SalesAmount)) OVER (PARTITION BY EnglishProductCategoryName, YEAR(FullDateAlternateKey)) AS AvgMonthlySales
    FROM 
        FactResellerSales_OBT fs
    JOIN 
        DimDate d ON fs.ShipDateKey = d.DateKey
    WHERE 
        YEAR(d.FullDateAlternateKey) = 2012
    GROUP BY 
        EnglishProductCategoryName, YEAR(d.FullDateAlternateKey), MONTH(d.FullDateAlternateKey)
),
Deviations AS (
    SELECT 
        EnglishProductCategoryName,
        SalesYear,
        SalesMonth,
        MonthlySales,
        AvgMonthlySales,
        ABS(MonthlySales - AvgMonthlySales) / AvgMonthlySales AS SalesDeviation
    FROM 
        MonthlySales
    WHERE 
        ABS(MonthlySales - AvgMonthlySales) / AvgMonthlySales > 0.1
)
SELECT 
    EnglishProductCategoryName,
    SalesYear,
    SalesMonth,
    MonthlySales,
    AvgMonthlySales,
    SalesDeviation
FROM 
    Deviations
ORDER BY 
    SalesDeviation DESC;