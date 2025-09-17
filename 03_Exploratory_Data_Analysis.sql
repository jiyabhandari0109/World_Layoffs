/* EXPLORATORY DATA ANALYSIS */

-- Order results by total funds raised to identify top-funded companies first

SELECT *
	FROM layoffs_cleaned2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Find maximum layoff in a day

SELECT MAX(total_laid_off) AS max_total_laid_off, 
       MAX(percentage_laid_off) AS max_percentage_laid_off
	FROM layoffs_cleaned2;
 
-- Find total layoffs by company stage, sorted from highest to lowest
 
 SELECT stage, 
        SUM(total_laid_off) AS total_laid_off
	FROM layoffs_cleaned2
GROUP BY stage
ORDER BY 2 DESC;
 
-- Find total percentage of layoffs by company, sorted from highest to lowest
 
 SELECT company, 
        ROUND(SUM(percentage_laid_off), 2) AS percentage_laid_off
	FROM layoffs_cleaned2
GROUP BY 1
ORDER BY 2 DESC;

-- Find the earliest and latest layoff dates

SELECT MIN(`date`) AS earliest_layoff, 
       MAX(`date`) AS latest_layoff
	FROM layoffs_cleaned2;
    
-- Calculate daily layoffs and rolling monthly totals

WITH daily_totals AS
(
	SELECT date,
		   SUM(total_laid_off) AS daily_laid_off
		FROM layoffs_cleaned2
	GROUP BY 1
	ORDER BY 1
)
SELECT `date`,
       SUM(daily_laid_off) OVER(PARTITION BY MONTH(`date`) ORDER BY `date`) AS rolling_monthly_totals
	FROM daily_totals
ORDER BY 1;
    
-- Calculate monthly layoffs with a rolling cumulative total

WITH monthly_totals AS 
(
    SELECT DATE_FORMAT(`date`, '%Y-%m') AS month,
           SUM(total_laid_off) AS monthly_laid_off
		FROM layoffs_cleaned2
    GROUP BY DATE_FORMAT(`date`, '%Y-%m')
)
SELECT month,
       monthly_laid_off,
       SUM(monthly_laid_off) OVER (ORDER BY month) AS rolling_total
	FROM monthly_totals
ORDER BY month;
 
 -- Total layoffs per company by year, sorted from highest to lowest

 SELECT company, 
        YEAR(`date`) AS year, 
        SUM(total_laid_off) AS total_layoff
	FROM layoffs_cleaned2
GROUP BY 1, 2
ORDER BY 3 DESC;

-- Find the top 5 companies with the highest layoffs for each year

WITH company_year(company, years, total_laid_off) AS
(
	SELECT company, 
           YEAR(`date`) AS year, 
           SUM(total_laid_off) AS total_laid_off
		FROM layoffs_cleaned2
GROUP BY 1, 2
),
company_year_rank AS
(
	SELECT *, 
	DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
		FROM company_year
	WHERE years IS NOT NULL
)
SELECT *
	FROM company_year_rank
WHERE ranking <= 5;
       