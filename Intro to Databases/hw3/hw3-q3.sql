
.mode column
.header on

WITH number AS (SELECT X.origin_city, COUNT(X.actual_time) AS NUM FROM FLIGHTS X
                WHERE (X.actual_time < 180
                AND X.actual_time IS NOT NULL)
                GROUP BY X.origin_city),
total_count AS (SELECT X.origin_city, COUNT(X.actual_time) AS TOTAL FROM FLIGHTS X
                GROUP BY X.origin_city)
SELECT DISTINCT T.origin_city AS origin_city, (CAST(N.NUM AS FLOAT) / T.TOTAL) * 100 AS percentage
FROM total_count T LEFT JOIN number N
ON T.origin_city = N.origin_city
ORDER BY percentage ASC;
