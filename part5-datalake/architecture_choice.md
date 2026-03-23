# Data Architecture Choice

## Architecture Recommendation

### Recommendation: Data Lakehouse

For a fast-growing food delivery startup ingesting GPS location logs, customer text reviews, payment transactions, and restaurant menu images, a **Data Lakehouse** is the right architecture — and the three specific reasons below explain why neither a pure Data Warehouse nor a pure Data Lake is sufficient on its own.

**1. Multi-modal, schema-diverse data rules out a Data Warehouse.**
A traditional Data Warehouse (Snowflake, Redshift, BigQuery) requires structured, tabular data with a fixed schema. GPS logs are high-frequency time-series, customer reviews are unstructured text, payment records are semi-structured, and menu images are binary blobs. Forcing all of these into a rigid star schema would require lossy transformations — discarding the raw review text, downsampling GPS coordinates, dropping image metadata — and would make it impossible to later run NLP sentiment analysis or computer vision on the originals. A Lakehouse stores all raw formats in cheap object storage (S3/GCS) while layering an open table format (Delta Lake, Apache Iceberg) on top for structured query access.

**2. ACID transactions on raw storage prevent the "data swamp" problem of a pure Data Lake.**
A naive Data Lake gives you cheap, flexible storage but no transactional guarantees — concurrent writers corrupt files, failed ETL jobs leave partial data, and there is no versioning. For a payment transaction dataset, this is a compliance and audit failure waiting to happen. The Lakehouse adds ACID semantics via Delta Lake or Iceberg, enabling safe concurrent writes, time-travel queries (point-in-time auditing for regulators), and schema enforcement where needed — without giving up flexibility for the unstructured data types.

**3. Unified serving for both BI and ML from a single storage tier.**
The startup needs two very different consumers: a BI dashboard (revenue by city, order volume trends) that benefits from optimised columnar query performance, and a data science team building an ETA prediction model that needs raw GPS sequences. A Lakehouse serves both: analysts query curated Delta tables with DuckDB or Spark SQL at near-warehouse speed, while ML engineers read raw parquet files with pandas or PyTorch DataLoader from the same storage layer. A Data Warehouse would require a separate feature store or data lake export for ML workloads — doubling storage costs and creating data synchronisation risks.
