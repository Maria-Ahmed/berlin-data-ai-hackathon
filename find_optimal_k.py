from snowflake.snowpark import Session
from snowflake.ml.modeling.cluster import KMeans
from snowflake.ml.modeling.preprocessing import StandardScaler
from sklearn.metrics import silhouette_score
import pandas as pd

# Connect to Snowflake using Snowpark
connection_parameters = {
    "account": "OHHGHHL-ZM06890",
    "user": "UMAIRTUFAIL2001@GMAIL.COM",
    "password": "nRr5#iwzT5Au1T",
    "database": "DB_TEAM_8",
    "schema": "CHALLENGE_PREP",
    "warehouse": "WH_TEAM_8_M",
    "role": "ROLE_TEAM_8"
}
session = Session.builder.configs(connection_parameters).create()

print("Connected to Snowflake Snowpark. Loading data...")

# Load the prep_users table (which has ~1.58M rows)
df = session.table("prep_users")

# Select numerical behavioral features
feature_cols = [
    "TOTAL_EVENTS",
    "TOTAL_SESSIONS",
    "TOTAL_CLICKOUTS",
    "TOTAL_SEARCH_EVENTS",
    "TOTAL_WATCHLIST_ADDS",
    "TOTAL_LIKES",
    "DISTINCT_PROVIDERS",
    "DISTINCT_GENRES",
    "AVG_IMDB_SCORE",
    "CLICKOUT_RATE",
    "SEARCH_RATE",
    "GENRE_ENTROPY"
]

# We need to fill na values to safely cluster
df_filled = df.fillna(value=0.0, subset=feature_cols)

# Scale the features using Standard Scaler across the cluster
print("Scaling features...")
scaler = StandardScaler(input_cols=feature_cols, output_cols=[c + "_SCALED" for c in feature_cols])
df_scaled = scaler.fit(df_filled).transform(df_filled)
scaled_cols = [c + "_SCALED" for c in feature_cols]

# We will sample 100k rows to speed up Silhouette Score computation (which is O(N^2) normally)
df_sample = df_scaled.sample(n=100000)

print(f"Testing K between 4 and 10 on {df_sample.count()} users...")

best_k = 0
best_score = -1

# Test K from 4 to 10
for k in range(4, 11):
    print(f"Training KMeans(k={k})...")
    kmeans = KMeans(n_clusters=k, input_cols=scaled_cols, output_cols=["CLUSTER_ID"])
    
    # Evaluate locally using pandas sample
    kmeans.fit(df_sample)
    predictions_df = kmeans.transform(df_sample).to_pandas()
    score = silhouette_score(predictions_df[scaled_cols], predictions_df["CLUSTER_ID"])
    
    print(f"k={k} --> Silhouette Score: {score:.4f}")
    
    if score > best_score:
        best_score = score
        best_k = k

print("\n===============================")
print(f"OPTIMAL MACRO-PERSONAS: {best_k} (Score: {best_score:.4f})")
print("===============================")

session.close()
