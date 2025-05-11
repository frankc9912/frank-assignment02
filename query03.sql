SELECT
    parcels.address AS parcel_address,
    stops.stop_name,
    ROUND(ST_DISTANCE(parcels.geog, stops.geog)::numeric, 2) AS distance
FROM phl.pwd_parcels AS parcels
INNER JOIN LATERAL (
    SELECT
        bus_stops.stop_name,
        bus_stops.geog
    FROM septa.bus_stops
    ORDER BY parcels.geog <-> septa.bus_stops.geog
    LIMIT 1
) AS stops ON true
ORDER BY distance DESC;
