# dbt Configuration

## Install dbt

```bash
pip install dbt-snowflake
```

## Create your dbt profile

dbt needs a `profiles.yml` to connect to Snowflake. Create one at `~/.dbt/profiles.yml`:

```yaml
dbt_template:
  outputs:
    dev:
      type: snowflake
      account: "<ACCOUNT_ID>"
      user: "<your-email>"
      password: "<your-password>"
      database: DB_TEAM_<N>          # ← your team's private database (e.g. DB_TEAM_1)
      schema: base
      warehouse: WH_TEAM_<N>_XS     # ← your team's warehouse (e.g. WH_TEAM_1_XS)
      threads: 4
  target: dev
```

Replace `<ACCOUNT_ID>`, your credentials, and `<N>` with your team number. The `database` must be your team database — this is where dbt will create views and tables that Lightdash can read.

## Verify connection

```bash
cd my-dbt-project
dbt debug
```

## Build base models

```bash
dbt run
```

After `dbt run`, you should see views like `DB_TEAM_<N>.base.base_events_t1`, `DB_TEAM_<N>.base.base_objects`, etc. in Snowflake.
