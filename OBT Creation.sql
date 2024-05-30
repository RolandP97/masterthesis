WITH bigtable AS (
SELECT
	T1.EmployeeKey,
	T1.ResellerKey,
	T1.ShipDateKey,
	T1.ProductKey,
	T1.SalesOrderNumber,
	T1.SalesOrderLineNumber,
	T1.RevisionNumber,
	T1.OrderQuantity,
	T1.UnitPrice,
	T1.ExtendedAmount,
	T1.UnitPriceDiscountPct,
	T1.DiscountAmount,
	T1.ProductStandardCost,
	T1.TotalProductCost,
	T1.SalesAmount,
	T1.TaxAmt,
	T1.Freight,
	T1.CarrierTrackingNumber,
	T1.CustomerPONumber,
	t1.OrderDate,
	t1.DueDate,
	t1.ShipDate,
	dp.ProductAlternateKey,
	dp.ProductSubcategoryKey,
	dp.WeightUnitMeasureCode,
	dp.SizeUnitMeasureCode,
	dp.EnglishProductName,
	dp.SpanishProductName,
	dp.FrenchProductName,
	dp.StandardCost,
	dp.FinishedGoodsFlag,
	dp.Color,
	dp.SafetyStockLevel,
	dp.ReorderPoint,
	dp.SafetyStockLevel as dp_safetystock,
	dp.ListPrice,
	dp.[Size],
	dp.SizeRange,
	dp.Weight,
	dp.DaysToManufacture,
	dp.ProductLine as dp_productline,
	dp.DealerPrice,
	dp.Class,
	dp.[Style],
	dp.ModelName,
	dp.LargePhoto,
	dp.EnglishDescription,
	dp.FrenchDescription,
	dp.ChineseDescription,
	dp.ArabicDescription,
	dp.HebrewDescription,
	dp.ThaiDescription,
	dp.GermanDescription,
	dp.JapaneseDescription,
	dp.TurkishDescription,
	dp.StartDate as dp_startdate,
	dp.EndDate as dp_enddate,
	dp.[Status] as dp_status,
	dr.ResellerAlternateKey,
	dr.Phone as dr_phone,
	dr.BusinessType,
	dr.ResellerName,
	dr.NumberEmployees,
	dr.OrderFrequency,
	dr.OrderMonth,
	dr.FirstOrderYear,
	dr.LastOrderYear,
	dr.ProductLine as dr_productline,
	dr.AddressLine1 as dr_address1,
	dr.AddressLine2 as dr_address2,
	dr.AnnualSales,
	dr.BankName,
	dr.MinPaymentType,
	dr.MinPaymentAmount,
	dr.AnnualRevenue,
	dr.YearOpened,
	dst.SalesTerritoryAlternateKey,
	dst.SalesTerritoryRegion,
	dst.SalesTerritoryCountry,
	dst.SalesTerritoryGroup,
	dst.SalesTerritoryImage,
	dpsc.EnglishProductSubcategoryName,
	dpsc.FrenchProductSubcategoryName,
	dpsc.SpanishProductSubcategoryName,
	dpc.EnglishProductCategoryName,
	dpc.FrenchProductCategoryName,
	dpc.SpanishProductCategoryName
FROM
	FactResellerSales t1
LEFT JOIN DimProduct dp  ON
	t1.ProductKey = dp.ProductKey 
LEFT JOIN DimReseller dr on
	t1.ResellerKey = dr.ResellerKey
LEFT JOIN DimSalesTerritory dst ON
	t1.SalesTerritoryKey = dst.SalesTerritoryKey 
LEFT JOIN DimGeography dg ON 
	dr.GeographyKey = dg.GeographyKey
LEFT JOIN DimProductSubCategory dpsc ON
	dpsc.ProductCategoryKey = dp.ProductKey
LEFT JOIN DimProductCategory dpc ON
	dpc.ProductCategoryKey = dpsc.ProductCategoryKey
LEFT JOIN DimDate dd ON
	dd.DateKey = t1.ShipDateKey
	)
SELECT * INTO FactResellerSales_OBT FROM bigtable;