-- User dimension: behavioral features + segment assignment
-- Grain: 1 row per user_id

select
    u.user_id,

    -- segment
    s.segment_id,
    s.segment_name,

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
    u.primary_provider_id,
    u.primary_genre,
    u.primary_monetization_type,
    u.primary_device

from {{ ref('prep_users') }} u
left join {{ ref('prep_user_segments') }} s on u.user_id = s.user_id
