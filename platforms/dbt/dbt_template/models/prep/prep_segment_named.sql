-- V3 Segment LLM Naming via Snowflake Cortex — Enriched
-- Exactly 12 LLM calls (name + description × 6 clusters).
-- Cortex runs on 6 rows only. Join to users happens in dim_users.

{{ config(materialized='table') }}

SELECT
    cluster_id,
    user_count,
    user_pct,
    top_device,
    top_monetization,
    avg_clickout_rate,
    avg_search_rate,
    avg_genre_entropy,
    avg_imdb_score,
    avg_providers,
    avg_sessions,
    avg_events_per_session,
    avg_watchlist_adds,
    pct_high_imdb_users,
    pct_high_intent_buyers,
    pct_curators,
    pct_active_searchers,

    -- Name: 2-3 words, no explanation
    TRIM(SNOWFLAKE.CORTEX.COMPLETE(
        'llama3.1-70b',
        'You are naming streaming audience segments for a media analytics pitch deck. '
        || 'Give a UNIQUE, creative 2-3 word name for this specific audience cluster. '
        || 'The name should reflect their DOMINANT BEHAVIOUR — not just genre. '
        || 'Key stats: '
        || 'clickout_rate=' || avg_clickout_rate || ' (avg=0.04), '
        || 'search_rate=' || avg_search_rate || ' (avg=0.08), '
        || 'genre_entropy=' || avg_genre_entropy || ' (diversity: 0=specialist, 3=very broad), '
        || 'avg_imdb=' || avg_imdb_score || '/10, '
        || 'avg_sessions=' || avg_sessions || ', '
        || 'avg_events_per_session=' || avg_events_per_session || ', '
        || 'avg_watchlist_adds=' || avg_watchlist_adds || ', '
        || 'pct_high_intent_buyers=' || pct_high_intent_buyers || '%, '
        || 'pct_curators=' || pct_curators || '%, '
        || 'pct_active_searchers=' || pct_active_searchers || '%, '
        || 'pct_high_imdb_users=' || pct_high_imdb_users || '%, '
        || 'top_device=' || top_device || ', '
        || 'top_monetization=' || top_monetization || ', '
        || 'pct_of_all_users=' || user_pct || '%.'
        || ' Reply with ONLY the 2-3 word segment name, nothing else.'
    )) AS segment_name,

    -- Description: 1 sentence, behaviour-focused
    TRIM(SNOWFLAKE.CORTEX.COMPLETE(
        'llama3.1-70b',
        'Write one sentence (under 25 words) describing this streaming audience segment for a B2B pitch deck. '
        || 'Focus on their BEHAVIOUR and VALUE to advertisers. '
        || 'Key stats: '
        || 'clickout_rate=' || avg_clickout_rate || ', '
        || 'search_rate=' || avg_search_rate || ', '
        || 'genre_diversity=' || avg_genre_entropy || ', '
        || 'avg_imdb=' || avg_imdb_score || '/10, '
        || 'avg_sessions=' || avg_sessions || ', '
        || 'pct_buyers=' || pct_high_intent_buyers || '%, '
        || 'pct_curators=' || pct_curators || '%, '
        || 'pct_searchers=' || pct_active_searchers || '%, '
        || 'top_device=' || top_device || ', '
        || 'monetization=' || top_monetization || '.'
        || ' One sentence only, no headers.'
    )) AS segment_description

FROM {{ ref('prep_segment_profiles') }}
