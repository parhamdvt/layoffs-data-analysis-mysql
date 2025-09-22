# Global Layoffs Data Cleaning & Exploratory Data Analysis in MySQL

## Project Overview

This project involves the cleaning and exploratory data analysis (EDA) of a dataset covering global layoffs from various companies. The primary goal was to take a raw, messy dataset and transform it into a clean, reliable source for analysis. Following the cleaning, I performed an EDA to uncover insights related to layoffs across different industries, countries, and time periods.

## Tools Used

* **Database:** MySQL

## Data Cleaning Process

The raw data required several cleaning steps to be ready for analysis. The entire process includes:

1.  **Duplicate Removal:** Identified and removed duplicate rows using a `ROW_NUMBER()` window function.
2.  **Data Standardization:**
    * Trimmed leading/trailing whitespaces from company names.
    * Standardized industry names (e.g., merging 'Crypto', 'Crypto Currency', and 'CryptoCurrency' into a single 'Crypto' category).
    * Corrected country names by removing trailing periods.
3.  **Data Type Conversion:** Converted the `date` column from a text format to the standard `DATE` format.
4.  **Handling Nulls and Blanks:**
    * Populated `NULL` values in the `industry` column by using other entries from the same company.
    * Removed rows where both `total_laid_off` and `percentage_laid_off` were `NULL`, as they contained no actionable information for this analysis.

## Exploratory Data Analysis (EDA)

The EDA, detailed in `eda_script.sql`, aimed to answer several key questions:

* Which companies and industries had the highest number of layoffs?
* Which countries were most affected?
* What was the timeline of layoffs, and were there specific peak periods?
* What was the rolling total of layoffs over time to observe trends?
* Who were the top 5 companies by layoffs for each year in the dataset?

## Key Findings

* **Industry Impact:** The analysis revealed that the Consumer and Retail industries were the most impacted by layoffs.
* **Geographical Trends:** United States saw the highest number of total layoffs.
* **Layoff Timeline:** The period around 2022/2023 experienced a significant surge in layoffs.
* **Yearly Leaders:** The top companies in terms of layoffs shifted each year, with major players like Uber, ByteDance, Meta and Google leading in different years.

## How to Replicate

1.  Clone this repository to your local machine.
2.  Create a new database in your MySQL instance.
3.  Import the original `.csv` data into a table named `layoffs`.
4.  Run the `data_cleaning_script.sql` to create the cleaned `layoffs_staging2` table.
5.  Run the `eda_script.sql` against the `layoffs_staging2` table to perform the analysis.
