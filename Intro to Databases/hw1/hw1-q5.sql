--  A SQL query that returns only the name and distance of all restaurants within and
-- including 20 minutes of my house in alphabetical order by name
SELECT name, distance
  FROM Restaurants
  WHERE Distance <= 20
  ORDER BY name ASC;