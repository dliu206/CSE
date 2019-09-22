

SELECT SUM(X.capacity) AS capacity FROM FLIGHTS X, MONTHS M
WHERE ((X.origin_city LIKE 'Seattle%' AND X.dest_city LIKE 'San Francisco%')
OR (X.origin_city LIKE 'San Francisco%' AND X.dest_city LIKE 'Seattle%'))
  AND M.month LIKE 'July' AND X.month_id = M.mid AND X.day_of_month = 10;
