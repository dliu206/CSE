
SELECT W.day_of_week AS day_of_week, AVG(X.arrival_delay) AS delay FROM FLIGHTS X, WEEKDAYS W
WHERE X.day_of_week_id = W.did
GROUP BY W.did
ORDER BY AVG(X.arrival_delay) DESC
LIMIT 1;

