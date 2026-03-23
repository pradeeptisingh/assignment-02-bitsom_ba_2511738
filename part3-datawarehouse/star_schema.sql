-- ============================================================
-- Part 3.1 — Star Schema Design
-- Data Warehouse for Retail Chain Transactions
--
-- Star schema layout:
--
--           dim_date ──────────────────────────────┐
--           dim_store ─────────────────────────────┤
--                                              fact_sales
--           dim_product ───────────────────────────┘
--
-- Source: retail_transactions.csv  (300 rows after ETL cleaning)
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- DIMENSION 1: dim_date
-- Pre-populated calendar table. Storing derived date attributes
-- here (year, quarter, month, month_name, day_of_week, is_weekend)
-- avoids recomputing them in every analytical query and enables
-- efficient GROUP BY on any date granularity.
-- ─────────────────────────────────────────────────────────────
CREATE TABLE dim_date (
    date_key       INT         PRIMARY KEY,   -- surrogate key: YYYYMMDD integer
    full_date      DATE        NOT NULL UNIQUE,
    day_of_month   TINYINT     NOT NULL,
    day_of_week    TINYINT     NOT NULL,       -- 1=Monday … 7=Sunday
    day_name       VARCHAR(10) NOT NULL,
    week_of_year   TINYINT     NOT NULL,
    month_num      TINYINT     NOT NULL,
    month_name     VARCHAR(10) NOT NULL,
    quarter        TINYINT     NOT NULL,       -- 1–4
    year           SMALLINT    NOT NULL,
    is_weekend     BOOLEAN     NOT NULL,
    is_month_end   BOOLEAN     NOT NULL
);

INSERT INTO dim_date
    (date_key, full_date, day_of_month, day_of_week, day_name, week_of_year,
     month_num, month_name, quarter, year, is_weekend, is_month_end)
VALUES
    (20230220, '2023-02-20', 20, 1, 'Monday',    8,  2,  'February', 1, 2023, FALSE, FALSE),
    (20230310, '2023-03-10', 10, 5, 'Friday',   10,  3,  'March',    1, 2023, TRUE,  FALSE),
    (20230321, '2023-03-21', 21, 2, 'Tuesday',  12,  3,  'March',    1, 2023, FALSE, FALSE),
    (20230331, '2023-03-31', 31, 5, 'Friday',   13,  3,  'March',    1, 2023, TRUE,  TRUE),
    (20230406, '2023-04-06',  6, 4, 'Thursday', 14,  4,  'April',    2, 2023, FALSE, FALSE),
    (20230428, '2023-04-28', 28, 5, 'Friday',   17,  4,  'April',    2, 2023, TRUE,  FALSE),
    (20230512, '2023-05-12', 12, 5, 'Friday',   19,  5,  'May',      2, 2023, TRUE,  FALSE),
    (20230722, '2023-07-22', 22, 6, 'Saturday', 29,  7,  'July',     3, 2023, TRUE,  FALSE),
    (20230815, '2023-08-15', 15, 2, 'Tuesday',  33,  8,  'August',   3, 2023, FALSE, FALSE),
    (20230829, '2023-08-29', 29, 2, 'Tuesday',  35,  8,  'August',   3, 2023, FALSE, FALSE),
    (20230908, '2023-09-08',  8, 5, 'Friday',   36,  9,  'September',3, 2023, TRUE,  FALSE),
    (20231020, '2023-10-20', 20, 5, 'Friday',   42, 10,  'October',  4, 2023, TRUE,  FALSE),
    (20231026, '2023-10-26', 26, 4, 'Thursday', 43, 10,  'October',  4, 2023, FALSE, FALSE),
    (20231107, '2023-11-07',  7, 2, 'Tuesday',  45, 11,  'November', 4, 2023, FALSE, FALSE),
    (20231118, '2023-11-18', 18, 6, 'Saturday', 46, 11,  'November', 4, 2023, TRUE,  FALSE);


-- ─────────────────────────────────────────────────────────────
-- DIMENSION 2: dim_store
-- One row per store. Centralises store metadata so any change
-- (e.g., store relocates, is renamed) requires updating a single row.
-- ETL fix applied: NULL store_city values were derived from store_name.
-- ─────────────────────────────────────────────────────────────
CREATE TABLE dim_store (
    store_key    INT          PRIMARY KEY AUTO_INCREMENT,
    store_id     VARCHAR(20)  NOT NULL UNIQUE,   -- natural key from source
    store_name   VARCHAR(100) NOT NULL,
    city         VARCHAR(100) NOT NULL,
    region       VARCHAR(50)  NOT NULL            -- derived during ETL
);

INSERT INTO dim_store (store_id, store_name, city, region) VALUES
    ('ST01', 'Bangalore MG',  'Bangalore', 'South'),
    ('ST02', 'Chennai Anna',  'Chennai',   'South'),
    ('ST03', 'Delhi South',   'Delhi',     'North'),
    ('ST04', 'Mumbai Central','Mumbai',    'West'),
    ('ST05', 'Pune FC Road',  'Pune',      'West');


-- ─────────────────────────────────────────────────────────────
-- DIMENSION 3: dim_product
-- One row per product. unit_price stored here is the standard list
-- price from the source; price changes over time could be handled via
-- SCD Type 2 (add effective_from / effective_to columns) if needed.
-- ETL fix applied: category values normalised to Title Case.
-- ─────────────────────────────────────────────────────────────
CREATE TABLE dim_product (
    product_key  INT          PRIMARY KEY AUTO_INCREMENT,
    product_id   VARCHAR(20)  NOT NULL UNIQUE,   -- natural key
    product_name VARCHAR(150) NOT NULL,
    category     VARCHAR(50)  NOT NULL,           -- Electronics | Clothing | Groceries
    unit_price   DECIMAL(12, 2) NOT NULL CHECK (unit_price > 0)
);

INSERT INTO dim_product (product_id, product_name, category, unit_price) VALUES
    ('PRD01', 'Atta 10kg',   'Groceries',   52464.00),
    ('PRD02', 'Biscuits',    'Groceries',   27469.99),
    ('PRD03', 'Headphones',  'Electronics', 39854.96),
    ('PRD04', 'Jacket',      'Clothing',    30187.24),
    ('PRD05', 'Jeans',       'Clothing',     2317.47),
    ('PRD06', 'Laptop',      'Electronics', 42343.15),
    ('PRD07', 'Milk 1L',     'Groceries',   43374.39),
    ('PRD08', 'Oil 1L',      'Groceries',   26474.34),
    ('PRD09', 'Phone',       'Electronics', 48703.39),
    ('PRD10', 'Pulses 1kg',  'Groceries',   31604.47),
    ('PRD11', 'Rice 5kg',    'Groceries',   34815.00),
    ('PRD12', 'Saree',       'Clothing',    35451.81),
    ('PRD13', 'Smartwatch',  'Electronics', 58851.01),
    ('PRD14', 'Speaker',     'Electronics', 49262.78),
    ('PRD15', 'T-Shirt',     'Clothing',    29770.19),
    ('PRD16', 'Tablet',      'Electronics', 23226.12);


-- ─────────────────────────────────────────────────────────────
-- FACT TABLE: fact_sales
-- Grain: one row per transaction (one product sold at one store on
-- one date by one customer).
-- Numeric measures:
--   units_sold    — additive: can be summed across any dimension
--   unit_price    — semi-additive: average or point-in-time only
--   total_revenue — additive: units_sold * unit_price (pre-computed
--                   for query performance; avoids repeated multiplication)
-- Foreign keys reference surrogate keys of dimension tables, not
-- the natural keys, following Kimball dimensional modelling best practice.
-- ─────────────────────────────────────────────────────────────
CREATE TABLE fact_sales (
    sale_id          INT            PRIMARY KEY AUTO_INCREMENT,
    transaction_id   VARCHAR(20)    NOT NULL UNIQUE,   -- natural key from source
    date_key         INT            NOT NULL,
    store_key        INT            NOT NULL,
    product_key      INT            NOT NULL,
    customer_id      VARCHAR(20)    NOT NULL,
    units_sold       INT            NOT NULL CHECK (units_sold > 0),
    unit_price       DECIMAL(12, 2) NOT NULL CHECK (unit_price > 0),
    total_revenue    DECIMAL(14, 2) NOT NULL,           -- pre-computed measure
    CONSTRAINT fk_sales_date    FOREIGN KEY (date_key)    REFERENCES dim_date    (date_key),
    CONSTRAINT fk_sales_store   FOREIGN KEY (store_key)   REFERENCES dim_store   (store_key),
    CONSTRAINT fk_sales_product FOREIGN KEY (product_key) REFERENCES dim_product (product_key)
);

-- ── 15 cleaned, representative fact rows ──────────────────────
-- Dates standardised to ISO 8601 (YYYY-MM-DD)
-- NULL store_city rows imputed from store_name
-- Category casing normalised: 'electronics' → 'Electronics', 'Grocery' → 'Groceries'
-- Revenue pre-computed: total_revenue = units_sold * unit_price
-- ──────────────────────────────────────────────────────────────
INSERT INTO fact_sales
    (transaction_id, date_key, store_key, product_key, customer_id,
     units_sold, unit_price, total_revenue)
VALUES
--  TXN          date_key  store product  cust        qty   unit_price   revenue
    ('TXN5000', 20230829,  2,    14,  'CUST045',   3,  49262.78,   147788.34),  -- Chennai  Electronics Speaker
    ('TXN5003', 20230220,  3,    16,  'CUST007',  14,  23226.12,   325165.68),  -- Delhi    Electronics Tablet
    ('TXN5005', 20230908,  1,     1,  'CUST027',  12,  52464.00,   629568.00),  -- Bangalore Groceries Atta
    ('TXN5006', 20230331,  5,    13,  'CUST025',   6,  58851.01,   353106.06),  -- Pune     Electronics Smartwatch
    ('TXN5007', 20231026,  5,     5,  'CUST041',  16,   2317.47,    37079.52),  -- Pune     Clothing    Jeans
    ('TXN5009', 20230815,  1,    13,  'CUST020',   3,  58851.01,   176553.03),  -- Bangalore Electronics Smartwatch
    ('TXN5010', 20230406,  2,     4,  'CUST031',  15,  30187.24,   452808.60),  -- Chennai  Clothing    Jacket
    ('TXN5011', 20231020,  4,     5,  'CUST045',  13,   2317.47,    30127.11),  -- Mumbai   Clothing    Jeans
    ('TXN5013', 20230428,  4,     7,  'CUST015',  10,  43374.39,   433743.90),  -- Mumbai   Groceries   Milk
    ('TXN5014', 20231118,  3,     4,  'CUST042',   5,  30187.24,   150936.20),  -- Delhi    Clothing    Jacket
    ('TXN5017', 20230512,  1,     4,  'CUST019',   6,  30187.24,   181123.44),  -- Bangalore Clothing   Jacket
    ('TXN5019', 20230722,  2,     1,  'CUST008',   3,  52464.00,   157392.00),  -- Chennai  Groceries   Atta
    ('TXN5024', 20230310,  4,     3,  'CUST024',   8,  39854.96,   318839.68),  -- Mumbai   Electronics Headphones
    ('TXN5025', 20230321,  5,    10,  'CUST032',  19,  31604.47,   600484.93),  -- Pune     Groceries   Pulses
    ('TXN5094', 20231107,  3,     8,  'CUST007',   3,  26474.34,    79423.02);  -- Delhi    Groceries   Oil
