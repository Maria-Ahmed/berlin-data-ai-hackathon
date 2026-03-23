-- V2 Step 2: Embed user profile text with Cortex
-- Grain: 1 row per user_id
-- NOTE: ~10 min for 1.58M users on M warehouse. Materialized as TABLE to avoid re-embedding.

{{ config(materialized='table') }}

SELECT
    user_id,
    profile_text,
    SNOWFLAKE.CORTEX.EMBED_TEXT_768('snowflake-arctic-embed-m-v1.5', profile_text) AS embedding
FROM {{ ref('prep_user_profiles_text') }}
