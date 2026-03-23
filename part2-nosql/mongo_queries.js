// ============================================================
// Part 2.2 — MongoDB Operations

// ─────────────────────────────────────────────────────────────
// OP1: insertMany() — insert all 3 documents from sample_documents.json

db.products.insertMany(
  [
    {
      _id: "prod_elec_001",
      category: "Electronics",
      name: "Samsung Galaxy Book4 Pro",
      brand: "Samsung",
      sku: "SAM-GB4P-16-512",
      price: 129999,
      currency: "INR",
      in_stock: true,
      stock_quantity: 34,
      images: [
        "https://cdn.store.com/products/sam-gb4p-main.jpg",
        "https://cdn.store.com/products/sam-gb4p-side.jpg"
      ],
      specs: {
        processor: "Intel Core Ultra 7 155H",
        ram_gb: 16,
        storage_gb: 512,
        storage_type: "NVMe SSD",
        display_inches: 16.0,
        display_resolution: "2880x1800",
        display_type: "AMOLED",
        battery_wh: 76,
        os: "Windows 11 Home",
        weight_kg: 1.56,
        ports: ["USB-C (Thunderbolt 4)", "USB-C 3.2", "HDMI 2.0", "MicroSD", "3.5mm Audio"],
        connectivity: { wifi: "Wi-Fi 6E", bluetooth: "5.3" },
        voltage: "19V DC / 65W",
        frequency_hz: 50
      },
      warranty: {
        duration_months: 12,
        type: "On-site",
        provider: "Samsung India",
        terms_url: "https://samsung.com/in/warranty"
      },
      certifications: ["BIS", "ISI Mark"],
      tags: ["laptop", "ultrabook", "amoled", "work-from-home"],
      ratings: { average: 4.5, count: 1283 },
      created_at: new Date("2024-03-10T09:00:00Z"),
      updated_at: new Date("2025-01-15T14:30:00Z")
    },
    {
      _id: "prod_cloth_001",
      category: "Clothing",
      name: "Levi's 511 Slim Fit Jeans",
      brand: "Levi's",
      sku: "LEV-511-IND-32-30",
      price: 3299,
      currency: "INR",
      in_stock: true,
      stock_quantity: 120,
      images: [
        "https://cdn.store.com/products/lev-511-front.jpg",
        "https://cdn.store.com/products/lev-511-back.jpg"
      ],
      specs: {
        fabric_composition: { cotton_percent: 99, elastane_percent: 1 },
        fit: "Slim",
        rise: "Mid-rise",
        closure: "Button fly",
        pockets: 5,
        wash_care: ["Machine wash cold", "Do not bleach", "Tumble dry low", "Warm iron"],
        sustainable: false,
        country_of_origin: "India"
      },
      variants: [
        { size: "30x30", color: "Indigo Blue", sku_variant: "LEV-511-IND-30-30", stock: 15 },
        { size: "32x30", color: "Indigo Blue", sku_variant: "LEV-511-IND-32-30", stock: 28 },
        { size: "32x32", color: "Indigo Blue", sku_variant: "LEV-511-IND-32-32", stock: 20 },
        { size: "34x32", color: "Dark Stone",  sku_variant: "LEV-511-DST-34-32", stock: 12 },
        { size: "36x32", color: "Dark Stone",  sku_variant: "LEV-511-DST-36-32", stock:  9 }
      ],
      gender: "Men",
      age_group: "Adult",
      tags: ["jeans", "slim-fit", "casual", "denim", "workwear"],
      ratings: { average: 4.3, count: 5620 },
      return_policy: {
        returnable: true,
        return_window_days: 30,
        conditions: ["Unworn", "Tags attached", "Original packaging"]
      },
      created_at: new Date("2023-08-01T10:00:00Z"),
      updated_at: new Date("2024-11-20T08:45:00Z")
    },
    {
      _id: "prod_groc_001",
      category: "Groceries",
      name: "Amul Gold Full Cream Milk",
      brand: "Amul",
      sku: "AML-MILK-GOLD-1L",
      price: 68,
      currency: "INR",
      in_stock: true,
      stock_quantity: 850,
      images: ["https://cdn.store.com/products/amul-gold-1l.jpg"],
      packaging: {
        type: "Tetra Pak",
        volume_ml: 1000,
        units_per_pack: 1,
        recyclable: true
      },
      dates: {
        manufactured_at: new Date("2024-12-20"),
        best_before:     new Date("2025-06-20"),
        expiry_date:     new Date("2025-06-20")
      },
      storage_instructions:
        "Store in a cool and dry place. Once opened, refrigerate and consume within 2 days.",
      nutritional_info: {
        serving_size_ml: 200,
        servings_per_pack: 5,
        per_serving: {
          calories_kcal: 130,
          total_fat_g: 7.4,
          saturated_fat_g: 4.6,
          trans_fat_g: 0,
          cholesterol_mg: 24,
          sodium_mg: 80,
          total_carbohydrate_g: 9.5,
          sugars_g: 9.5,
          protein_g: 6.8,
          calcium_percent_dv: 25
        }
      },
      allergens: ["Milk"],
      dietary_flags: {
        vegetarian: true,
        vegan: false,
        gluten_free: true,
        organic: false,
        halal: true
      },
      fssai_license: "10013022002253",
      country_of_origin: "India",
      tags: ["dairy", "milk", "full-cream", "amul", "daily-essentials"],
      ratings: { average: 4.7, count: 23180 },
      created_at: new Date("2024-12-20T06:00:00Z"),
      updated_at: new Date("2024-12-20T06:00:00Z")
    }
  ],
  { ordered: true }
);


// ─────────────────────────────────────────────────────────────
// OP2: find() — retrieve all Electronics products with price > 20000

db.products.find(
  {
    category: "Electronics",
    price:    { $gt: 20000 }
  },
  {
    _id:                       1,
    name:                      1,
    brand:                     1,
    price:                     1,
    "specs.processor":         1,
    "specs.ram_gb":            1,
    "specs.storage_gb":        1,
    "warranty.duration_months": 1,
    ratings:                   1
  }
).sort({ price: -1 });


// ─────────────────────────────────────────────────────────────
// OP3: find() — retrieve all Groceries expiring before 2025-01-01

db.products.find(
  {
    category:            "Groceries",
    "dates.expiry_date": { $lt: new Date("2025-01-01") }
  },
  {
    _id:                  1,
    name:                 1,
    brand:                1,
    price:                1,
    "dates.expiry_date":  1,
    "dates.best_before":  1,
    stock_quantity:       1
  }
).sort({ "dates.expiry_date": 1 });  // soonest-expiring first


// ─────────────────────────────────────────────────────────────
// OP4: updateOne() — add a "discount_percent" field to a specific product

db.products.updateOne(
  { _id: "prod_elec_001" },
  {
    $set: {
      discount_percent: 10,
      updated_at: new Date()
    }
  }
);



// ─────────────────────────────────────────────────────────────
// OP5: createIndex() — create an index on the category field and explain why


// Index 1 — single field: supports any query filtering on category
db.products.createIndex(
  { category: 1 },
  {
    name:       "idx_category",
    background: true   
  }
);

// Index 2 — compound: optimises OP2 (category + price range) specifically
db.products.createIndex(
  { category: 1, price: 1 },
  {
    name:       "idx_category_price",
    background: true
  }
);

// Index 3 — sparse on dates.expiry_date: only indexes Groceries-style
// documents that actually have this field, keeping the index small.
db.products.createIndex(
  { "dates.expiry_date": 1 },
  {
    name:   "idx_expiry_date",
    sparse: true
  }
);

// Confirm indexes:
// db.products.getIndexes();

// Explain plan for OP2 to verify IXSCAN is used:
// db.products.find({ category: "Electronics", price: { $gt: 20000 } }).explain("executionStats");


// WHY: The two find() queries above (OP2, OP3) both filter on
// `category` as the first predicate.  Without an index, MongoDB
// performs a full collection scan (COLLSCAN) for every such query —
// O(n) in the number of documents.  A single-field ascending index on
// `category` reduces that to an index scan (IXSCAN) — O(log n) for
// the lookup + sequential scan of only the matching category bucket.
//
// For a product catalogue with millions of SKUs across three
// categories, this is the highest-leverage single index to add.
//
// A compound index on { category: 1, price: 1 } (second line below)
// is an optional further optimisation: it lets MongoDB answer OP2's
// price range filter directly from the index without touching the
// documents at all (a "covered query"), which halves I/O