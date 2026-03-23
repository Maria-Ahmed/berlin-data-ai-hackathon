-- V2 Step 1: Convert user features to natural language for embedding
-- Grain: 1 row per user_id

SELECT
    user_id,

    'Streaming user: clickout_rate=' || ROUND(COALESCE(clickout_rate, 0), 3)
    || ' (' || CASE
        WHEN clickout_rate > 0.1 THEN 'high'
        WHEN clickout_rate > 0.03 THEN 'medium'
        ELSE 'low' END || ')'
    || ', genre_entropy=' || ROUND(COALESCE(genre_entropy, 0), 2)
    || ' (' || CASE
        WHEN genre_entropy > 2 THEN 'very diverse'
        WHEN genre_entropy > 1 THEN 'moderate'
        ELSE 'specialist' END || ')'
    || ', avg_imdb=' || ROUND(COALESCE(avg_imdb_score, 0), 1) || '/10'
    || ', platforms=' || COALESCE(distinct_providers, 0)
    || ', primary_genre=' || COALESCE(primary_genre, 'unknown')
    || ', monetization=' || COALESCE(primary_monetization_type, 'unknown')
    || ', discovery=' || CASE
        WHEN search_rate > 0.1 THEN 'active_searcher'
        ELSE 'browser' END
    AS profile_text

FROM {{ ref('prep_users') }}
