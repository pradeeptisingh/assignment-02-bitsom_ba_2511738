# Capstone Design Justification

## Storage Systems

The architecture assigns each of the four goals to the storage system best matched to its access pattern and latency requirements.

**Goal 1 — Readmission prediction** draws its training data from the **Data Lakehouse** (Delta Lake on S3). The gold-zone tables in the Lakehouse aggregate cleaned, feature-engineered patient history — diagnoses, vitals trends, medication history, length-of-stay records — at the granularity an ML model needs. Lakehouse's columnar Parquet format enables the large-scale batch reads required for model training without impacting the operational database. The trained model artefacts are versioned in **MLflow**, ensuring reproducibility and rollback.

**Goal 2 — Natural-language patient history search** uses a **vector database** (pgvector as an extension on PostgreSQL, or Weaviate for larger scale). Clinical notes from the EHR are chunked and embedded using a clinical-domain language model (e.g., BioMedBERT). At query time, the doctor's plain-English question is embedded and matched via approximate nearest-neighbour (ANN) search against the stored note chunks. The top-k chunks are passed to a large language model (GPT-4 / Claude) as context in a RAG pipeline, producing a grounded, source-cited answer. The operational source of truth remains **PostgreSQL**.

**Goal 3 — Monthly management reports** uses a **Snowflake Data Warehouse** fed by ELT from the Lakehouse. Snowflake's star schema (fact_admissions, dim_date, dim_department, dim_bed) enables sub-second aggregation queries over years of history. Power BI or Metabase connects directly to Snowflake for dashboard and PDF generation.

**Goal 4 — Real-time ICU vitals streaming** uses **InfluxDB**, a purpose-built time-series database. InfluxDB supports sub-second write throughput, automatic downsampling of historical data, and continuous queries for threshold-based alerting (e.g., SpO₂ < 90 → immediate page to nursing station via Apache Flink). A 90-day retention policy keeps hot data in InfluxDB; older vitals are archived to the Lakehouse for long-term ML feature use.

---

## OLTP vs OLAP Boundary

The OLTP boundary ends at **PostgreSQL and InfluxDB**. These are the systems that accept primary writes from clinical applications — the EHR writes new patient encounters, orders, and medication records to PostgreSQL; ICU monitoring devices write waveform samples to InfluxDB. All writes that directly support patient care happen here. PostgreSQL provides ACID guarantees essential for clinical data integrity: a prescription write either commits fully or not at all.

The OLAP boundary begins at the **Data Lakehouse**. Change Data Capture (CDC) from PostgreSQL (via Debezium) streams row-level changes into the Lakehouse in near-real time, where they land in the raw zone and are progressively refined through ETL pipelines into curated and gold zones. Nothing in the OLAP layer is written to by clinical applications — it is a read-optimised replica. The Snowflake Data Warehouse sits one further step downstream, receiving pre-aggregated gold-zone tables via scheduled ELT, and is accessed exclusively by the reporting and BI layer.

This separation ensures that analytical workloads — large-scale model training jobs, multi-year reporting queries — never contend with OLTP writes and cannot affect latency for clinical staff.

---

## Trade-offs

**Trade-off: Lakehouse ETL lag vs. freshness for Goal 1**

The readmission risk model draws its features from the Lakehouse gold zone, which is updated via CDC + batch ETL. Depending on pipeline scheduling, this introduces a lag of anywhere from a few minutes (near-real-time CDC with micro-batch processing) to several hours (nightly batch). For a risk model used at admission triage, this is generally acceptable — a patient's historical diagnoses and past readmissions do not change intraoperatively. However, if real-time features (e.g., current vitals trend, latest lab result from the past two hours) are incorporated into the feature set, the batch Lakehouse path becomes a bottleneck.

**Mitigation:** Implement a **feature store** (e.g., Feast or Tecton) as a hybrid serving layer. The feature store maintains two feature views: a batch view sourced from the Lakehouse gold zone (for historical features updated hourly or nightly) and an online view sourced directly from InfluxDB and a Redis cache (for real-time features at sub-second freshness). At inference time, the serving API fetches both views and concatenates them. This preserves the Lakehouse as the system of record for historical features while eliminating the freshness bottleneck for time-sensitive signals, without requiring the ML model to query multiple heterogeneous stores at inference time.
