-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems
-- 1. Which maturity rating dominates Movies vs. TV Shows, 
--and who is Netflix's primary target audience?
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS total_count
    FROM netflix
    WHERE rating IS NOT NULL
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        total_count,
        RANK() OVER (PARTITION BY type ORDER BY total_count DESC) AS ranking
    FROM RatingCounts
)
SELECT 
    type,
    rating AS dominant_rating,
    total_count
FROM RankedRatings
WHERE ranking = 1;

--2.In which release years did Netflix produce/release the 
--highest proportion of its total Indian catalog?

SELECT 
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric / 
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 
        2
    ) AS pct_of_total_india_catalog
FROM netflix
WHERE country = 'India'
GROUP BY release_year
ORDER BY pct_of_total_india_catalog DESC
LIMIT 5;


--3.Titles on Netflix belong to multiple genres stored in a 
--single text column (e.g., 'Comedies, Dramas'). How many total titles exist per individual genre?


SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY genre
ORDER BY total_content DESC
LIMIT 10;


--4.How much of Netflix's catalog contains 
--sensitive/violent themes vs. family-friendly content based on plot descriptions?   


SELECT 
    CASE 
        WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Sensitive / Mature'
        ELSE 'Family / General'
    END AS content_category,
    COUNT(*) AS total_titles,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix), 2) AS share_pct
FROM netflix
GROUP BY 1;


--End of Queries--
