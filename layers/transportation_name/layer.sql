
-- etldoc: layer_transportation_name[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_transportation_name | <z8> z8 |<z9> z9 |<z10> z10 |<z11> z11 |<z12> z12|<z13> z13|<z14_> z14+" ] ;

CREATE OR REPLACE FUNCTION layer_transportation_name(bbox geometry, zoom_level integer)
RETURNS TABLE(osm_id bigint, geometry geometry, name text, ref text, ref_length int, network text, class text) AS $$
    SELECT osm_id, geometry, name,
      NULLIF(ref, ''), NULLIF(LENGTH(ref), 0) AS ref_length,
      --TODO: The road network of the road is not yet implemented
      NULL::text AS network,
      highway_class(highway) AS class
    FROM (

        -- etldoc: osm_transportation_name_linestring_gen3 ->  layer_transportation_name:z8
        SELECT * FROM osm_transportation_name_linestring_gen3
        WHERE zoom_level = 8
        UNION ALL

        -- etldoc: osm_transportation_name_linestring_gen2 ->  layer_transportation_name:z9
        SELECT * FROM osm_transportation_name_linestring_gen2
        WHERE zoom_level = 9
        UNION ALL

        -- etldoc: osm_transportation_name_linestring_gen1 ->  layer_transportation_name:z10
        -- etldoc: osm_transportation_name_linestring_gen1 ->  layer_transportation_name:z11
        SELECT * FROM osm_transportation_name_linestring_gen1
        WHERE zoom_level BETWEEN 10 AND 11
        UNION ALL

        -- etldoc: osm_transportation_name_linestring ->  layer_transportation_name:z12
        SELECT * FROM osm_transportation_name_linestring
        WHERE zoom_level = 12
            AND LineLabel(zoom_level, COALESCE(NULLIF(name, ''), ref), geometry)
            AND highway_class(highway) NOT IN ('minor', 'track', 'path')
            AND NOT highway_is_link(highway)
        UNION ALL

        -- etldoc: osm_transportation_name_linestring ->  layer_transportation_name:z13
        SELECT * FROM osm_transportation_name_linestring
        WHERE zoom_level = 13
            AND LineLabel(zoom_level, COALESCE(NULLIF(name, ''), ref), geometry)
            AND highway_class(highway) NOT IN ('track', 'path')
        UNION ALL

        -- etldoc: osm_transportation_name_linestring ->  layer_transportation_name:z14_
        SELECT * FROM osm_transportation_name_linestring
        WHERE zoom_level >= 14

    ) AS zoom_levels
    WHERE geometry && bbox
    ORDER BY z_order ASC;
$$ LANGUAGE SQL IMMUTABLE;
