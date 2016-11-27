
-- etldoc: layer_poi[shape=record fillcolor=lightpink, style="rounded,filled",  
-- etldoc:     label="layer_poi | <z14_> z14_" ] ;

CREATE OR REPLACE FUNCTION layer_poi(bbox geometry, zoom_level integer, pixel_width numeric)
RETURNS TABLE(osm_id bigint, geometry geometry, name text, name_en text, class text, subclass text, "rank" int) AS $$
    SELECT osm_id, geometry, name, NULLIF(name_en, ''), poi_class(subclass) AS class, subclass,
        row_number() OVER (
            PARTITION BY LabelGrid(geometry, 100 * pixel_width)
            ORDER BY poi_class_rank(poi_class(subclass)) ASC, length(name) DESC
        )::int AS "rank"
    FROM (    
        -- etldoc: osm_poi_point ->  layer_poi:z14_        
        SELECT * FROM osm_poi_point
            WHERE geometry && bbox
                AND zoom_level >= 14
                AND name <> ''
        UNION ALL
        -- etldoc: osm_poi_polygon ->  layer_poi:z14_        
        SELECT * FROM osm_poi_polygon
            WHERE geometry && bbox
                AND zoom_level >= 14
                AND name <> ''    
        ) as poi_union 
    ORDER BY "rank"
    ;
$$ LANGUAGE SQL IMMUTABLE;
