SELECT bg.geoid
FROM phl.pwd_parcels AS p
INNER JOIN census.blockgroups_2020 AS bg
    ON ST_WITHIN(p.geog::geometry, bg.geog::geometry)
WHERE p.address ILIKE '220-30 S 34TH ST'
LIMIT 1;
