
.mode column
.header on

SELECT DISTINCT C.name AS carrier FROM CARRIERS C, FLIGHTS X
WHERE X.carrier_id = C.cid
AND X.origin_city LIKE 'Seattle%'
AND X.dest_city LIKE 'San Francisco%'
ORDER BY C.name ASC;
