-- Provider dimension: consolidated streaming platforms
-- Grain: 1 row per original provider_id, with consolidated platform_name

select
    provider_id,
    platform_name,
    technical_name,
    clear_name,
    is_flatrate,
    is_free,
    is_rent,
    is_buy,
    is_ads

from {{ ref('prep_providers') }}
