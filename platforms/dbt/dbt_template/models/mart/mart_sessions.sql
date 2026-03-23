SELECT
  fs.session_id,
  fs.session_start,
  fs.has_clickout,
  case when fs.has_clickout then 1 else 0 end as is_conversion,

  -- user attributes
  fs.user_id,
  du.segment_heuristic_name as segment_name,
  du.segment_embedding_name as segment_embedding_name,
  du.segment_kmeans_name as segment_kmeans_name,

  -- content attributes
  dc.title,
  dc.primary_genre,
  dc.short_description,

  -- provider attributes (session-level: from first clickout)
  dp.platform_name as provider_group,

  -- provider attributes (user-level: most converted provider group)
  du.primary_provider_group as user_primary_provider

FROM
  {{ ref('fct_sessions') }} fs
LEFT JOIN
  {{ ref('dim_users') }} du ON du.user_id = fs.user_id
LEFT JOIN
  {{ ref('dim_providers') }} dp ON dp.provider_id = fs.first_clickout_provider_id
LEFT JOIN
  {{ ref('dim_content') }} dc ON dc.title_id = fs.first_clickout_title_id