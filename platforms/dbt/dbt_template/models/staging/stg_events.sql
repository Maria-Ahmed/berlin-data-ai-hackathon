-- Cleaned, deduplicated, typed events from T1 (Germany, Dec 2025)
-- Extracts all JSON context fields into flat columns
-- Adds boolean convenience flags for common event types

with source as (
    select * from {{ ref('base_events_t1') }}
),

deduplicated as (
    select
        *,
        row_number() over (partition by rid order by collector_tstamp) as _rn
    from source
)

select
    -- identifiers
    rid,
    user_id,
    session_id,
    session_idx,
    login_id,

    -- timestamps
    collector_tstamp,
    derived_tstamp,

    -- event classification
    event as event_type,
    se_category,
    se_action,
    se_label,
    se_property,
    se_value,

    -- extracted: content context (100% fill)
    cc_title:jwEntityId::text as title_id,
    lower(cc_title:objectType::text) as object_type,
    cc_title:seasonNumber::int as season_number,
    cc_title:episodeNumber::int as episode_number,

    -- extracted: clickout context (only on clickout events)
    cc_clickout:providerId::number as provider_id,
    cc_clickout:monetizationType::text as monetization_type,

    -- extracted: search context (sticky within session, ~17.5% fill)
    cc_search:searchEntry::text as search_query,

    -- extracted: page context (100% fill)
    cc_page_type:pageType::text as page_type,
    cc_page_type:appLocale::text as app_locale,

    -- extracted: device context (100% fill)
    cc_yauaa:deviceClass::text as device_class,

    -- geography
    geo_country,
    geo_region_name,
    geo_city,

    -- boolean flags
    case when se_category = 'clickout' then true else false end as is_clickout,
    case when cc_search is not null then true else false end as is_search_session,
    case when se_category = 'watchlist_add' then true else false end as is_watchlist_add,
    case when se_category = 'seenlist_add' then true else false end as is_seenlist_add,
    case when se_category = 'likelist_add' then true else false end as is_like,
    case when se_category = 'dislikelist_add' then true else false end as is_dislike,
    case when event = 'page_view' then true else false end as is_pageview,
    case when se_category = 'userinteraction' then true else false end as is_interaction,
    case when se_category = 'youtube_started' then true else false end as is_trailer_play,

    -- first clickout per session (for clean session→provider attribution)
    case
        when se_category = 'clickout'
            then row_number() over (
                partition by session_id, case when se_category = 'clickout' then 1 else 0 end
                order by collector_tstamp
            ) = 1
        else false
    end as is_first_clickout,

    -- engagement score (weighted signal strength)
    case
        when se_category = 'clickout' then 3
        when se_category = 'watchlist_add' then 2
        when se_category in ('likelist_add', 'seenlist_add') then 2
        when se_category = 'userinteraction' then 1
        when event = 'page_view' then 1
        else 0
    end as engagement_weight

from deduplicated
where _rn = 1
  and user_id is not null
