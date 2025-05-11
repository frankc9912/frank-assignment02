ALTER TABLE septa.rail_stops
ADD COLUMN IF NOT EXISTS geog geography;

UPDATE septa.rail_stops
SET geog = ST_SETSRID(ST_MAKEPOINT(stop_lon, stop_lat), 4326)::geography
WHERE geog IS NULL;

WITH nearest_parcels AS (
    SELECT
        r.stop_id,
        r.stop_name,
        r.geog AS stop_geog,
        r.stop_lon,
        r.stop_lat,
        p.address AS nearest_address,
        p.geog AS parcel_geog
    FROM septa.rail_stops AS r
    INNER JOIN LATERAL (
        SELECT
            p.address,
            p.geog
        FROM phl.pwd_parcels AS p
        ORDER BY r.geog <-> p.geog
        LIMIT 1
    ) AS p ON TRUE
)

SELECT
    stop_id,
    stop_name,
    stop_lon,
    stop_lat,
    CONCAT(
        ROUND(ST_DISTANCE(stop_geog, parcel_geog))::int, ' meters ',
        CASE
            WHEN az BETWEEN 0 AND PI() / 8 THEN 'N'
            WHEN az < PI() / 4 THEN 'NE'
            WHEN az < 3 * PI() / 8 THEN 'E'
            WHEN az < 5 * PI() / 8 THEN 'SE'
            WHEN az < 7 * PI() / 8 THEN 'S'
            WHEN az < 9 * PI() / 8 THEN 'SW'
            WHEN az < 11 * PI() / 8 THEN 'W'
            ELSE 'NW'
        END,
        ' of ', INITCAP(nearest_address)
    ) AS stop_desc
FROM (
    SELECT
        *,
        ST_AZIMUTH(
            ST_CENTROID(parcel_geog::geometry),
            stop_geog::geometry
        ) AS az
    FROM nearest_parcels
) AS sub;
