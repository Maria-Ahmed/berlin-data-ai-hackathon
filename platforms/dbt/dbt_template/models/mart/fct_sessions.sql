-- Session-level fact table: pre-aggregated from fct_events
-- Grain: 1 row per user_id × session_id
-- Primary table for dashboard queries (faster than event grain)

with events as (
    select * from {{ ref('fct_events') }}
),

session_agg as (
    select
        user_id,
        session_id,

        -- time
        min(event_timestamp) as session_start,
        max(event_timestamp) as session_end,

        -- volume
        count(*) as total_events,
        sum(case when is_clickout then 1 else 0 end) as clickout_count,
        sum(case when is_search_session then 1 else 0 end) as search_event_count,
        sum(case when is_watchlist_add then 1 else 0 end) as watchlist_add_count,
        sum(case when is_like then 1 else 0 end) as like_count,
        sum(case when is_trailer_play then 1 else 0 end) as trailer_count,
        sum(engagement_weight) as engagement_score,

        -- diversity
        count(distinct provider_id) as distinct_providers,
        count(distinct title_id) as distinct_titles,

        -- primary attributes (mode per session)
        mode(provider_id) as primary_provider_id,
        mode(monetization_type) as primary_monetization_type,

        -- search
        max(search_query) as last_search_query,
        max(case when is_search_session then 1 else 0 end)::boolean as has_search,

        -- booleans
        max(case when is_clickout then 1 else 0 end)::boolean as has_clickout,
        mode(device_class) as device_class,
        mode(app_locale) as app_locale

    from events
    group by user_id, session_id
)

select * from session_agg
