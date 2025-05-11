-- Discussion:
-- To define Penn’s campus, I constructed a manually defined bounding polygon that spans from 33rd to 43rd Street, 
-- and from South Street to Chestnut Street. This region includes the full core of the University of Pennsylvania’s 
-- academic, research, and hospital campuses.
--
-- The polygon was created using ST_GeogFromText and passed into ST_Contains to identify how many 
-- 2020 Census block groups fall fully within this boundary.
--
-- This method balances precision and reproducibility without requiring external GIS layers, and ensures 
-- the results are grounded in real spatial geography.

WITH penn_campus AS (
    SELECT ST_GEOGFROMTEXT(
        'POLYGON((
      -75.2009 39.9573,
      -75.2009 39.9434,
      -75.1913 39.9434,
      -75.1913 39.9573,
      -75.2009 39.9573
    ))'
    ) AS geog
)

SELECT COUNT(*) AS count_block_groups
FROM census.blockgroups_2020 AS bg,
    penn_campus AS pc
WHERE ST_CONTAINS(pc.geog::geometry, bg.geog::geometry);
