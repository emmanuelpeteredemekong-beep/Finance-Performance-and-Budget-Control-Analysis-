

-- ==================== PROJECT WORK FLOW ==================== --

-- Data Source (Excel/Power Query, Cleaned) 
-- Data Validation
-- Data Modeling (Star Schema)
-- Data Population
-- Business Analysis
-- Power BI Reporting

						-- ==================== DATA VALIDATION ==================== --

-- Check Total Number Of Records

SELECT COUNT(*) AS Total_Records
FROM [dbo].[financial_performance];
GO

-- Check Duplicate Transaction_ID

SELECT [Journal_Entry_ID], COUNT(*) AS Duplicate_Count
FROM [dbo].[financial_performance]
GROUP BY [Journal_Entry_ID]
HAVING COUNT(*) >1;
GO

-- Check for Null Values in Key Identifiers and Dates

SELECT * 
FROM [dbo].[financial_performance]
WHERE [Journal_Entry_ID] IS NULL
	OR [Posting_Date] IS NULL
	OR [Counterparty_ID] IS NULL
	OR [Cost_Center] IS NULL
	OR [Tax_Code] IS NULL
	OR [Fiscal_Year] IS NULL;
GO

-- Check for Null Values in critical numberic fields

SELECT *
FROM [dbo].[financial_performance]
WHERE [Payment_Terms_Days] IS NULL
	OR [Exchange_Rate] IS NULL;
GO

-- Check Financial Values and Quantity

SELECT *
FROM [dbo].[financial_performance]
WHERE [Base_Amount_USD] IS NULL
	OR [Tax_Amount_USD] IS NULL
    OR [Budget_Allocated_USD] IS NULL
    OR [Budget_Allocated_USD] IS NULL;
GO

						-- ==================== DATA MODELING ==================== --

-- Dim Date

CREATE TABLE dbo.Dim_Date (
    Date_Key INT NOT NULL PRIMARY KEY,
    Posting_Date DATE NOT NULL,
    Fiscal_Year INT NOT NULL,
    Fiscal_Period NVARCHAR(50) NOT NULL,
    Day_Number INT NOT NULL,
    Day_Name NVARCHAR(50) NOT NULL,
    Month_Number INT NOT NULL,
    Month_Name NVARCHAR(50) NOT NULL,
    Quarter_Number INT NOT NULL,
    Quarter_Name CHAR(2) NOT NULL,
    Year_Number INT NOT NULL);
GO

-- Dim Company Organization

CREATE TABLE dbo.Dim_Company_Organization (
    Company_Entity_Key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Company_Entity NVARCHAR(50) NOT NULL,
    Region NVARCHAR(50) NOT NULL,
    Cost_Center NVARCHAR(50) NOT NULL,
    Department NVARCHAR(50) NOT NULL );
GO

-- Dim Account

CREATE TABLE dbo.Dim_Account (
    Account_Key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Account_Number INT NOT NULL,
    Account_Name NVARCHAR(50) NOT NULL,
    Account_Group NVARCHAR(50) NOT NULL,
    Sub_Ledger_Type NVARCHAR(50) NOT NULL );
GO

-- Dim Transaction Details

CREATE TABLE dbo.Dim_Transaction_Details (
    Transaction_Key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Transaction_Currency NVARCHAR(50) NOT NULL,
    Payment_Status NVARCHAR(50) NOT NULL,
    Payment_Terms_Days INT NOT NULL,
    Tax_Code NVARCHAR(50) NOT NULL,
    Audit_Status NVARCHAR(50) NOT NULL,
    Approved_By NVARCHAR(50) NOT NULL,
    Cash_Flow_Category NVARCHAR(50) NOT NULL );
GO

-- Dim Counterparty

CREATE TABLE dbo.Counterparty (
    Counterparty_Key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Counterparty_ID NVARCHAR(50) NOT NULL,
    Counterparty_Type NVARCHAR(50) NOT NULL);
GO

-- Fact Table


CREATE TABLE dbo.Fact_Table (
    Fact_Key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Journal_Entry_ID NVARCHAR(50) NOT NULL,
    Date_Key INT NOT NULL,
    Company_Entity_Key INT NOT NULL,
    Transaction_Key INT NOT NULL,
    Account_Key INT NOT NULL,
    Counterparty_Key INT NOT NULL,
    Debit_Credit_Indicator NVARCHAR(50) NOT NULL,
    Is_Posted BIT,
    ReconcilIation_Flag NVARCHAR(50) NOT NULL,
    Exchange_Rate DECIMAL(10,2) NOT NULL,
    Base_Amount_USD DECIMAL(10,2) NOT NULL,
    Local_Amount DECIMAL(10,2) NOT NULL,
    Tax_Amount_USD DECIMAL(10,2) NOT NULL,
    Budget_Allocation_USD DECIMAL(10,2) NOT NULL,
    Variance_To_Budget_USD DECIMAL(10,2) NOT NULL);
GO

						-- ==================== DATA POPULATION ==================== --

-- Insert Into Dim Date


-- 2. Populate it using only your unique transaction dates
INSERT INTO  [dbo].[Dim_Date] (
    Date_Key,
    Full_Date,
    Fiscal_Year,
    Fiscal_Period,
    Day_Number,
    Day_Name,
    Month_Number,
    Month_Name,
    Quarter_Number,
    Quarter_Name,
    Year_Number
)
SELECT DISTINCT
    -- DateKey format: YYYYMMDD
    CONVERT(INT, CONVERT(VARCHAR(8), Posting_Date, 112)) AS Date_Key,
    Posting_Date AS FullDate,
    YEAR(Posting_Date) AS Fiscal_Year,
    'P' + Right('0' + CAST(MONTH(Posting_Date) AS VARCHAR(2)),2) AS Fiscal_Period,
    DATEPART(WEEKDAY, Posting_Date) AS Day_Number,
    DATENAME(WEEKDAY, Posting_Date) AS Day_Name,
    DATEPART(MONTH, Posting_Date) AS Month_Number,
    DATENAME(MONTH, Posting_Date) AS MonthName,
    DATEPART(QUARTER, Posting_Date) AS Quarter_Number,
    'Q' + CAST(DATEPART(QUARTER, Posting_Date) AS CHAR(1)) AS Quarter_Name,
    DATEPART(YEAR, Posting_Date) AS Year_Number
FROM [dbo].[financial_performance] ;
GO

-- Insert Into Dim Company Organization


INSERT INTO dbo.Dim_Company_Organization (
    Company_Entity,
    Region,
    Cost_Center,
    Department
)
SELECT DISTINCT
    Company_Entity,
    Region,
    Cost_Center,
    Department
FROM [dbo].[financial_performance]
WHERE Company_Entity IS NOT NULL;
GO

-- Insert Into Dim Account

INSERT INTO dbo.Dim_Account (
    Account_Number,
    Account_Name,
    Account_Group,
    Sub_Ledger_Type
)
SELECT DISTINCT
    Account_Number,
    Account_Name,
    Account_Group,
    Sub_Ledger_Type
FROM [dbo].[financial_performance]
WHERE Account_Number IS NOT NULL ;
GO

-- Insert Into Dim Transaction Details

INSERT INTO dbo.Dim_Transaction_Details (
    Transaction_Currency,
    Payment_Status,
    Payment_Terms_Days,
    Tax_Code,
    Audit_Status,
    Approved_By,
    Cash_Flow_Category
)
SELECT DISTINCT
    Transaction_Currency,
    Payment_Status,
    Payment_Terms_Days,
    Tax_Code,
    Audit_Status,
    Approved_By,
    Cash_Flow_Category
FROM [dbo].[financial_performance];
GO

-- Insert Into Dim Counterparty

INSERT INTO dbo.Counterparty (
    Counterparty_ID,
    Counterparty_Type
)
SELECT DISTINCT
    Counterparty_ID,
    Counterparty_Type
FROM [dbo].[financial_performance]
WHERE Counterparty_ID IS NOT NULL;
GO

-- Insert Into Fact Table


INSERT INTO dbo.Fact_Table (
    Journal_Entry_ID,
    Date_Key,
    Company_Entity_Key,
    Account_Key,
    Transaction_Key,
    Counterparty_Key,
    Debit_Credit_Indicator,
    Is_Posted,
    ReconcilIation_Flag,
    Exchange_Rate,
    Base_Amount_USD,
    Local_Amount,
    Tax_Amount_USD,
    Budget_Allocation_USD,
    Variance_To_Budget_USD
)
SELECT DISTINCT
    fb.Journal_Entry_ID,
    CONVERT(INT, CONVERT(VARCHAR(8),fb.Posting_Date, 112)) AS Date_Key,
    dco.Company_Entity_Key,
    da.Account_Key,
    dtd.Transaction_Key,
    dc.Counterparty_Key,
    fb.Debit_Credit_Indicator,
    fb.Is_Posted,
    fb.ReconcilIation_Flag,
    fb.Exchange_Rate,
    fb.Base_Amount_USD,
    fb.Local_Amount,
    fb.Tax_Amount_USD,
    fb.Budget_Allocated_USD,
    fb.Variance_To_Budget_USD

FROM [dbo].[financial_performance] AS fb

LEFT JOIN [dbo].[Dim_Company_Organization] AS dco ON fb.[Company_Entity] = dco.[Company_Entity]
    AND fb.[Region] = dco.[Region]
    AND fb.[Cost_Center] = dco.[Cost_Center]
    AND fb.[Department] = dco.[Department]

LEFT JOIN [dbo].[Dim_Account] AS da ON fb.[Account_Number] = da.[Account_Number]
    AND fb.[Account_Name] = da.[Account_Name]
    AND fb.[Account_Group] = da.[Account_Group]
    AND fb.[Sub_Ledger_Type] = da.[Sub_Ledger_Type]

LEFT JOIN [dbo].[Dim_Transaction_Details] AS dtd ON fb.[Transaction_Currency] = dtd.[Transaction_Currency]
    AND fb.[Payment_Status] = dtd.[Payment_Status]
    AND fb.[Payment_Terms_Days] = dtd.[Payment_Terms_Days]
    AND fb.[Tax_Code] = dtd.[Tax_Code]
    AND fb.[Audit_Status] = dtd.[Audit_Status]
    AND fb.[Approved_By] = dtd.[Approved_By]
    AND fb.[Cash_Flow_Category] = dtd.[Cash_Flow_Category]

LEFT JOIN [dbo].[Counterparty] AS dc ON fb.[Counterparty_ID] = dc.[Counterparty_ID]
    AND fb.[Counterparty_Type] = dc.[Counterparty_Type]
GO

						-- ==================== BUSINESS ANALYSIS ==================== --

-- Key Performance Indicator (KPI) Analysis

-- Total Base Amount (USD)

SELECT SUM([Base_Amount_USD]) AS Total_Base_Amount
FROM [dbo].[Fact_Table];
GO

-- Total Budget Allocated (USD)

SELECT SUM([Budget_Allocation_USD]) AS Total_Budget_Allocated
FROM [dbo].[Fact_Table];
GO

-- Total Budget Variance (USD)

SELECT SUM([Variance_To_Budget_USD]) AS Total_Budget_Variance
FROM [dbo].[Fact_Table];
GO

-- Total Transactions

SELECT COUNT([Journal_Entry_ID]) AS Total_Transactions
FROM [dbo].[Fact_Table];
GO

						-- ==================== BUSINESS QUESTIONS ==================== --

-- Monthly Spending Trend
-- Business Question: How is company spending changing over time?

SELECT 
    YEAR(Posting_Date) AS Fiscal_Year,
    MONTH(Posting_Date) AS Month_Number,
    DATENAME(MONTH, Posting_Date) AS Month_Name,
    SUM([Base_Amount_USD]) AS Total_Base_Amount_USD
FROM [dbo].[financial_performance]
GROUP BY 
    YEAR(Posting_Date),
    MONTH(Posting_Date),
    DATENAME(MONTH, Posting_Date)
ORDER BY 
    Fiscal_Year,
    Month_Number;
GO

-- Budget vs. Actual Analysis by Department
-- Business Question: Which department are exceeding their allocated budgets, and which ones are staying within budget?

SELECT 
    [Department],
    SUM([Budget_Allocated_USD]) AS Total_Budget,
    SUM([Base_Amount_USD]) AS Total_Base_Amount,
    SUM([Variance_To_Budget_USD]) AS Total_Variance
FROM [dbo].[financial_performance]
GROUP BY  [Department]
ORDER BY Total_Variance ASC;
GO

-- Budget Variance by Account
-- Which account have the largest account variance?

SELECT
    [Account_Number],
    SUM([Variance_To_Budget_USD]) AS Total_Budgets_Variance
FROM [dbo].[financial_performance]
GROUP BY [Account_Number]
ORDER BY Total_Budgets_Variance ASC;
GO
 
-- Audit Completion
-- What percentage of transaction have been audited?

SELECT 
    COUNT(CASE WHEN Audit_Status = 'Audited' THEN 1 END) AS Audited_Transactions,
    COUNT(*) AS Total_Transactions
FROM [dbo].[financial_performance];
GO

