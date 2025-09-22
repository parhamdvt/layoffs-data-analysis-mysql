-- SQL Data Cleaning Script for Layoffs Dataset
-- This script takes raw data from the 'layoffs' table and performs several cleaning steps
-- to prepare it for analysis. The final clean data is stored in 'layoffs_staging2'.

-- 1. Create Staging Table and Copy Raw Data
-- It's a best practice to work on a copy (staging table) of the raw data to avoid accidental data loss.


SELECT *
FROM layoffs;

-- Create a table with the same schema as the original 'layoffs' table.

CREATE TABLE layoffs_staging 
LIKE layoffs;

SELECT *
FROM layoffs_staging;

-- Copy all data from the original table to the staging table.

INSERT layoffs_staging
SELECT * FROM 
layoffs;

-- 2. Remove Duplicates
-- The following steps identify and remove duplicate rows from the dataset.

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry,location, total_laid_off, percentage_laid_off, `date`,
stage,country,funds_raised_millions ) AS row_num
FROM layoffs_staging;

-- First, use a CTE and the ROW_NUMBER() window function to identify duplicate rows.
-- A row is considered a duplicate if it's identical to another across all specified columns.

WITH duplicate_cte AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry,location, total_laid_off, percentage_laid_off, `date`,
stage,country,funds_raised_millions ) AS row_num
FROM layoffs_staging
)

-- This query shows the rows that are duplicates (row_num > 1).

SELECT * 
FROM duplicate_cte
WHERE row_num >1;

-- Using this query, we can check a single example to determine its functionality.

SELECT *
FROM layoffs_staging
WHERE company = 'Cazoo';

-- To delete the duplicates, we create a new table that includes the 'row_num' column.
-- This allows us to easily filter and remove the unwanted rows.

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Insert data from the staging table into the new table, including the row number.

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry,location, total_laid_off, percentage_laid_off, `date`,
stage,country,funds_raised_millions ) AS row_num
FROM layoffs_staging;

-- Delete all rows where 'row_num' is greater than 1, effectively removing all duplicates.

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

-- 3. Standardize Data
-- This section cleans up inconsistencies in the text fields.

-- Trim leading/trailing whitespace from company names for consistency.

SELECT company, TRIM(company)
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET company = TRIM(company);

-- Standardize industry names by grouping similar entries (e.g., 'Crypto', 'Crypto Currency').


SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;


SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';



UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Clean up country names by removing trailing periods.

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT country
FROM layoffs_staging2
WHERE country LIKE 'United States%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
Where country LIKE 'United States%';

-- 4. Correct Data Types
-- Convert columns to their appropriate data types for better performance and analysis.

-- Convert the 'date' column from a text/string format to a standard DATE format.

SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 5. Handle Null and Blank Values
-- This section addresses missing data in the 'industry' column.

-- Set empty strings in the 'industry' column to NULL to make them easier to work with.

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry LIKE 'Bally%';

-- Populate NULL industry fields by looking for other records with the same company name that have a non-NULL industry.
-- This is useful for companies that have multiple entries but are missing industry data in some of them.

SELECT t1.industry,t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
 ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


SELECT *
FROM layoffs_staging2;

-- 6. Remove Unnecessary Rows
-- Delete rows that are not useful for the analysis.

-- Remove rows where both 'total_laid_off' and 'percentage_laid_off' are NULL,
-- as these rows lack the primary data points for this analysis.

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;



-- 7. Final Cleanup
-- Remove any helper columns that were created during the cleaning process.

-- Drop the 'row_num' column as it is no longer needed.

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- The layoffs_staging2 table is now clean and ready for analysis.

SELECT *
FROM layoffs_staging2;
