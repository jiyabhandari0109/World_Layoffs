/* DATA CLEANING */

SELECT *
	FROM layoffs;

-- Create Duplicate Table

CREATE TABLE layoffs_cleaned
	LIKE layoffs;

SELECT *
	FROM layoffs_cleaned;

INSERT layoffs_cleaned
	SELECT *
	FROM layoffs;
    
-- Identify Duplicate Rows

WITH duplicate_cte AS
(
	SELECT *,
		   ROW_NUMBER() OVER(
		   PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
		FROM layoffs_cleaned
)
SELECT *
	FROM duplicate_cte
WHERE row_num > 1;

-- Create Duplicate Table with Row_num
    
CREATE TABLE `layoffs_cleaned2` 
(
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
);
    
INSERT INTO layoffs_cleaned2
SELECT *,
       ROW_NUMBER() OVER(
       PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs;

-- Identify and Remove Duplicate Rows in Table 2

SELECT *
	FROM layoffs_cleaned2
    WHERE row_num > 1;

DELETE 
	FROM layoffs_cleaned2
    WHERE row_num > 1;

-- Trim Company

SELECT DISTINCT (TRIM(company))
	FROM layoffs_cleaned2;
    
UPDATE layoffs_cleaned2
SET company = TRIM(company);

-- Identify Identical Industry Names

SELECT DISTINCT (industry)
	FROM layoffs_cleaned2
ORDER BY 1;

SELECT *
	FROM layoffs_cleaned2
WHERE industry LIKE 'crypto%';

-- Update records to unify identical industry names into one a standard name

UPDATE layoffs_cleaned2
SET industry = 'Crypto'
WHERE industry LIKE 'crypto%';

-- Identify Identical Country Names

SELECT DISTINCT country
	FROM layoffs_cleaned2
ORDER BY 1;

SELECT DISTINCT country
	FROM layoffs_cleaned2
WHERE country LIKE 'united states%';

-- Update records to unify identical country names into one a standard name

UPDATE layoffs_cleaned2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'unites states%';

-- Format Date

SELECT `date`,
       STR_TO_DATE(`date`, '%m/%d/%Y') AS cleaned_date
	FROM layoffs_cleaned2;

UPDATE layoffs_cleaned2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Change Data Type

ALTER TABLE layoffs_cleaned2
MODIFY COLUMN `date` DATE;

-- Identify and Remove Blanks

SELECT *
	FROM layoffs_cleaned2
WHERE industry IS NULL
OR industry = '';

UPDATE layoffs_cleaned2
SET industry = NULL
WHERE industry = '';


SELECT t1.industry, t2.industry
	FROM layoffs_cleaned2 t1
JOIN layoffs_cleaned2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;


UPDATE layoffs_cleaned2 t1
JOIN layoffs_cleaned2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL )
AND t2.industry IS NOT NULL;

-- Remove Unproductive Columns

SELECT *
	FROM layoffs_cleaned2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
	FROM layoffs_cleaned2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Remove Row_num Column

ALTER TABLE layoffs_cleaned2
DROP COLUMN row_num;

/* FINAL TABLE */

SELECT *
	FROM layoffs_cleaned2;