# Lightdash Setup

## GUI Access

- **URL**: [hackathon.lightdash.cloud](https://hackathon.lightdash.cloud)
- **Login**: you'll receive an email invite — click the link and create your account
- **Project**: your team project (Team 1, Team 2, etc.) is pre-selected based on your group

## Install and authenticate the Lightdash CLI

```bash
# Install
npm install -g @lightdash/cli

# Verify
lightdash --version

# Authenticate
lightdash login https://hackathon.lightdash.cloud --token <YOUR_PERSONAL_ACCESS_TOKEN>
```

To get your personal access token:

1. Log in to [hackathon.lightdash.cloud](https://hackathon.lightdash.cloud)
2. Click your avatar (bottom-left) → **Settings**
3. Go to **Personal Access Tokens** → **Create new token**
4. Copy the token and use it in the command above

## Set your team project

```bash
# List available projects to find your team's project UUID
lightdash config list-projects

# Set your team's project as default
lightdash config set-project --project <PROJECT_UUID>
```

## Deploy dbt models to Lightdash

> **Important:** Each team's Lightdash project is connected to your team's private database (`DB_TEAM_<N>`), **not** the shared database. Your dbt models read from `DB_JW_SHARED.CHALLENGE` but write to your team database — that's where Lightdash looks.

From your dbt project directory:

```bash
# Compile dbt and deploy models to Lightdash
lightdash deploy
```

After deploying, your dbt models appear under **Explore** in the Lightdash UI.

## Adding models and re-deploying

After adding or changing dbt models:

```bash
dbt run
lightdash deploy
```

## End-to-end flow

```text
┌─────────────────────────────────────────────────────────────────┐
│  DB_JW_SHARED.CHALLENGE     DB_TEAM_<N>        Lightdash       │
│  (shared, read-only)        (your team DB)     (your project)  │
│                                                                 │
│  T1, T2, T3, T4  ──dbt──▶  base.base_events   ──deploy──▶     │
│  OBJECTS          ──dbt──▶  base.base_objects      Explore      │
│  PACKAGES         ──dbt──▶  base.base_packages     (charts &   │
│                             marts.your_model        dashboards) │
└─────────────────────────────────────────────────────────────────┘
```

## Resources

- [Lightdash documentation](https://docs.lightdash.com/)
- [Lightdash AI agent documentation](https://docs.lightdash.com/guides/ai-agents)
