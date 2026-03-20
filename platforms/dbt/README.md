# dbt

[dbt](https://www.getdbt.com/) (data build tool) transforms raw data in Snowflake into clean, tested, documented models. Use it to organise your SQL transformations and deploy them to Lightdash for visualisation.

## What's here

| Path | What it covers |
| ---- | -------------- |
| [profiles.md](profiles.md) | dbt profile setup for connecting to your team's Snowflake database |
| [dbt_template/](dbt_template/) | Bootstrap dbt project — sources registered, base models for all tables |

## The bootstrap project

[dbt_template/](dbt_template/) is a ready-to-use dbt project with:

- **Sources** — all shared tables registered in [dbt_template/models/base/sources.yml](dbt_template/models/base/sources.yml) with full column descriptions
- **Base models** — simple `SELECT *` pass-throughs for every source table (`base_events_t1` through `base_events_t4`, `base_objects`, `base_packages`)

These base models read from the shared database (`DB_JW_SHARED.CHALLENGE`) but materialise as views in your team's private database (`DB_TEAM_<N>.base`). Everything beyond `base/` is yours to build.

## Setup

1. Copy the project to your working directory: `cp -r platforms/dbt/dbt_template/ my-dbt-project`
2. Create a dbt profile — see [profiles.md](profiles.md)
3. Run `dbt debug` to verify your connection
4. Run `dbt run` to materialise the base views

## AI-assisted dbt development

This repo includes **dbt agent skills** (from [dbt-labs/dbt-agent-skills](https://github.com/dbt-labs/dbt-agent-skills)) that help AI coding assistants work with dbt:

| Skill | What it does |
| ----- | ------------ |
| `using-dbt-for-analytics-engineering` | Builds and modifies dbt models, writes SQL with `ref()` and `source()`, validates with `dbt show` |
| `running-dbt-commands` | Formats and runs dbt CLI commands correctly |
| `adding-dbt-unit-test` | Creates unit test YAML definitions to validate model logic |
| `answering-natural-language-questions-with-dbt` | Translates business questions into SQL queries against your models |

These are registered in `.claude/skills/` and your AI assistant will use them automatically when working on dbt tasks.
