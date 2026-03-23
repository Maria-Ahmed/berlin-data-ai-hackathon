-- User dimension: behavioral features + segmentation variants
-- Grain: 1 row per user_id
--
-- Join pattern (same for V2 and V3):
--   prep_users → user_id
--   prep_user_segments_* → user_id + cluster_id  (user-level assignment)
--   prep_segment_named_* → cluster_id + name     (cluster-level lookup)

select
    u.user_id,

    -- V1: Heuristic rule-based segment
    v1.segment_id as segment_heuristic_id,
    v1.segment_name as segment_heuristic_name,

    -- V2: Embedding clusters (Cortex EMBED → K-Means → LLM named)
    v2.cluster_id              as segment_embedding_id,
    v2_named.segment_name      as segment_embedding_name,
    v2_named.segment_description as segment_embedding_description,

    -- V3: Feature K-Means clusters (Snowflake ML → LLM named)
    v3.cluster_id              as segment_kmeans_id,
    v3_named.segment_name      as segment_kmeans_name,
    v3_named.segment_description as segment_kmeans_description,

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
    u.primary_provider_group,
    u.primary_genre,
    u.primary_monetization_type,
    u.primary_device

from {{ ref('prep_users') }} u

-- V1: heuristic (user-level, has segment_name directly)
left join {{ ref('prep_user_segments') }} v1
    on u.user_id = v1.user_id

-- V2: embedding clusters (user → cluster_id, then cluster_id → name)
left join {{ ref('prep_user_segments_embed') }} v2
    on u.user_id = v2.user_id
left join {{ ref('prep_segment_named_embed') }} v2_named
    on v2.cluster_id = v2_named.cluster_id

-- V3: feature K-Means (user → cluster_id, then cluster_id → name)
left join {{ ref('prep_user_segments_KMean') }} v3
    on u.user_id = v3.user_id
left join {{ ref('prep_segment_named') }} v3_named
    on v3.cluster_id = v3_named.cluster_id
