-- Streaming providers consolidated to major platforms
-- Grain: 1 row per original package ID, with a consolidated platform_name
-- Amazon's 3 package IDs → one "Amazon Prime Video" label, etc.

with packages as (
    select * from {{ ref('base_packages') }}
),

mapped as (
    select
        id as provider_id,
        technical_name,
        clear_name,
        monetization_types,

        -- consolidate sub-brands into major platforms
        case
            when id in (9, 119) then 'Amazon Prime Video'
            when id in (10, 50) then 'Amazon Store'
            when id = 8 then 'Netflix'
            when id = 337 then 'Disney+'
            when id = 2 then 'Apple TV Store'
            when id = 350 then 'Apple TV+'
            when id = 283 then 'Crunchyroll'
            when id = 1945 then 'Plex'
            when id = 2285 then 'JustWatch TV'
            when id = 304 then 'Joyn'
            when id = 30 then 'WOW'
            when id = 219 then 'ARD Mediathek'
            when id = 20 then 'maxdome'
            when id = 421 then 'ZDF Mediathek'
            when id = 445 then 'RTL+'
            when id = 1899 then 'MagentaTV'
            when id = 175 then 'MUBI'
            when id = 531 then 'Paramount+'
            else clear_name
        end as platform_name,

        -- monetization flags
        contains(monetization_types::text, 'flatrate') as is_flatrate,
        contains(monetization_types::text, 'free') as is_free,
        contains(monetization_types::text, 'rent') as is_rent,
        contains(monetization_types::text, 'buy') as is_buy,
        contains(monetization_types::text, 'ads') as is_ads

    from packages
)

select * from mapped
