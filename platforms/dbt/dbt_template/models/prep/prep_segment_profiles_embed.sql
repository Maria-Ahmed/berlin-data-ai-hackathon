-- V2 Step 4: Centroid feature stats per embedding cluster
-- Grain: 1 row per cluster_id (6 rows)

SELECT
    e.cluster_id,
    COUNT(*) AS user_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS user_pct,
    ROUND(AVG(u.clickout_rate), 4) AS avg_clickout_rate,
    ROUND(AVG(u.genre_entropy), 2) AS avg_genre_entropy,
    ROUND(AVG(u.avg_imdb_score), 2) AS avg_imdb_score,
    ROUND(AVG(u.distinct_providers), 1) AS avg_providers,
    ROUND(AVG(u.search_rate), 4) AS avg_search_rate,
    ROUND(AVG(u.avg_events_per_session), 1) AS avg_session_depth,
    MODE(u.primary_genre) AS top_genre,
    MODE(u.primary_monetization_type) AS top_monetization
FROM {{ ref('prep_user_segments_embed') }} e
JOIN {{ ref('prep_users') }} u ON e.user_id = u.user_id
GROUP BY e.cluster_id
ORDER BY user_count DESC
