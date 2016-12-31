
-- etldoc: layer_water_name[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_water_name | <z9_13> z9_13 | <z14_> z14+" ] ;

CREATE OR REPLACE FUNCTION layer_water_name(bbox geometry, zoom_level integer)
RETURNS TABLE(osm_id bigint, geometry geometry, name text, name_en text, class text) AS $$
    -- etldoc: osm_water_lakeline ->  layer_water_name:z9_13
    -- etldoc: osm_water_lakeline ->  layer_water_name:z14_
    SELECT osm_id, geometry, name, name_en, 'lake'::text AS class
    FROM osm_water_lakeline(bbox, zoom_level)
    WHERE geometry && bbox
      AND ((zoom_level BETWEEN 9 AND 13 AND LineLabel(zoom_level, NULLIF(name, ''), geometry))
        OR (zoom_level >= 14))
    -- etldoc: osm_water_point ->  layer_water_name:z9_13
    -- etldoc: osm_water_point ->  layer_water_name:z14_    
    UNION ALL
    SELECT osm_id, geometry, name, name_en, 'lake'::text AS class
    FROM osm_water_point(bbox, zoom_level)
    WHERE geometry && bbox AND (
        (zoom_level BETWEEN 9 AND 13 AND area > 70000*2^(20-zoom_level))
        OR (zoom_level >= 14)
    );
$$ LANGUAGE SQL IMMUTABLE;
