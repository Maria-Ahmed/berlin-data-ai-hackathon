import snowflake.snowpark.functions as F
import snowflake.snowpark.types as T
from snowflake.ml.modeling.cluster import KMeans
from snowflake.ml.modeling.preprocessing import StandardScaler

def model(dbt, session):
    dbt.config(
        materialized="table",
        packages=["snowflake-snowpark-python", "snowflake-ml-python"]
    )
    
    # Fix for Snowpark ML Temp Stage creation missing schema context inside dbt SP
    session.use_database(dbt.this.database)
    session.use_schema(dbt.this.schema)
    
    # Load prep_users
    df = dbt.ref("prep_users")
    
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
    
    # Cast all feature columns to DoubleType so fillna(0.0) matches the type exactly and succeeds
    for col in feature_cols:
        df = df.with_column(col, F.col(col).cast(T.DoubleType()))
        
    # Now we can safely fill NA 
    df_filled = df.fillna(value=0.0, subset=feature_cols)
    
    scaled_cols = [f"{c}_SCALED" for c in feature_cols]
    
    # 1. Scale Features
    scaler = StandardScaler(input_cols=feature_cols, output_cols=scaled_cols)
    # fit_transform doesn't exist natively on this particular wrapper version, so we fit then transform
    scaler.fit(df_filled)
    df_scaled = scaler.transform(df_filled)
    
    # 2. KMeans Clustering
    kmeans = KMeans(n_clusters=6, input_cols=scaled_cols, output_cols=["CLUSTER_ID"])
    # Train the model on the full 1.58M rows in Snowflake compute!
    kmeans.fit(df_scaled)
    df_assigned = kmeans.predict(df_scaled)
    
    # 3. Clean up the output dataframe
    # We keep the raw features + the cluster ID, minus the scaled noise
    cols_to_keep = [col for col in df_assigned.columns if not col.endswith('_SCALED')]
    final_df = df_assigned.select(cols_to_keep)
    print(final_df.show())
    return final_df
