-- Query for Kepler.gl visualization with fully compliant GeoJSON formatting
SELECT jsonb_build_object(
    'type', 'FeatureCollection',
    'features', jsonb_agg(features.feature)
)
FROM (
    SELECT jsonb_build_object(
        'type', 'Feature',
        'geometry', ST_AsGeoJSON(geom)::jsonb,
        'properties', jsonb_build_object(
            'id', id,
            'population', aantal_inwoners,
            'housing_units', aantal_woningen,
            'avg_income', gemiddeld_inkomen_huishouden,
            'urbanization', stedelijkheid,
            'housing_value', gemiddelde_woz_waarde_woning,
            'train_station_distance', dichtstbijzijnde_treinstation_afstand_in_km
        )
    ) AS feature
    FROM netherlands.vk500
    WHERE aantal_inwoners > 0
    LIMIT 500
) AS features;