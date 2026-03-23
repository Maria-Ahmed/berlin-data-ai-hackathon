-- Streaming providers consolidated to major platforms
-- Grain: 1 row per original package ID, with a consolidated platform_name
-- Amazon's 3 package IDs → one "Amazon Prime Video" label, etc.

with packages as (
    select * from {{ ref('base_packages') }}
),

provider_mapping as (
    select * from {{ ref('provider_mapping') }}
),

mapped as (
    select
        p.id as provider_id,
        p.technical_name,
        p.clear_name,
        p.monetization_types,

        -- consolidated platform name from seed mapping
        coalesce(pm.provider_group, p.clear_name) as platform_name,

        -- monetization flags
        contains(p.monetization_types::text, 'flatrate') as is_flatrate,
        contains(p.monetization_types::text, 'free') as is_free,
        contains(p.monetization_types::text, 'rent') as is_rent,
        contains(p.monetization_types::text, 'buy') as is_buy,
        contains(p.monetization_types::text, 'ads') as is_ads

    from packages p
    left join provider_mapping pm on p.id = pm.provider_id
)

select * from mapped
