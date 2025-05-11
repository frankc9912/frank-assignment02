WITH neighborhood_stats AS (
    SELECT
        n.name AS neighborhood_name,
        COUNT(CASE WHEN s.wheelchair_boarding = 1 THEN 1 END) AS num_bus_stops_accessible,
        COUNT(CASE WHEN s.wheelchair_boarding = 2 THEN 1 END) AS num_bus_stops_inaccessible,
        ROUND(ST_AREA(n.geog::geometry)::numeric / 1e6, 2) AS area_km2
    FROM phl.neighborhoods AS n
    LEFT JOIN septa.bus_stops AS s
        ON ST_WITHIN(s.geog::geometry, n.geog::geometry)
    GROUP BY n.name, n.geog
),

accessibility_scores AS (
    SELECT
        neighborhood_name,
        num_bus_stops_accessible,
        num_bus_stops_inaccessible,
        area_km2,
        ROUND(num_bus_stops_accessible / NULLIF(area_km2, 0), 2) AS accessibility_metric
    FROM neighborhood_stats
)

SELECT
    neighborhood_name,
    accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
FROM accessibility_scores
WHERE accessibility_metric IS NOT NULL
ORDER BY accessibility_metric ASC
LIMIT 5;
