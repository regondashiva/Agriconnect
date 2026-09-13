# 🌾 AgriConnect: Seed Data Architecture & Backend Specification

> **Target Audience**: Backend Engineers (FastAPI / Node.js / Django / Spring Boot), Database Administrators (PostgreSQL / MySQL / MongoDB), QA Engineers  
> **Platform**: AgriConnect — AI-Powered Agricultural Supply Coordination Platform  
> **Hackathon Reference**: Smart India Hackathon 2026 (Problem Statement: SIH26033)  
> **Accompanying Files**:
> - [`seed_data.json`](file:///c:/Users/shiva/OneDrive/Desktop/Agriconnect/seed_data.json) — Full ready-to-import JSON dataset for document databases or seed runners.
> - [`seed_data.sql`](file:///c:/Users/shiva/OneDrive/Desktop/Agriconnect/seed_data.sql) — Production-ready SQL DDL schema & relational INSERT statements.

---

## 📌 Executive Summary

To support the end-to-end AgriConnect mobile and web workflows, the backend database requires seed data structured around **4 primary user personas** participating in a connected agricultural value chain:

```
[ 3 Smallholder Farmers ] ──► [ FPO Hub Aggregation ] ──► [ Bulk Wholesale Buyer ]
  - Ramesh Reddy (100kg)        (Suresh Rao - Shabad)       (FreshBasket Mandi - 500kg)
  - Suresh Patil (150kg)                  │                             │
  - Ravi Patel   (250kg)                  ▼                             ▼
                                [ Direct Consumer ]      [ Jan Dhan Settlement ]
                                (Ananya - 2kg Tomato)    (100% Direct Bank Transfer)
```

---

## 🗂️ Complete Entity Inventory (11 Seed Domains)

| # | Entity Name | Database Table / Collection | Purpose in App | Key Records Seeded |
|---|---|---|---|---|
| **1** | **Users & Profiles** | `users` | Auth, role switcher, profile state | 4 core roles + 2 supplementary farmers |
| **2** | **FPO Clusters** | `fpo_hubs` | Regional aggregation center & coordinator hub | 2 FPO Hubs (Telangana & Maharashtra) |
| **3** | **Commodities Master** | `commodities` | Crop catalog, base pricing, shelf lives | 6 crops (Tomato, Potato, Onion, Wheat, Paddy, Chillies) |
| **4** | **Farmer Produce** | `produce_listings` | Active farm batches listed for sale | 9 listings across farmers (5 vegetable listings for Ramesh Reddy + aggregation crops) |
| **5** | **Buyer Requirements** | `buyer_requirements` | Procurement contracts posted by wholesale buyers | 3 requirements (500kg Tomato, 10-ton Wheat, 2-ton Potato) |
| **6** | **AI Smart Matches** | `supply_matches` & `match_contributors` | Multi-farmer batch aggregations fulfilling buyer demands | 1 flagship 3-farmer match (Order `#AGR-1024`) |
| **7** | **Orders & Timelines** | `orders` & `order_timeline` | Real-time transit, status timeline, delivery | Bulk Order `#AGR-1024` + Consumer Order `#AGR-2048` |
| **8** | **CVRP Logistics Routes** | `logistics_routes` & `route_stops` | Multi-stop pickup vehicle routing & waypoint polyline | 1 multi-stop route (`ROUTE-OPT-2026-902`) with 4 stops |
| **9** | **Bank Settlements** | `farmer_settlements` | Jan Dhan / direct UPI payments triggered at Mandi gate | 3 settlements (₹2,000, ₹3,000, ₹5,000) with 0% middleman cut |
| **10** | **Consumer Products** | `consumer_products` | Direct FPO farm-to-door grocery store | 8 retail products with freshness badges, ratings, discounts |
| **11** | **Mandi Forecasts** | `mandi_price_forecasts` | APMC market modal prices & 7-day AI forecast | 4 commodities with price trends & "Hold / Sell" advisory |
| **12** | **Notifications** | `notifications` | Role-targeted push alerts for mobile notifications tab | 6 pre-seeded notifications across all roles |

---

## 👥 1. Primary Seed User Personas

These credentials and profiles map directly to the mobile app's **Quick Role Switcher** and demo flows:

### 1.1 Farmer — Ramesh Reddy (Anchor Demo Farmer)
* **User ID**: `usr_farmer_001`
* **Phone Number**: `+91 9876543210` (Demo OTP: `123456`)
* **Role**: `farmer`
* **Village/Location**: Chevella Village, Ranga Reddy Dist, Telangana (`17.3075, 78.1362`)
* **Primary Crops**: Tomato, Potato, Onion, Chillies, Capsicum
* **FPO Assigned**: Ranga Reddy Organic Producers FPO (`fpo_001`)
* **Bank / Jan Dhan**: State Bank of India (A/C: `****4912`, IFSC: `SBIN0001234`, UPI: `ramesh.reddy@okaxis`)
* **Listings (5 Distinct Vegetables)**:
  1. `prod_tomato_001`: 100 kg Hybrid Roma Tomato @ ₹20/kg (Grade A, AI 89.4)
  2. `prod_potato_001`: 250 kg Kufri Jyoti Potato @ ₹18/kg (Grade A, AI 91.2)
  3. `prod_onion_001`: 300 kg Nashik Red Onion @ ₹24/kg (Grade A, AI 88.0)
  4. `prod_chilli_001`: 80 kg Guntur Teja Green Chillies @ ₹42/kg (Grade A, AI 90.5)
  5. `prod_capsicum_001`: 120 kg Indra Green Capsicum @ ₹35/kg (Grade A, AI 89.0)

### 1.2 FPO Coordinator — Suresh Rao
* **User ID**: `usr_fpo_001`
* **Phone Number**: `+91 9876543211` (Demo OTP: `123456`)
* **Role**: `fpo`
* **Business Name**: Ranga Reddy Farmers Producer Co-op
* **Hub Location**: Shabad Center, Hyderabad Rural, Telangana (`17.2000, 78.2500`)
* **Member Farmers**: 48 active farmers
* **Capacity**: 25.0 Tons cold & dry aggregation capacity

### 1.3 Bulk Wholesale Buyer — Vikram Mehta (FreshBasket Mandi)
* **User ID**: `usr_buyer_001`
* **Phone Number**: `+91 9876543212` (Demo OTP: `123456`)
* **Role**: `bulk_buyer`
* **Business Name**: FreshBasket Wholesale Mandi Pvt Ltd
* **GSTIN**: `36AABCF1234Z1ZX`
* **Delivery Hub**: Kothapet Wholesale Mandi, Hyderabad (`17.3688, 78.5398`)
* **Requirement**: 500 kg Grade A Tomatoes (Requirement ID: `req_tomato_001`)

### 1.4 Household Consumer — Ananya Sharma
* **User ID**: `usr_consumer_001`
* **Phone Number**: `+91 9876543213` (Demo OTP: `123456`)
* **Role**: `consumer`
* **Delivery Address**: Flat 402, Green Meadows, Madhapur, Hyderabad - 500081 (`17.4483, 78.3915`)
* **Order**: Order `#AGR-2048` (2kg Farm Tomatoes + 1kg Jyoti Potatoes)

### 1.5 Supplementary Contributing Farmers (For Lot Aggregation)
* **Suresh Patil** (`usr_farmer_002`): Shabad North, 150 kg Tomato contributor
* **Ravi Patel** (`usr_farmer_003`): Moinabad Cluster, 250 kg Tomato contributor

---

## 🔗 Key Relationships & Workflow Integrity

```
[buyer_requirements] (req_tomato_001: 500kg Tomato)
         ▲
         │ satisfies
[supply_matches] (match_001: 500kg aggregated, 94.2% match score)
         │
         ├──► [match_contributors]
         │       ├── Ramesh Reddy: 100 kg (₹2,000)
         │       ├── Suresh Patil: 150 kg (₹3,000)
         │       └── Ravi Patel:   250 kg (₹5,000)
         │
         ├──► [orders] (Order #AGR-1024, Bulk Coordination)
         │       ├── [order_timeline] (6 status stages)
         │       └── [farmer_settlements] (3 Jan Dhan payouts, ₹0 fees)
         │
         └──► [logistics_routes] (ROUTE-OPT-2026-902, 1.2 Ton Mini-Truck)
                 ├── Stop 1: Chevella (Pickup 100kg)
                 ├── Stop 2: Shabad (Pickup 150kg)
                 ├── Stop 3: Moinabad (Pickup 250kg)
                 └── Stop 4: Kothapet Mandi (Dropoff 500kg)
```

---

## 🥦 Real-World Vegetable & Grocery Photography Catalog

All vegetable items in `consumer_products` and `commodities` use **real, high-resolution photographs** (no placeholders or generic AI art). Backend endpoints (`GET /api/v1/consumer/products`, `GET /api/v1/farmer/produce`) should return these URLs under the `image_url` field:

| Item Name | Category | Real Image URL | Freshness & Grade |
|---|---|---|---|
| **Hybrid Farm Fresh Tomatoes** | Vegetables | `https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&auto=format&fit=crop&q=80` | Grade A • Harvested 3h ago |
| **Organic Jyoti Potatoes** | Vegetables | `https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&auto=format&fit=crop&q=80` | Grade A • Cleaned & Soil-Free |
| **Nashik Red Fresh Onions** | Vegetables | `https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=600&auto=format&fit=crop&q=80` | Grade A • Cured & Dry |
| **Fresh Green Palak (Spinach)** | Greens | `https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600&auto=format&fit=crop&q=80` | Grade A • Harvested at 5 AM Today |
| **Spicy Guntur Green Chillies** | Vegetables | `https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=600&auto=format&fit=crop&q=80` | Grade A • Hand-picked |
| **Premium Sona Masoori Rice** | Grains | `https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&auto=format&fit=crop&q=80` | Grade A • 1-Year Aged Grain |
| **Farm Fresh Green Peas (Matar)** | Vegetables | `https://images.unsplash.com/photo-1587735243615-c03f25aaff15?w=600&auto=format&fit=crop&q=80` | Grade A • Crisp & Sweet Pods |
| **Organic Ginger (Adrak)** | Herbs | `https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=600&auto=format&fit=crop&q=80` | Grade A • Aromatic & Unwashed |
| **Fresh Crunchy Orange Carrots** | Vegetables | `https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=600&auto=format&fit=crop&q=80` | Grade A • Harvested Today |
| **Farm Fresh White Cauliflower** | Vegetables | `https://images.unsplash.com/photo-1568584711075-3d021a7c3ca3?w=600&auto=format&fit=crop&q=80` | Grade A • Firm & Compact Head |
| **Green Bell Peppers (Capsicum)** | Vegetables | `https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=600&auto=format&fit=crop&q=80` | Grade A • Glossy & Crisp |
| **Country Fresh Garlic (Lahsun)** | Herbs | `https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?w=600&auto=format&fit=crop&q=80` | Grade A • Sun-cured & Dry |
| **Fresh Green Cabbage (Patta Gobi)** | Vegetables | `https://images.unsplash.com/photo-1594282486552-05b4d80fbb9f?w=600&auto=format&fit=crop&q=80` | Grade A • Crisp & Tightly Layered |
| **Tender Fresh Okra (Bhindi)** | Vegetables | `https://images.unsplash.com/photo-1425543103986-22abb7d7e8d2?w=600&auto=format&fit=crop&q=80` | Grade A • Harvested Today, 6 AM |
| **Crisp Salad Cucumber (Kheera)** | Vegetables | `https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?w=600&auto=format&fit=crop&q=80` | Grade A • Cool & Hydrated |
| **Glossy Purple Brinjal (Baingan)** | Vegetables | `https://images.unsplash.com/photo-1590165482129-1b8b27698780?w=600&auto=format&fit=crop&q=80` | Grade A • Freshly Picked |
| **Organic Red Beetroot (Chukandar)** | Vegetables | `https://images.unsplash.com/photo-1593105544559-ecb03bf76f82?w=600&auto=format&fit=crop&q=80` | Grade A • Rich Iron-rich Roots |
| **Juicy Yellow Farm Lemons (Nimbu)** | Fruits | `https://images.unsplash.com/photo-1590502593747-42a996133562?w=600&auto=format&fit=crop&q=80` | Grade A • Thin-skinned & Extra Juicy |
| **Fresh Aromatic Coriander (Kothmir)** | Greens | `https://images.unsplash.com/photo-1599940824399-b87987ceb72a?w=600&auto=format&fit=crop&q=80` | Grade A • Dew-fresh Bunches |
| **Fresh Mountain Mint (Pudina)** | Greens | `https://images.unsplash.com/photo-1628556270448-4d4e4148e1b1?w=600&auto=format&fit=crop&q=80` | Grade A • High Aroma & Cooling |
| **Naturally Sweet Yelakki Bananas** | Fruits | `https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=600&auto=format&fit=crop&q=80` | Grade A • Naturally Tree-Ripened |
| **Crisp Royal Apples (Seb)** | Fruits | `https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600&auto=format&fit=crop&q=80` | Grade A • Sweet, Juicy & Crunchy |
| **Ruby Red Fresh Pomegranates (Anar)** | Fruits | `https://images.unsplash.com/photo-1557800636-894a64c1696f?w=600&auto=format&fit=crop&q=80` | Grade A • Seed-Rich & Sweet |
| **Tender Green French Beans (Phasli)** | Vegetables | `https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=600&auto=format&fit=crop&q=80` | Grade A • Snap Fresh & Tender |
| **Farm Fresh Sweet Corn (Bhutta)** | Vegetables | `https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=600&auto=format&fit=crop&q=80` | Grade A • Milky Sweet Kernels |
| **Fresh Green Bottle Gourd (Lauki)** | Vegetables | `https://images.unsplash.com/photo-1597362925123-77861d3fbac7?w=600&auto=format&fit=crop&q=80` | Grade A • Tender & Light-skinned |
| **Fresh Button Mushrooms (Khumb)** | Vegetables | `https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&auto=format&fit=crop&q=80` | Grade A • Firm White Caps |
| **Fresh Fenugreek Leaves (Methi)** | Greens | `https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&auto=format&fit=crop&q=80` | Grade A • Fresh Morning Pluck |
| **Farm Golden Sweet Potatoes (Shakarkand)** | Vegetables | `https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=600&auto=format&fit=crop&q=80` | Grade A • Naturally Sweet & Cured |
| **Farm Fresh Golden Pumpkin (Kaddu)** | Vegetables | `https://images.unsplash.com/photo-1570586437263-ab629fccc818?w=600&auto=format&fit=crop&q=80` | Grade A • Rich Orange Flesh |
| **Fresh Banganapalli Sweet Mangoes** | Fruits | `https://images.unsplash.com/photo-1553279768-865429fa0078?w=600&auto=format&fit=crop&q=80` | Grade A • Tree Ripe & Sweet |
| **Farm Fresh Sweet Papaya (Red Lady)** | Fruits | `https://images.unsplash.com/photo-1517282009859-f000ec3b26fe?w=600&auto=format&fit=crop&q=80` | Grade A • Naturally Ripened |
| **Allahabad Sweet White Guavas** | Fruits | `https://images.unsplash.com/photo-1536511135898-3f5f3e4e9f3b?w=600&auto=format&fit=crop&q=80` | Grade A • Crisp & Sweet White Flesh |
| **Nagpur Sweet Juicy Oranges (Santra)** | Fruits | `https://images.unsplash.com/photo-1582979512210-99b6a53386f9?w=600&auto=format&fit=crop&q=80` | Grade A • Juicy & High Vitamin C |
| **Fresh Crisp Black Seedless Grapes** | Fruits | `https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=600&auto=format&fit=crop&q=80` | Grade A • Plump & Sugar Sweet |
| **Thompson Fresh Green Grapes** | Fruits | `https://images.unsplash.com/photo-1596363505729-4190a9506133?w=600&auto=format&fit=crop&q=80` | Grade A • Crisp & Tangy-Sweet |
| **Sweet Red Kiran Watermelon** | Fruits | `https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=600&auto=format&fit=crop&q=80` | Grade A • Deep Red & Hydrating |
| **Sweet Honey Muskmelon (Kharbooja)** | Fruits | `https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=600&auto=format&fit=crop&q=80` | Grade A • Aromatic & Golden Center |
| **Sweet Brown Sapota (Chikoo)** | Fruits | `https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?w=600&auto=format&fit=crop&q=80` | Grade A • Caramel Sweet & Soft |
| **Fresh Sweet Queen Pineapple** | Fruits | `https://images.unsplash.com/photo-1550258987-190a2d41a8ba?w=600&auto=format&fit=crop&q=80` | Grade A • Fragrant Golden Core |
| **Fresh Tangy Gongura (Sorrel Leaves)** | Greens | `https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600&auto=format&fit=crop&q=80` | Grade A • Harvested 4 AM Today |
| **Fresh Red Amaranth Leaves (Thotakura)** | Greens | `https://images.unsplash.com/photo-1524179091875-bf99a9a6fa57?w=600&auto=format&fit=crop&q=80` | Grade A • Rich Iron & Mineral Packed |
| **Aromatic Fresh Curry Leaves (Kadi Patta)** | Greens | `https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=600&auto=format&fit=crop&q=80` | Grade A • Crisp Dark Green Aroma |
| **Tender Moringa Leaves (Munagaku)** | Greens | `https://images.unsplash.com/photo-1515543237350-b3eea1ec8082?w=600&auto=format&fit=crop&q=80` | Grade A • Superfood Morning Harvest |
| **Tender Malabar Spinach (Bachali Kura)** | Greens | `https://images.unsplash.com/photo-1628771065518-0d82f1938462?w=600&auto=format&fit=crop&q=80` | Grade A • Plump Succulent Leaves |
| **Crisp Farm Spring Onion Greens (Hari Pyaz)** | Greens | `https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=600&auto=format&fit=crop&q=80` | Grade A • Crisp Green Stalks |
| **Fresh Fragrant Dill Leaves (Shepu / Suva)** | Greens | `https://images.unsplash.com/photo-1509358271058-acd22cc93898?w=600&auto=format&fit=crop&q=80` | Grade A • Feathery Fragrant Leaves |
| **Crunchy Green Lettuce & Salad Leaves** | Greens | `https://images.unsplash.com/photo-1556801712-76c8eb07bbc9?w=600&auto=format&fit=crop&q=80` | Grade A • Clean Hydroponic Pluck |
| **Winter Fresh Mustard Greens (Sarson)** | Greens | `https://images.unsplash.com/photo-1518843875459-f738682238a6?w=600&auto=format&fit=crop&q=80` | Grade A • Peppery Tender Green Leaves |

### 🏷️ Verified Consumer Promotional Offer Banners

| Banner Offer | Tag / Code | Verified Image URL | Value Proposition |
|---|---|---|---|
| **50% OFF First Order** | `HOT DEAL` • `HARVEST50` | `https://images.unsplash.com/photo-1542838132-92c53300491e?w=600&auto=format&fit=crop&q=80` | Farm-fresh vegetables direct from rural FPO clusters |
| **100% Fair Pay to Farmers** | `COMMUNITY` • `DIRECTFARM` | `https://images.unsplash.com/photo-1595974482597-4b8da8879bc5?w=600&auto=format&fit=crop&q=80` | Zero middlemen markup • Harvested fresh within 12 hours |
| **Fresh Market Daily Deals** | `DAILY DEALS` • `VEGMKT20` | `https://images.unsplash.com/photo-1610348725531-843dff563e2c?w=600&auto=format&fit=crop&q=80` | Flat ₹20/kg on organic tomatoes, onions & potatoes |
| **Greens & Herbs Festival** | `ORGANIC GREENS` • `GREENS15` | `https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600&auto=format&fit=crop&q=80` | Crisp Spinach, Methi, Mint & Fresh Coriander at flat ₹15 |
| **Certified Organic Produce** | `100% ORGANIC` • `MIDPAGE` | `https://images.unsplash.com/photo-1506802913710-40e2e66339c9?w=600&auto=format&fit=crop&q=80` | Chevella & Moinabad clusters • Zero chemical pesticides |

---

## 🧪 How the Backend Team Can Test & Verify

### 1. Verification with REST API Endpoints:
* `POST /api/v1/auth/send-otp` with `{"phone_number": "+919876543210", "role": "farmer", "is_login": true}`
* `POST /api/v1/auth/verify-otp` with `{"otp": "123456"}` ➔ Returns `usr_farmer_001` and JWT
* `GET /api/v1/farmer/produce` ➔ Returns Ramesh Reddy's 100kg Tomato listing
* `GET /api/v1/buyer/requirements` ➔ Returns 500kg Tomato demand
* `GET /api/v1/matching/find?crop=Tomato&quantity_kg=500&lat=17.3688&lng=78.5398` ➔ Returns multi-farmer aggregated match
* `GET /api/v1/consumer/products` ➔ Returns 12 farm-to-fork grocery items with real photographic image URLs
* `GET /api/v1/orders/AGR-1024` ➔ Returns complete order timeline and settlement receipts
