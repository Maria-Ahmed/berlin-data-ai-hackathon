-- V3 Segment Centroid Profiles — Enriched
-- Provides rich per-cluster stats with multiple discriminating signals for LLM naming.
-- Grain: 6 rows (one per K-Means cluster)

{{ config(materialized='table') }}

WITH user_clusters AS (
    SELECT
        p.user_id,
        p.cluster_id,
        u.clickout_rate,
        u.genre_entropy,
        u.avg_imdb_score,
        u.distinct_providers,
        u.search_rate,
        u.total_sessions,
        u.total_watchlist_adds,
        u.total_likes,
        u.total_events,
        u.total_clickouts,
        u.total_search_events,
        u.avg_events_per_session,
        u.distinct_titles,
        u.distinct_genres,
        u.primary_genre,
        u.primary_monetization_type,
        u.primary_device
    FROM {{ ref('prep_user_segments_KMean') }} p
    JOIN {{ ref('prep_users') }} u ON p.user_id = u.user_id
)

SELECT
    cluster_id,
    COUNT(*) AS user_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS user_pct,

    -- Engagement depth
    ROUND(AVG(clickout_rate), 4)         AS avg_clickout_rate,
    ROUND(AVG(search_rate), 4)           AS avg_search_rate,
    ROUND(AVG(genre_entropy), 2)         AS avg_genre_entropy,
    ROUND(AVG(avg_imdb_score), 2)        AS avg_imdb_score,
    ROUND(AVG(distinct_providers), 1)    AS avg_providers,
    ROUND(AVG(total_sessions), 1)        AS avg_sessions,
    ROUND(AVG(avg_events_per_session), 1) AS avg_events_per_session,
    ROUND(AVG(distinct_titles), 1)       AS avg_distinct_titles,
    ROUND(AVG(distinct_genres), 1)       AS avg_distinct_genres,
    ROUND(AVG(total_watchlist_adds), 2)  AS avg_watchlist_adds,
    ROUND(AVG(total_likes), 2)           AS avg_likes,

    -- Taste tier
    ROUND(AVG(CASE WHEN avg_imdb_score >= 7.5 THEN 1.0 ELSE 0.0 END) * 100, 1) AS pct_high_imdb_users,

    -- Behaviour type (buyer vs browser vs curator)
    ROUND(AVG(CASE WHEN clickout_rate > 0.08 THEN 1.0 ELSE 0.0 END) * 100, 1) AS pct_high_intent_buyers,
    ROUND(AVG(CASE WHEN total_watchlist_adds > 2 THEN 1.0 ELSE 0.0 END) * 100, 1) AS pct_curators,
    ROUND(AVG(CASE WHEN search_rate > 0.1 THEN 1.0 ELSE 0.0 END) * 100, 1) AS pct_active_searchers,

    -- Top device
    MODE(primary_device) AS top_device,

    -- Top monetization
    MODE(primary_monetization_type) AS top_monetization,

    -- Top 3 genres as a ranked list (not just mode)
    LISTAGG(DISTINCT primary_genre, ', ') WITHIN GROUP (ORDER BY primary_genre) AS all_genres_seen

FROM user_clusters
GROUP BY cluster_id
ORDER BY user_count DESC
