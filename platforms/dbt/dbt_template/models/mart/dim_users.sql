-- User dimension: behavioral features + segment assignments (V1 heuristic + V3 K-Means ML)
-- Grain: 1 row per user_id

select
    u.user_id,

    -- V1: Heuristic rule-based segment
    s.segment_id                   AS segment_heuristic_id,
    s.segment_name                 AS segment_heuristic_name,

    -- V3: ML K-Means + Cortex LLM segments
    km.cluster_id                  AS segment_kmeans_id,
    sn.segment_name                AS segment_kmeans_name,
    sn.segment_description         AS segment_kmeans_description,

    -- behavioral features
    u.total_events,
    u.total_sessions,
    u.total_clickouts,
    u.total_search_events,
    u.total_watchlist_adds,
    u.total_likes,
    u.total_engagement_score,

    -- diversity
    u.distinct_providers,
    u.distinct_genres,
    u.distinct_titles,

    -- rates & averages
    u.clickout_rate,
    u.search_rate,
    u.avg_events_per_session,
    u.avg_imdb_score,
    u.genre_entropy,

    -- primary attributes
    u.primary_provider_id,
    u.primary_genre,
    u.primary_monetization_type,
    u.primary_device

from {{ ref('prep_users') }} u
-- V1 heuristic segments
left join {{ ref('prep_user_segments') }} s
    on u.user_id = s.user_id
-- V3 ML cluster assignment
left join {{ ref('prep_user_segments_KMean') }} km
    on u.user_id = km.user_id
-- V3 Cortex LLM-generated persona names (6-row lookup)
left join {{ ref('prep_segment_named') }} sn
    on km.cluster_id = sn.cluster_id
