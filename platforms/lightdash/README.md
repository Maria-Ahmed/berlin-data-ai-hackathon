# Lightdash

[Lightdash](https://www.lightdash.com/) is an open-source BI tool connected to your team's Snowflake database. Use it to build dashboards and visualisations for your analysis and final presentation.

The recommended workflow: set up a dbt project, deploy it to Lightdash via the CLI, then use **Explore** to build charts and dashboards from your models' dimensions and metrics.

## What's here

| File | What it covers |
| ---- | -------------- |
| [setup.md](setup.md) | GUI access, CLI installation, authentication, deploying dbt models |

## AI-assisted Lightdash development

This repo includes a **Lightdash skill** (`.claude/skills/developing-in-lightdash/`) that lets you describe what you want in plain language and have your AI assistant generate the configuration.

The skill can:

- Add **metrics and dimensions** to your dbt models (Lightdash meta properties)
- Create **charts** (bar, line, pie, table, big number, funnel, and more) as code
- Build **dashboards** combining multiple charts with filters
- Handle the full `lightdash deploy` / `lightdash download` / `lightdash upload` workflow

**Example:** Tell your AI assistant _"I want a bar chart showing top 10 streaming providers by clickout count, broken down by country"_ — it will create the dbt model with the right Lightdash metadata, deploy it, and generate the chart.

## Quick start

1. Get the Lightdash CLI working — see [setup.md](setup.md)
2. Deploy your dbt project to Lightdash
3. Use AI skills or the Lightdash UI to build explores and dashboards

Oli from Lightdash will give a live demo during the kickoff.

## Lightdash resources

### Video tutorials

- [Full onboarding playlist](https://youtube.com/playlist?list=PL0KkGNSO0W0P0JOrScLet9Nvn9mY0L_H) — the best starting point
- [Building with AI in Lightdash](https://youtube.com/playlist?list=PL0KkGNSO0W0N7Zk5V22186DHMKaJ8FU2A&si=PE7ovOg-x7ONsf34)

### Documentation

1. [Exploring data and building charts](https://docs.lightdash.com/get-started/exploring-data/using-explores)
2. [Creating dashboards](https://docs.lightdash.com/get-started/exploring-data/dashboards)
3. [SQL Runner](https://docs.lightdash.com/guides/developer/sql-runner) — write custom SQL, build charts, and create reusable virtual views
4. [AI Agents](https://docs.lightdash.com/guides/ai-agents/getting-started) — ask questions in plain English, get charts back instantly
5. [Lightdash Skills](https://docs.lightdash.com/guides/developer/agent-skills) — use AI coding tools to build and maintain dashboards
6. [Lightdash MCP](https://docs.lightdash.com/references/integrations/lightdash-mcp) — use AI agents to interact with Lightdash programmatically (via Claude, Cursor, etc.)

### Live demo

Interact with the [Lightdash live demo](https://demo.lightdash.com/) to get a feel for the platform before the hackathon.
