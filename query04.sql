-- Index creation (run once)
CREATE INDEX IF NOT EXISTS bus_shapes_shape_seq_idx
ON septa.bus_shapes (shape_id, shape_pt_sequence);

CREATE INDEX IF NOT EXISTS bus_trips_shape_id_idx
ON septa.bus_trips (shape_id);

CREATE INDEX IF NOT EXISTS bus_trips_route_id_idx
ON septa.bus_trips (route_id);

-- Build shape geometries and compute lengths
WITH shape_geoms AS (
    SELECT
        shape_id,
        ST_MAKELINE(
            ST_SETSRID(ST_MAKEPOINT(shape_pt_lon, shape_pt_lat), 4326)
            ORDER BY shape_pt_sequence
        )::geography AS shape_geog
    FROM septa.bus_shapes
    GROUP BY shape_id
),

-- Get top 2 longest shapes
longest_shapes AS (
    SELECT
        shape_id,
        shape_geog,
        ROUND(ST_LENGTH(shape_geog)) AS shape_length
    FROM shape_geoms
    ORDER BY shape_length DESC
    LIMIT 2
)

-- Join with trips and routes
SELECT
    r.route_short_name,
    t.trip_headsign,
    s.shape_geog,
    s.shape_length
FROM longest_shapes AS s
INNER JOIN septa.bus_trips AS t ON s.shape_id = t.shape_id
INNER JOIN septa.bus_routes AS r ON t.route_id = r.route_id
LIMIT 2;
