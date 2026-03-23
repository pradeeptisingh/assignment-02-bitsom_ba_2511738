# Normalization Report 

---

## Anomaly Analysis

### 1. Insert Anomaly

**Definition:** An insert anomaly occurs when a new entity cannot be recorded without including unrelated data that does not yet exist.

**Example from the dataset:**

In `orders_flat.csv`, it is **impossible to add a new product to the catalogue** (e.g., `P009 — Wireless Keyboard, Electronics, ₹1,500`) without first creating a dummy order row. Every row in the flat file represents an **order line**, not just a product. To store product information, the table demands values for `order_id`, `customer_id`, `customer_name`, `order_date`, `sales_rep_id`, etc., which are meaningless if the product simply hasn't been ordered yet.

- **Affected columns:** `product_id`, `product_name`, `category`, `unit_price` — these product attributes have no independent home.
- **Consequence:** A new product cannot exist in the system until at least one order is placed, which is a business logic problem (e.g., you can't build a product catalogue before sales begin).

---

### 2. Update Anomaly

**Definition:** An update anomaly occurs when changing a single real-world fact requires updating multiple rows, creating a risk of inconsistency.

**Example from the dataset:**

Sales rep `SR01 (Deepak Joshi)` has his `office_address` stored redundantly across every order he handled. Due to partial, inconsistent updates, two different address strings now coexist for the **same rep**:

| Row(s) | `order_id` | `sales_rep_id` | `office_address` |
|--------|------------|----------------|------------------|
| Row 1 (index 1) | ORD1114 | SR01 | `Mumbai HQ, Nariman Point, Mumbai - 400021` |
| Row 37 (index 37) | ORD1180 | SR01 | `Mumbai HQ, Nariman Pt, Mumbai - 400021` *(typo — "Pt" instead of "Point")* |

This same truncated/typo address (`Nariman Pt`) appears in **15 rows** (ORD1170–ORD1184 range), while the correct version appears in the remaining SR01 rows. If Deepak Joshi's office truly relocated, all 171 rows linked to SR01 would need to be updated — and any missed row would leave stale, contradictory data.

- **Affected columns:** `office_address` (rows where `sales_rep_id = 'SR01'`)
- **Root cause:** `office_address` is a fact about the sales rep, not about the order, yet it is repeated for every order row.

---

### 3. Delete Anomaly

**Definition:** A delete anomaly occurs when deleting a set of rows to remove one piece of information inadvertently destroys other, unrelated information.

**Example from the dataset:**

The business intends to **cancel and purge all historical orders** for the year 2023 (e.g., for data retention compliance). The hypothetical scenario involves a customer who works under the identifier C004 and corresponds with the name Sneha Iyer and the email address sneha@gmail.com and lives in Chennai. The database would lose all of Sneha Iyer's customer information through the deletion of those specific rows that include ORD1001 and ORD1013 and ORD1018 and all 22 of her orders while the business needs to keep customer contact details for CRM and marketing and compliance needs.

The company would lose all record of Ravi Kumar's employment at the company through the deletion of his orders which would also result in permanent loss of his email and office details.

- **Affected columns:** The order rows contain embedded facts about independent entities which include `customer_id`, `customer_name`, `customer_email`, `customer_city` and `sales_rep_id`, `sales_rep_name`, `sales_rep_email`.
- **Affected rows:** Any order row referencing the entity being logically "removed."

---

## Normalization Justification

The manager believes that the table exists in a simpler state because it requires no JOINs and no foreign keys and all data displays at once. The `orders_flat.csv` dataset demonstrates that simplicity which appears to be present in this situation does not exist.

The **update anomaly** identified above shows that Deepak Joshi's office address needs to be stored in all 171 order rows which connect to him. A partial address correction led to some rows receiving updates while 15 rows remained unchanged with the truncated value of `"Nariman Pt"` and other rows displayed the correct value of `"Nariman Point"`. A query needs to filter by address but it will now produce incorrect results which will go unnoticed. The address exists as a single entry in the `sales_reps` table so a single `UPDATE` operation will bring changes to all locations.

The **delete anomaly** makes the cost evaluation more transparent. The deletion of old order batches from the flat file system results in the loss of essential customer contact details which the business needs for its CRM and legal retention purposes. The only two options available to this situation involve keeping inactive order rows forever or The database system stores customer data as a separate entity from orders which allows responsible handling of orders through archiving or deletion without affecting customer records.

The **insert anomaly** shows that the flat model cannot even represent a product catalogue before the first sale -- absurd for any real retail business. The business can track its entire product inventory through a dedicated `products` table which operates independently from order processes.

Modern query optimisers together with views solve the counterargument which states that JOINs make systems more difficult to operate. A 3NF schema which has proper indexing outperforms a large flat table system when handling extensive operations because its normalized tables have reduced size.

---
