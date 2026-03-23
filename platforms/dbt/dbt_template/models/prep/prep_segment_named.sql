-- V3 Segment LLM Naming — Single-prompt approach
-- All 6 clusters sent in ONE Cortex call so the LLM can differentiate them.
-- Parses the structured response back into per-cluster rows.

{{ config(materialized='table') }}

WITH profiles AS (
    SELECT * FROM {{ ref('prep_segment_profiles') }}
    ORDER BY cluster_id
),

-- Build one prompt containing all 6 clusters
all_clusters_prompt AS (
    SELECT LISTAGG(
        'Cluster ' || cluster_id
        || ' (' || user_pct || '% of users'
        || ', clickout=' || avg_clickout_rate
        || ', search=' || avg_search_rate
        || ', imdb=' || avg_imdb_score
        || ', entropy=' || avg_genre_entropy
        || ', buyers=' || pct_high_intent_buyers || '%'
        || ', curators=' || pct_curators || '%'
        || ', searchers=' || pct_active_searchers || '%'
        || ', device=' || top_device
        || ', monetization=' || top_monetization
        || ')',
        ' | '
    ) AS clusters_summary
    FROM profiles
),

-- Single LLM call — returns all 6 names + descriptions
llm_response AS (
    SELECT TRIM(SNOWFLAKE.CORTEX.COMPLETE(
        'llama3.1-70b',
        'You are naming 6 streaming audience segments for a B2B pitch deck. '
        || 'Each cluster has different behavioral stats. You MUST give each a UNIQUE name that reflects its single most distinctive trait. '
        || 'Do NOT reuse names. Do NOT use generic words like "casual" or "mobile" for multiple clusters. '
        || 'Key: clickout=purchase intent (avg 0.04), search=discovery mode, entropy=genre diversity (0=specialist,3=broad), buyers%=high-intent, curators%=watchlist users. '
        || 'Clusters: ' || clusters_summary
        || ' Reply in EXACTLY this format, one line per cluster, nothing else: '
        || 'C0: [2-3 word name] | [one sentence description under 20 words] '
        || 'C1: [2-3 word name] | [one sentence description under 20 words] '
        || 'C2: [2-3 word name] | [one sentence description under 20 words] '
        || 'C3: [2-3 word name] | [one sentence description under 20 words] '
        || 'C4: [2-3 word name] | [one sentence description under 20 words] '
        || 'C5: [2-3 word name] | [one sentence description under 20 words]'
    )) AS raw_response
    FROM all_clusters_prompt
),

-- Parse each line: "C0: Name | Description"
parsed AS (
    SELECT
        p.cluster_id,
        p.user_count,
        p.user_pct,
        p.top_device,
        p.top_monetization,
        p.avg_clickout_rate,
        p.avg_search_rate,
        p.avg_genre_entropy,
        p.avg_imdb_score,
        p.avg_providers,
        p.avg_sessions,
        p.avg_events_per_session,
        p.avg_watchlist_adds,
        p.pct_high_imdb_users,
        p.pct_high_intent_buyers,
        p.pct_curators,
        p.pct_active_searchers,
        r.raw_response,
        -- Extract the line for this cluster: find "C{id}:" and grab until next newline
        TRIM(SPLIT_PART(
            SPLIT_PART(r.raw_response, 'C' || p.cluster_id || ':', 2),
            '\n', 1
        )) AS cluster_line
    FROM profiles p
    CROSS JOIN llm_response r
),

final AS (
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
        raw_response,
        cluster_line,
        -- Name = everything before the " | "
        TRIM(SPLIT_PART(cluster_line, '|', 1)) AS segment_name,
        -- Description = everything after the " | "
        TRIM(SPLIT_PART(cluster_line, '|', 2)) AS segment_description
    FROM parsed
)

SELECT * FROM final
ORDER BY cluster_id
