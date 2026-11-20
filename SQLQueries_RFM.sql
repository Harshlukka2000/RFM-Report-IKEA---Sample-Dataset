--use Ecommercecustomeranalytics;

--select count(1) from [dbo].[Year_2009_2010]
--select count(1) from [dbo].[Year_2010_2011]

-- COMBINE BOTH YEARS AND CONVERT TYPES SAFELY

SELECT
    Invoice,
    StockCode,
    Description,
    Quantity,

    COALESCE(
        TRY_CONVERT(datetime2, InvoiceDate, 120),
        TRY_CONVERT(datetime2, InvoiceDate, 105)
    ) AS InvoiceDate,

    TRY_CONVERT(decimal(10,2), Price) AS Price,

    Customer_ID,
    Country,
    '2009-2010' AS SourceSheet

INTO dbo.RetailCombined

FROM dbo.[Year_2009_2010]

UNION ALL

SELECT
    Invoice,
    StockCode,
    Description,
    Quantity,

    COALESCE(
        TRY_CONVERT(datetime2, InvoiceDate, 120),
        TRY_CONVERT(datetime2, InvoiceDate, 105)
    ) AS InvoiceDate,

    TRY_CONVERT(decimal(10,2), Price) AS Price,

    Customer_ID,
    Country,
    '2010-2011' AS SourceSheet

FROM dbo.[Year_2010_2011];

select * from [dbo].[RetailCleaned]

-- DEDUPLICATE AND PRODUCE THE FINAL CLEANED TABLE

WITH Deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY
                Invoice,
                StockCode,
                Description,
                Quantity,
                InvoiceDate,
                Price,
                Customer_ID,
                Country
            ORDER BY (SELECT NULL)
        ) AS RowNum
    FROM dbo.RetailCombined
)

SELECT
    Invoice,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    Price,
    Customer_ID,
    Country,
    SourceSheet
INTO dbo.RetailCleaned
FROM Deduped
WHERE RowNum = 1;