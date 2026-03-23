-- Content dimension: movies and shows with metadata
-- Grain: 1 row per title_id (top-level titles only)

select
    title_id,
    title,
    original_title,
    object_type,
    primary_genre,
    all_genres,
    imdb_score,
    release_year,
    runtime,
    original_language,
    primary_country,
    seasons,
    short_description,
    poster_jw

from {{ ref('prep_content_pieces') }}
