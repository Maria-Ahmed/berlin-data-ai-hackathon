# Snowflake

[Snowflake](https://www.snowflake.com/) is the cloud data platform where all hackathon data lives and all queries run. Each team gets a dedicated environment with compute resources and shared access to the challenge data.

## What you get

- **Shared data** — `DB_JW_SHARED.CHALLENGE` (read-only) contains all event tables (T1–T4), content metadata (OBJECTS), and provider lookup (PACKAGES)
- **Team database** — `DB_TEAM_<N>` (private, read-write) for creating your own schemas, tables, and views
- **Team warehouses** — `WH_TEAM_<N>_XS`, `WH_TEAM_<N>_S`, `WH_TEAM_<N>_M` for varying compute needs

## What's here

| File | What it covers |
| ---- | -------------- |
| [credentials.md](credentials.md) | Account details, credentials, warehouse assignments |
| [programmatic-access.md](programmatic-access.md) | Snow CLI, Python connectors, Snowpark — all ways to query Snowflake from code |
| [connections.toml](connections.toml) | Template config for `~/.snowflake/connections.toml` |
| [snowflake-hackathon-guide.pdf](snowflake-hackathon-guide.pdf) | Snowflake's hackathon guide — Cortex Code, prompt examples, learning resources |

## Quick start

1. Set up your CLI connection — see [programmatic-access.md](programmatic-access.md)
2. Copy and edit the connection template — see [connections.toml](connections.toml)
3. Test with: `snow sql -q "SELECT COUNT(*) FROM DB_JW_SHARED.CHALLENGE.T1" -c hackathon`
