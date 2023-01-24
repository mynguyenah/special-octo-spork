SELECT *
FROM CasePhase2.dbo.DummyData

----- Data Preprocessing
-- Data quality Assessment
----- DATA CLEANING

--Handle missing values  4572 rows
SELECT *
INTO #DummyData
FROM CasePhase2.dbo.DummyData
WHERE TV != '' AND Radio != '' AND SocialMedia != '' AND Sales !=''

SELECT *
FROM #DummyData /* 4546 rows*/

-- Change data type from nvarchar to INT
ALTER TABLE #DummyData
ALTER COLUMN TV FLOAT;

ALTER TABLE #DummyData
ALTER COLUMN Radio FLOAT;

ALTER TABLE #DummyData
ALTER COLUMN SocialMedia FLOAT;

ALTER TABLE #DummyData
ALTER COLUMN Sales FLOAT;

SELECT DISTINCT Influencer
FROM #DummyData;


-- Exploratory Data
-- Total sales group by Influencer : 
SELECT Influencer, SUM(Sales) AS total_sales
FROM #DummyData
GROUP BY Influencer 
ORDER BY total_sales DESC
/*MICRO Influencer get the most total sales in all promotion package 1/4, the amount of people is 1148 2/4
Mega has more 4 more influencer than Nano, the sales is lower */


SELECT *
FROM #DummyData 
-- Count Influnencer
SELECT
	SUM(CASE WHEN Influencer = 'Macro' THEN 1 ELSE 0 END) AS count_macro, /* 1112*/
	SUM(CASE WHEN Influencer = 'Nano' THEN 1 ELSE 0 END) AS count_nano, /*1134*/
	SUM(CASE WHEN Influencer = 'Mega' THEN 1 ELSE 0 END) AS count_mega, /*1152*/
	SUM(CASE WHEN Influencer = 'Micro' THEN 1 ELSE 0 END) AS count_micro /*1148*/
FROM #DummyData

-- Find Mean, Median, Mode of Mega & Micro
SELECT
	AVG(Sales) AS avg_mega_sales,
	MAX(Sales) AS max_mega_sales,
	MIN(Sales) AS min_mega_sales
	--PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Sales) OVER() AS Median_mega_sales
FROM #DummyData
WHERE Influencer = 'Micro'
-- Find Standard deviation of Mega & Micro
SELECT
	STDEV(Sales)
FROM #DummyData
WHERE Influencer = 'Micro'


-- Create #ShortDummyData
SELECT
	Expense,
	Influencer,
	Sales
INTO #ShortDummyData
FROM
(
		SELECT *,
			(TV + Radio + SocialMedia) AS Expense
		FROM #DummyData
) tbl

SELECT MAX(Expense), MIN(Expense)
--SELECT *
FROM #ShortDummyData

-- Create Micro Influencer : Amount of expense, number of occurence and AVG
SELECT Expense, Sales_group
FROM
(
	SELECT
			*,
			CASE	
				WHEN Sales < 50 THEN '10-50'
				WHEN 100 > Sales AND Sales >= 50 THEN '50 -100'
				WHEN 150> Sales AND Sales >= 100 THEN '100 -150'
				ELSE '150+'
				END AS Sales_group
	FROM #ShortDummyData
	WHERE Influencer = 'Micro'
) t
pivot(
	COUNT(Expense)
	FOR Sales_group IN (
	[10-50],
	[50-100],
	[100-150],
	[150+])
	)
	AS pivot_tbl