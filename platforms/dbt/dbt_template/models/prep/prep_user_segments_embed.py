"""
V2 Step 3: K-Means clustering on 768-dim embedding vectors.
Strategy: Train on 50K sample (fits in memory), assign all 1.58M by nearest centroid via SQL.
"""

def model(dbt, session):
    dbt.config(
        materialized="table",
        packages=["pandas", "scikit-learn", "numpy"],
    )

    import numpy as np
    from sklearn.cluster import KMeans
    from sklearn.preprocessing import StandardScaler

    # Step 1: Sample 50K users for clustering (fits in Snowpark memory)
    sample_df = dbt.ref("prep_user_embeddings").select(
        "USER_ID", "EMBEDDING"
    ).sample(n=50000).to_pandas()

    # Step 2: Convert vectors + cluster the sample
    X = np.stack(sample_df["EMBEDDING"].apply(
        lambda v: np.array(v, dtype=np.float32)
    ).values)
    X_scaled = StandardScaler().fit_transform(X)

    km = KMeans(n_clusters=6, random_state=42, n_init=10)
    sample_df["CLUSTER_ID"] = km.fit_predict(X_scaled)

    # Step 3: Save centroids as a temp table so SQL can assign the rest
    centroids = km.cluster_centers_  # shape: (6, 768)
    import pandas as pd
    centroid_rows = []
    for i, c in enumerate(centroids):
        centroid_rows.append({
            "CLUSTER_ID": i,
            "CENTROID": c.tolist()
        })
    centroid_df = pd.DataFrame(centroid_rows)

    # Write centroids to temp table
    session.use_database(dbt.this.database)
    session.use_schema(dbt.this.schema)
    c_sp = session.create_dataframe(centroid_df)
    c_sp.write.mode("overwrite").save_as_table("_v2_centroids_temp")

    # Step 4: Assign ALL users to nearest centroid via Snowflake vector similarity
    # This runs in SQL on Snowflake compute — no memory issue
    result = session.sql(f"""
        WITH centroids AS (
            SELECT cluster_id, centroid::VECTOR(FLOAT, 768) AS centroid_vec
            FROM {dbt.this.database}.{dbt.this.schema}._v2_centroids_temp
        )
        SELECT
            e.user_id,
            c.cluster_id
        FROM {dbt.this.database}.DEV_VLANGE_prep.prep_user_embeddings e
        CROSS JOIN centroids c
        QUALIFY ROW_NUMBER() OVER (
            PARTITION BY e.user_id
            ORDER BY VECTOR_COSINE_SIMILARITY(e.embedding, c.centroid_vec) DESC
        ) = 1
    """)

    return result
