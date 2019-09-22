-- Compute the total departure delay of each airline
-- across all flights.
-- Name the output columns name and delay, in that order.
-- [Output relation cardinality: 22 rows]

SELECT C.name AS name, SUM(X.departure_delay) AS delay FROM FLIGHTS X, CARRIERS C
WHERE C.cid = X.carrier_id
GROUP BY C.cid;