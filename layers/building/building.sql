CREATE SCHEMA IF NOT EXISTS building;

-- etldoc: layer_building[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_building | <z13> z13 | <z14_> z14+ " ] ;

CREATE OR REPLACE FUNCTION building.layer_building(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, osm_id bigint, render_height int, render_min_height int) AS $$
    SELECT geometry, osm_id, render_height, render_min_height
    FROM (
        -- etldoc: osm_building_polygon_gen1 -> layer_building:z13
        SELECT
            osm_id, geometry,
            NULL::int AS render_height, NULL::int AS render_min_height
        FROM osm_building_polygon_gen1
        WHERE zoom_level = 13 AND geometry && bbox AND area > 1400
        UNION ALL
        -- etldoc: osm_building_polygon -> layer_building:z14_
        SELECT
            osm_id, geometry,
            greatest(5, COALESCE(height, levels*3.66,5))::int AS render_height,
            greatest(0, COALESCE(min_height, min_level*3.66,0))::int AS render_min_height
        FROM osm_building_polygon
        WHERE zoom_level >= 14 AND geometry && bbox
    ) AS zoom_levels
    ORDER BY render_height ASC, ST_YMin(geometry) DESC;
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION building.delete() RETURNS VOID AS $$
BEGIN
  DROP SCHEMA IF EXISTS building CASCADE;
  DROP TABLE IF EXISTS osm_building_polygon_gen1 CASCADE;
  DROP TABLE IF EXISTS osm_building_polygon CASCADE;
END;
$$ LANGUAGE plpgsql;
