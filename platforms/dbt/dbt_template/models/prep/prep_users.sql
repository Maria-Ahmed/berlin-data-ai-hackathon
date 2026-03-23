-- Per-user behavioral aggregates from events
-- Grain: 1 row per user_id
-- These features feed into segment assignment

with events as (
    select * from {{ ref('stg_events') }}
),

objects as (
    select
        object_id,
        imdb_score,
        genre_tmdb
    from {{ ref('base_objects') }}
    where object_type in ('movie', 'show')
),

-- get first genre per title for genre analysis
title_genres as (
    select
        object_id,
        g.value::text as genre
    from objects,
        lateral flatten(input => genre_tmdb, outer => true) as g
    qualify row_number() over (partition by object_id order by g.index) = 1
),

provider_mapping as (
    select * from {{ ref('provider_mapping') }}
),

-- provider group with most clickouts per user
user_top_provider as (
    select
        e.user_id,
        coalesce(pm.provider_group, e.provider_id::text) as primary_provider_group
    from events e
    left join provider_mapping pm on e.provider_id = pm.provider_id
    where e.is_clickout and e.provider_id is not null
    group by e.user_id, primary_provider_group
    qualify row_number() over (partition by e.user_id order by count(*) desc) = 1
),

user_stats as (
    select
        e.user_id,

        -- volume
        count(*) as total_events,
        count(distinct e.session_id) as total_sessions,
        sum(case when e.is_clickout then 1 else 0 end) as total_clickouts,
        sum(case when e.is_search_session then 1 else 0 end) as total_search_events,
        sum(case when e.is_watchlist_add then 1 else 0 end) as total_watchlist_adds,
        sum(case when e.is_like then 1 else 0 end) as total_likes,
        sum(e.engagement_weight) as total_engagement_score,

        -- diversity
        count(distinct e.provider_id) as distinct_providers,
        count(distinct tg.genre) as distinct_genres,
        count(distinct e.title_id) as distinct_titles,

        -- quality taste
        avg(o.imdb_score) as avg_imdb_score,

        -- rates
        round(sum(case when e.is_clickout then 1 else 0 end)::float / nullif(count(*), 0), 4) as clickout_rate,
        round(sum(case when e.is_search_session then 1 else 0 end)::float / nullif(count(*), 0), 4) as search_rate,

        -- depth
        round(count(*)::float / nullif(count(distinct e.session_id), 0), 2) as avg_events_per_session,

        -- primary provider group (most clickouts)
        utp.primary_provider_group,

        -- primary genre (mode)
        mode(tg.genre) as primary_genre,

        -- primary monetization type
        mode(e.monetization_type) as primary_monetization_type,

        -- device
        mode(e.device_class) as primary_device

    from events e
    left join objects o on e.title_id = o.object_id
    left join title_genres tg on e.title_id = tg.object_id
    left join user_top_provider utp on e.user_id = utp.user_id
    group by e.user_id, utp.primary_provider_group
)

select
    *,
    -- genre entropy approximation: distinct genres / log(total events)
    -- higher = more diverse taste
    round(distinct_genres::float / nullif(ln(nullif(total_events, 0)), 0), 4) as genre_entropy

from user_stats
