-- Exploratory Data Analysis (EDA) of the Cleaned Layoffs Dataset
-- This script uses the cleaned 'layoffs_staging2' table to uncover trends and insights.

-- First, a quick preview of the cleaned data to ensure everything is correct.

SELECT *
FROM layoffs_staging2;

-- 1. High-Level Overview
-- Let's start with some basic maximums to understand the scale of the data.

-- Find the maximum number of employees laid off in a single event and the highest percentage (1 = 100%).

 
SELECT MAX(percentage_laid_off),MAX(total_laid_off)
FROM layoffs_staging2;

-- Look at companies that laid off 100% of their workforce, ordered by funds raised.
-- This can help identify well-funded companies that went under completely.

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions desc;

-- 2. Aggregate Analysis
-- Now, let's group the data to see which categories were most affected.

-- Total layoffs by company.

SELECT company,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- What is the date range of this dataset?

SELECT MIN(`date`),MAX(`date`)
FROM layoffs_staging2;

-- Total layoffs by industry.

SELECT industry,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Total layoffs by country.

SELECT country,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Total layoffs by year.

SELECT YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Total layoffs by the company's funding stage (e.g., Seed, Series A, IPO).

SELECT stage,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- 3. Deeper Dive into Funding and Layoff Percentages

-- Which companies have raised the most funds?

SELECT distinct company,MAX(funds_raised_millions)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- What is the maximum funding raised within each industry?

SELECT industry,MAX(funds_raised_millions)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- What is the maximum funding raised within each country?

SELECT country,MAX(funds_raised_millions)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- What is the average layoff percentage for each company stage?

SELECT stage, ROUND(AVG(percentage_laid_off),2)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- 4. Time-Series Analysis
-- Analyzing layoff trends over time.

-- Calculate the total layoffs per month and year.

SELECT SUBSTRING(`Date`,1,7) AS `MONTH`,SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`Date`,1,7) IS NOT NULL
GROUP BY MONTH
ORDER BY 1 ASC;

-- Calculate the rolling total of layoffs month by month using a CTE and a window function.
-- This helps to visualize the cumulative impact over time.

WITH rolling_total AS
(
SELECT SUBSTRING(`Date`,1,7) AS `MONTH`,SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`Date`,1,7) IS NOT NULL
GROUP BY MONTH
ORDER BY 1 ASC
)
SELECT `MONTH`,total_off,SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM rolling_total;


-- 5. Advanced Analysis: Ranking Companies by Year
-- Identifying the top companies by layoffs for each year in the dataset.


-- First, let's look at the total layoffs per company per year.

SELECT company,YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company,YEAR(`date`)
ORDER BY 3 desc;

-- Now, use CTEs and the DENSE_RANK() window function to rank the top 5 companies by layoffs each year.

-- CTE 1: Calculates the sum of layoffs for each company per year.

WITH Company_year (company, years, total_laid_off) AS 
(
SELECT company,YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company,YEAR(`date`)
), 
-- CTE 2: Ranks the companies within each year based on the total layoffs.
Comppany_Year_Rank AS
(SELECT *,DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) as Ranking
FROM Company_year
WHERE years IS NOT NULL
)
-- Final Selection: Display only the top 5 ranked companies for each year.
SELECT *
FROM Comppany_Year_Rank
WHERE Ranking <= 5;
