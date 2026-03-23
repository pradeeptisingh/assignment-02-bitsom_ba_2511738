# ETL Notes — retail_transactions.csv → Data Warehouse

## ETL Decisions

### Decision 1 — Mixed Date Format Standardisation

**Problem:**
The `date` column contained three distinct formats coexisting in the same column: `DD/MM/YYYY` (e.g., `29/08/2023`), `DD-MM-YYYY` (e.g., `12-12-2023`), and `YYYY-MM-DD` (e.g., `2023-02-05`). A naive `pd.to_datetime()` call with a single fixed format raises a `ValueError` on the first non-matching row. More dangerously, without the `dayfirst=True` flag, a date like `05-06-2023` could be parsed as May 6 instead of June 5, silently corrupting the time dimension and making month-level aggregations wrong.

**Resolution:**
Parsed all dates using `pd.to_datetime(df['date'], format='mixed', dayfirst=True)`. The `format='mixed'` argument instructs pandas to infer the format row-by-row rather than applying a single global pattern, while `dayfirst=True` ensures that ambiguous numeric dates (where the day value ≤ 12) are interpreted consistently as day-first. All dates were then converted to the ISO 8601 standard (`YYYY-MM-DD`) for storage. The `date_key` surrogate (`YYYYMMDD` integer) in `dim_date` was derived from this standardised form, making range scans (`BETWEEN 20230101 AND 20231231`) efficient via integer comparison rather than string matching.

---

### Decision 2 — NULL `store_city` Imputation

**Problem:**
19 rows (≈ 6.3% of the dataset) had `NULL` in the `store_city` column. Left unaddressed, these rows would be excluded from any `GROUP BY store_city` query, silently under-reporting revenue for the affected stores. The NULLs were not random: inspection showed that every NULL city row belonged to a known store name (`Mumbai Central`, `Chennai Anna`, `Delhi South`, `Pune FC Road`), suggesting that the source extract simply omitted the city for a subset of records rather than representing genuinely unknown locations.

**Resolution:**
Applied a deterministic lookup map (`store_name → city`) to fill the NULLs: `df['store_city'] = df['store_city'].fillna(df['store_name'].map(city_map))`. Because each store name maps to exactly one city (one-to-one relationship verified by inspecting non-NULL rows), this imputation is lossless — it recovers true data, not an estimate. In the warehouse, city is stored in `dim_store` alongside `store_name`, so the city value only needs to be correct once per store rather than per transaction. A `region` column (North / South / West) was also derived from city during this step to support region-level roll-up queries without additional ETL later.

---

### Decision 3 — Category Casing Normalisation

**Problem:**
The `category` column contained five distinct string values for what should be only three categories: `'Electronics'`, `'electronics'` (lowercase), `'Clothing'`, `'Groceries'`, and `'Grocery'` (inconsistent singular form). Without normalisation, a `GROUP BY category` query would return five rows instead of three, fragmenting the Electronics and Groceries buckets and under-reporting revenue for those categories. This is a classic data quality issue that arises when multiple upstream systems or data-entry operators write to the same column without enforcing a controlled vocabulary.

**Resolution:**
Applied a replacement map to standardise all values to Title Case: `{'electronics': 'Electronics', 'Grocery': 'Groceries'}`. The corrected values were validated against a three-value allowlist `{'Electronics', 'Clothing', 'Groceries'}` — any row outside this set would be flagged for manual review rather than silently passed through. In the warehouse schema, `dim_product.category` is defined as a `VARCHAR(50)` column and a `CHECK` constraint or application-level enum could be added to prevent future non-standard values from entering the warehouse.
