-- V2 Segment LLM Naming via Snowflake Cortex
-- Grain: 1 row per cluster_id (6 rows) — same pattern as V3's prep_segment_named
-- dim_users joins this to users via cluster_id

{{ config(materialized='table') }}

SELECT
    cluster_id,
    user_count,
    user_pct,

    TRIM(SNOWFLAKE.CORTEX.COMPLETE(
        'llama3.1-70b',
        'You name audience segments for a streaming platform. '
        || 'Given these stats, respond with ONLY a 2-3 word segment name. Nothing else. '
        || 'Stats: clickout_rate=' || avg_clickout_rate
        || ', genre_diversity=' || avg_genre_entropy
        || ', avg_imdb=' || avg_imdb_score
        || ', platforms_used=' || avg_providers
        || ', search_rate=' || avg_search_rate
        || ', session_depth=' || avg_session_depth
        || ', top_genre=' || COALESCE(top_genre, 'mixed')
        || ', top_monetization=' || COALESCE(top_monetization, 'unknown')
        || ', user_count=' || user_count
        || '. Reply with ONLY the 2-3 word segment name, nothing else.'
    )) AS segment_name,

    TRIM(SNOWFLAKE.CORTEX.COMPLETE(
        'llama3.1-70b',
        'Write one sentence (under 25 words) describing this streaming audience segment. '
        || 'Focus on behaviour and value to advertisers. '
        || 'Stats: clickout_rate=' || avg_clickout_rate
        || ', genre_diversity=' || avg_genre_entropy
        || ', avg_imdb=' || avg_imdb_score
        || ', platforms_used=' || avg_providers
        || ', search_rate=' || avg_search_rate
        || ', top_genre=' || COALESCE(top_genre, 'mixed')
        || ', top_monetization=' || COALESCE(top_monetization, 'unknown')
        || '. One sentence only, no headers.'
    )) AS segment_description

FROM {{ ref('prep_segment_profiles_embed') }}
