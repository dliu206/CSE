
.mode column
.header on

SELECT DISTINCT W.origin_city AS city FROM FLIGHTS W
WHERE W.origin_city NOT IN (SELECT DISTINCT Y.dest_city AS city FROM FLIGHTS X, FLIGHTS Y
                            WHERE X.origin_city LIKE 'Seattle%'
                            AND X.dest_city = Y.origin_city
                            AND NOT Y.dest_city LIKE 'Seattle%'
                            AND NOT X.dest_city LIKE 'Seattle%')
AND W.origin_city NOT IN (SELECT DISTINCT Z.dest_city FROM FLIGHTS Z WHERE Z.origin_city LIKE 'Seattle%')
AND NOT W.origin_city LIKE 'Seattle%'
ORDER BY city ASC;

