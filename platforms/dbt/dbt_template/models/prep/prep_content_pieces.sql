-- Content metadata rolled up to movie/show level
-- Grain: 1 row per top-level title (movie or show)
-- Drops episodes and seasons — those aggregate into their parent title

with objects as (
    select * from {{ ref('base_objects') }}
    where object_type in ('movie', 'show')
),

-- extract first genre as primary, keep full array
with_genres as (
    select
        object_id as title_id,
        title,
        original_title,
        object_type,
        short_description,
        release_year,
        runtime,
        original_language,
        imdb_score,
        id_imdb,
        genre_tmdb as all_genres,
        genre_tmdb[0]::text as primary_genre,
        production_countries,
        production_countries[0]::text as primary_country,
        seasons,
        poster_jw
    from objects
)

select * from with_genres
