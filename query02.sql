WITH septa_bus_stop_blockgroups AS (
    SELECT
        stops.stop_id,
        '1500000US' || bg.geoid AS geoid
    FROM septa.bus_stops AS stops
    INNER JOIN census.blockgroups_2020 AS bg
        ON ST_DWITHIN(stops.geog, bg.geog, 800)
    WHERE bg.geoid LIKE '42101%' -- Only Philadelphia County
),

septa_bus_stop_surrounding_population AS (
    SELECT
        sb.stop_id,
        SUM(pop.total) AS estimated_pop_800m
    FROM septa_bus_stop_blockgroups AS sb
    INNER JOIN census.population_2020 AS pop
        ON sb.geoid = pop.geoid
    GROUP BY sb.stop_id
    HAVING SUM(pop.total) > 500
)

SELECT
    stops.stop_name,
    pop.estimated_pop_800m,
    stops.geog
FROM septa_bus_stop_surrounding_population AS pop
INNER JOIN septa.bus_stops AS stops
    ON pop.stop_id = stops.stop_id
ORDER BY pop.estimated_pop_800m ASC
LIMIT 8;
