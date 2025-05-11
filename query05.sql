-- Goal: Rate Philadelphia neighborhoods by their accessibility to wheelchair-friendly bus stops.
-- 
-- Metric: Wheelchair-Accessible Stop Density (WASD)
--   → (# of accessible bus stops) / (neighborhood area in square kilometers)
--
-- Why this metric?
-- - Normalizes accessibility by geographic size for fair comparison
-- - Highlights neighborhoods with high density of accessible stops
--
-- Process:
-- 1. Filter bus stops where wheelchair_boarding = 1
-- 2. Use ST_Within() to count how many fall inside each neighborhood
-- 3. Compute area of each neighborhood using ST_Area()
-- 4. Calculate stop density as (accessible stops / area)
-- 5. Rank neighborhoods by this density score (higher is better)
--
-- Note:
-- - ST_Within() requires geometry types, so cast geog → geometry using ::geometry
-- - ST_Area() returns square meters, divide by 1e6 to get square kilometers


WITH neighborhood_accessibility AS (
    SELECT
        n.name AS neighborhood,
        COUNT(CASE WHEN s.wheelchair_boarding = 1 THEN 1 END) AS accessible_stop_count,
        ROUND(ST_AREA(n.geog::geometry)::numeric / 1e6, 2) AS area_km2
    FROM phl.neighborhoods AS n
    LEFT JOIN septa.bus_stops AS s
        ON ST_WITHIN(s.geog::geometry, n.geog::geometry)
    GROUP BY n.name, n.geog
),

accessibility_scores AS (
    SELECT
        neighborhood,
        accessible_stop_count,
        area_km2,
        ROUND(accessible_stop_count / NULLIF(area_km2, 0), 2) AS wasd_score
    FROM neighborhood_accessibility
)

SELECT *
FROM accessibility_scores
ORDER BY wasd_score DESC;
