

SELECT DISTINCT C.name AS name, AVG(X.canceled) AS percent
FROM CARRIERS C, FLIGHTS X
WHERE X.carrier_id = C.cid AND X.origin_city LIKE 'Seattle%'
GROUP BY C.cid
HAVING percent > .005
ORDER BY percent ASC;