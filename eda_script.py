import snowflake.connector
import pandas as pd
import warnings
warnings.filterwarnings('ignore')

conn = snowflake.connector.connect(
    account="OHHGHHL-ZM06890",
    user="UMAIRTUFAIL2001@GMAIL.COM",
    password="nRr5#iwzT5Au1T",
    database="DB_TEAM_8",
    schema="CHALLENGE_prep",
    warehouse="WH_TEAM_8_M",
    role="ROLE_TEAM_8"
)

df = pd.read_sql("""
SELECT
    cluster_id,
    user_count,
    user_pct,
    top_device,
    top_monetization,
    ROUND(avg_clickout_rate, 4) AS clickout_rate,
    ROUND(avg_search_rate, 4) AS search_rate,
    ROUND(pct_high_intent_buyers, 1) AS pct_buyers,
    ROUND(pct_curators, 1) AS pct_curators,
    ROUND(pct_active_searchers, 1) AS pct_searchers,
    segment_name,
    segment_description
FROM DB_TEAM_8.CHALLENGE_prep.prep_segment_named
ORDER BY user_count DESC
""", conn)

conn.close()
pd.set_option('display.max_colwidth', 80)
pd.set_option('display.width', 200)
print(df.to_string(index=False))
