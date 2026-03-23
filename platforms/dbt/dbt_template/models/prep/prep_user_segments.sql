-- Assign each user to a behavioral segment using heuristic rules
-- Grain: 1 row per user_id (with segment_id + segment_name)
--
-- Segmentation logic: rule-based CASE WHEN on prep_users features
-- Priority order: first matching rule wins
-- TODO: Replace with Snowflake ML K-means if time allows

with users as (
    select * from {{ ref('prep_users') }}
),

-- compute percentiles for relative thresholds
percentiles as (
    select
        percentile_cont(0.75) within group (order by clickout_rate) as p75_clickout_rate,
        percentile_cont(0.75) within group (order by avg_imdb_score) as p75_imdb,
        percentile_cont(0.25) within group (order by avg_imdb_score) as p25_imdb,
        percentile_cont(0.75) within group (order by genre_entropy) as p75_genre_entropy,
        percentile_cont(0.25) within group (order by genre_entropy) as p25_genre_entropy,
        percentile_cont(0.75) within group (order by total_sessions) as p75_sessions,
        percentile_cont(0.75) within group (order by total_watchlist_adds) as p75_watchlist,
        percentile_cont(0.25) within group (order by total_events) as p25_events,
        percentile_cont(0.75) within group (order by distinct_providers) as p75_providers
    from users
    where total_events >= 3  -- filter noise
),

segmented as (
    select
        u.*,
        case
            -- Deal Hunter: high clickout rate + primarily free/ads content
            when u.clickout_rate >= p.p75_clickout_rate
                and u.primary_monetization_type in ('free', 'ads')
                then 1

            -- Cinephile: high IMDB taste + focused genres (low entropy)
            when u.avg_imdb_score >= p.p75_imdb
                and u.genre_entropy <= p.p25_genre_entropy
                and u.total_events >= 10
                then 2

            -- Binge Curator: many sessions + focused on few genres
            when u.total_sessions >= p.p75_sessions
                and u.genre_entropy <= p.p25_genre_entropy
                then 3

            -- Family Planner: high watchlist usage + family/animation genres
            when u.total_watchlist_adds >= p.p75_watchlist
                and u.primary_genre in ('Animation', 'Family', 'Comedy', 'Kids')
                then 4

            -- Omnivore: high genre entropy + many providers
            when u.genre_entropy >= p.p75_genre_entropy
                and u.distinct_providers >= p.p75_providers
                then 5

            -- Casual Scroller: low event count + few sessions
            when u.total_events <= p.p25_events
                then 6

            -- Default: unclassified → assign to nearest by primary behavior
            else 7
        end as segment_id

    from users u
    cross join percentiles p
)

select
    user_id,
    segment_id,
    case segment_id
        when 1 then 'Deal Hunter'
        when 2 then 'Cinephile'
        when 3 then 'Binge Curator'
        when 4 then 'Family Planner'
        when 5 then 'Omnivore'
        when 6 then 'Casual Scroller'
        when 7 then 'Mainstream'
    end as segment_name
from segmented
