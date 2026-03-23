# Ghost Content Discovery

## The Goal
JustWatch is uniquely positioned to understand demand and supply of movie content across providers. The is a huge commercial opportunity in providing that intelligence back to the movie platforms by surfacing anonymized analytics on that content types are under served by one particular provider, given by user behavior on other providers.

## Development setup
1. Create a new python virtual environment
```
uv venv && source .venv/bin/activate
```
2. Install dependencies
```
uv pip install -r requirements.txt
```
3. Create a copy of the `.env.example` and fill it with your Snowflake credentials
4. Load all environment variables into your terminal
```
source .env
```
5. Verify that your dbt connection works
```
source .venv/bin/activate
cd platforms/dbt/dbt_template
dbt debug
```

