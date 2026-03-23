-- Fact table: cleaned events with FKs to all dimensions
-- Grain: 1 row per event (deduplicated)

select
    -- event identifiers
    e.rid as event_id,
    e.session_id,
    e.collector_tstamp as event_timestamp,
    e.derived_tstamp,

    -- dimension FKs
    e.user_id,             -- → dim_users
    e.title_id,            -- → dim_content
    e.provider_id,         -- → dim_providers (null if not clickout)

    -- event classification
    e.se_category,
    e.se_action,
    e.page_type,
    e.app_locale,
    e.device_class,

    -- content context
    e.object_type,
    e.monetization_type,

    -- search context
    e.search_query,
    e.is_search_session,

    -- boolean measures
    e.is_clickout,
    e.is_watchlist_add,
    e.is_seenlist_add,
    e.is_like,
    e.is_dislike,
    e.is_pageview,
    e.is_interaction,
    e.is_trailer_play,

    -- engagement
    e.engagement_weight

from {{ ref('stg_events') }} e
