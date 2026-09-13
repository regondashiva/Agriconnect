# 📱 AgriConnect: Complete Backend & API Architecture Guide
## Consumer E-Commerce & Delivery Partner Logistics (Modules 5 & 6)

This specification serves as the comprehensive, production-grade implementation guide for the **Backend Engineering Team** and **Frontend Mobile Team (Flutter)**. It covers the full lifecycle of:
1. **Direct Farmer-to-Consumer Auto-Sync**: How listed produce immediately flows into the consumer marketplace.
2. **Consumer E-Commerce Flow**: Discovery, Cart, Saved Cards/Payment Methods, Addresses, Escrow Checkout, Real-Time Tracking.
3. **Delivery Partner Flow**: Onboarding, Shift/Duty Toggle, Trip Acceptance, Cargo Verification, Route Navigation, 6-Digit OTP Escrow Settlement, and Instant UPI Driver Payouts.

---

## 🌍 Global Configuration & Environments

| Parameter | Development | Production |
| :--- | :--- | :--- |
| **REST API Base URL** | `http://localhost:8000/api/v1` | `https://agriconnect-api-fiz5.onrender.com/api/v1` |
| **WebSocket Stream** | `ws://localhost:8000/ws/tracking` | `wss://agriconnect-api-fiz5.onrender.com/ws/tracking` |
| **Voice AI Engine** | `http://localhost:5000` | `https://agriconnect-voice-ai.onrender.com` |

### Security & Authentication
All endpoints marked **[JWT Protected]** require an HTTP Bearer Header:
```http
Authorization: Bearer <user_jwt_token>
```
The token payload must encode:
```json
{
  "user_id": "usr_99214a12",
  "role": "consumer", // "consumer" | "delivery_partner" | "farmer" | "fpo_admin"
  "phone": "+919876543210",
  "exp": 1789312000
}
```

---

## 🔄 Core Architecture: Direct Farmer Produce ➔ Consumer Catalog Sync

### Requirement
When a farmer adds or updates produce (e.g. *2 kg Organic Tomatoes* or *100 kg Jyoti Potatoes*):
1. The backend **must automatically and immediately publish** the item into the consumer-facing vegetables and fruits catalog.
2. The consumer catalog item maintains a live foreign-key relationship with the farmer's produce lot (`produce_id`), automatically locking stock upon consumer cart checkout.
3. Provenance metadata is preserved: Farmer Name, Cluster Village, Harvest Timestamp, Quality Grade, and Chemical-Free certifications are displayed to consumers.

### Automated PostgreSQL Trigger Architecture
```sql
-- Trigger Function: Auto-sync newly registered farmer produce into Consumer Catalog
CREATE OR REPLACE FUNCTION sync_farmer_produce_to_consumer_catalog()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO consumer_products (
        id,
        produce_id,
        farmer_id,
        farmer_name,
        farm_cluster_name,
        name,
        category,
        image_url,
        price_per_kg,
        available_stock_kg,
        min_order_quantity_kg,
        grade,
        is_organic,
        harvest_date,
        is_active,
        created_at
    )
    VALUES (
        'CPRD-' || substr(md5(random()::text), 1, 10),
        NEW.id,
        NEW.farmer_id,
        NEW.farmer_name,
        COALESCE(NEW.location, 'Local Cluster Hub'),
        NEW.crop_name,
        CASE 
            WHEN NEW.crop_name ILIKE ANY(ARRAY['%tomato%', '%potato%', '%onion%', '%chilli%', '%carrot%', '%cabbage%', '%brinjal%']) THEN 'Vegetables'
            WHEN NEW.crop_name ILIKE ANY(ARRAY['%mango%', '%banana%', '%papaya%', '%guava%', '%apple%']) THEN 'Fruits'
            ELSE 'Daily Staples'
        END,
        COALESCE(NEW.image_url, 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400'),
        ROUND((NEW.expected_price_per_kg * 1.15)::numeric, 2), -- 15% fair margin covering cold-chain aggregation & FPO
        NEW.quantity_kg,
        0.5, -- Minimum 500g order
        NEW.grade,
        TRUE,
        COALESCE(NEW.available_date, NOW()),
        TRUE,
        NOW()
    )
    ON CONFLICT (produce_id) DO UPDATE SET
        available_stock_kg = NEW.quantity_kg,
        price_per_kg = ROUND((NEW.expected_price_per_kg * 1.15)::numeric, 2),
        is_active = (NEW.quantity_kg > 0);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sync_produce_to_consumer
AFTER INSERT OR UPDATE ON produce_items
FOR EACH ROW
EXECUTE FUNCTION sync_farmer_produce_to_consumer_catalog();
```

---

## 🛒 Module 5: Consumer E-Commerce API Specification

### 1. Product Catalog & Categories

#### `GET /consumer/categories`
Returns produce categories for top chip filters.
* **Headers:** Public / Optional JWT
* **Response 200 OK:**
```json
{
  "status": "success",
  "data": [
    { "id": "all", "name": "All", "icon": "eco", "count": 24 },
    { "id": "vegetables", "name": "Vegetables", "icon": "grass", "count": 14 },
    { "id": "fruits", "name": "Fruits", "icon": "nutrition", "count": 6 },
    { "id": "staples", "name": "Daily Staples", "icon": "inventory_2", "count": 4 }
  ]
}
```

#### `GET /consumer/products`
Fetches available farm-fresh produce with filters and provenance.
* **Query Parameters:**
  * `category` (optional, string): e.g. `Vegetables`, `Fruits`
  * `search` (optional, string): Search by crop or variety
  * `min_price` / `max_price` (optional, number)
  * `sort` (optional): `freshness_desc` | `price_asc` | `price_desc`
* **Response 200 OK:**
```json
{
  "status": "success",
  "data": {
    "total": 1,
    "products": [
      {
        "id": "CPRD-88401",
        "produce_id": "PRD-1726154800",
        "name": "Farm Fresh Red Tomatoes",
        "category": "Vegetables",
        "variety": "Hybrid Red Standard",
        "price_per_kg": 28.00,
        "mrp_price_per_kg": 38.00,
        "available_stock_kg": 150.0,
        "grade": "Grade A",
        "farmer_name": "Shiva (Local Farmer)",
        "farm_cluster_name": "Chevella Agro Cluster, Telangana",
        "harvest_date": "2026-09-12T06:00:00Z",
        "is_organic": true,
        "image_url": "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400",
        "rating": 4.9,
        "reviews_count": 82
      }
    ]
  }
}
```

---

### 2. Cart & Basket Management [JWT Protected]

#### `GET /consumer/cart`
Returns the active shopping cart with live subtotal, fees, and stock alerts.
* **Response 200 OK:**
```json
{
  "status": "success",
  "data": {
    "cart_id": "crt_a9821d",
    "items": [
      {
        "item_id": "citm_102",
        "product_id": "CPRD-88401",
        "name": "Farm Fresh Red Tomatoes",
        "image_url": "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400",
        "price_per_kg": 28.00,
        "quantity_kg": 2.0,
        "item_total": 56.00,
        "in_stock": true
      }
    ],
    "item_count": 1,
    "total_weight_kg": 2.0,
    "subtotal": 56.00,
    "farm_handling_fee": 10.00,
    "green_delivery_fee": 25.00,
    "discount": 0.00,
    "grand_total": 91.00
  }
}
```

#### `POST /consumer/cart/add`
Adds or increments product quantity in cart with atomic stock validation.
* **Request Body:**
```json
{
  "product_id": "CPRD-88401",
  "quantity_kg": 2.0
}
```
* **Response 200 OK:**
```json
{
  "status": "success",
  "message": "2.0 kg of Farm Fresh Red Tomatoes added to cart",
  "data": { "cart_item_count": 1, "subtotal": 56.00 }
}
```
* **Error 400 Bad Request:**
```json
{
  "status": "error",
  "code": "INSUFFICIENT_STOCK",
  "message": "Requested 200.0 kg exceeds farmer stock of 150.0 kg"
}
```

#### `PUT /consumer/cart/items/:itemId`
Updates quantity for an existing cart item.
* **Request Body:**
```json
{
  "quantity_kg": 3.5
}
```

#### `DELETE /consumer/cart/items/:itemId`
Removes an item from cart.

#### `DELETE /consumer/cart/clear`
Empties the consumer's cart.

---

### 3. Payment Methods & Saved Cards [JWT Protected]

#### `GET /consumer/payment-methods`
Retrieves saved payment cards, UPI handles, and default options.
* **Response 200 OK:**
```json
{
  "status": "success",
  "data": {
    "saved_cards": [
      {
        "id": "crd_8910",
        "card_holder_name": "Shiva Kumar",
        "card_number_masked": "•••• •••• •••• 4242",
        "card_brand": "Visa",
        "expiry_month": "08",
        "expiry_year": "28",
        "is_default": true
      }
    ],
    "saved_upi": [
      {
        "id": "upi_001",
        "vpa": "shiva@okaxis",
        "app": "Google Pay",
        "is_default": true
      }
    ],
    "cash_on_delivery_enabled": true
  }
}
```

#### `POST /consumer/payment-methods/add-card`
Securely saves a tokenized card for fast 1-click checkout (PCI-DSS compliant).
* **Request Body:**
```json
{
  "card_holder_name": "Shiva Kumar",
  "card_number": "4111222233334242",
  "expiry_month": "08",
  "expiry_year": "28",
  "cvv": "123",
  "gateway_token": "tok_1Nxxxxxx",
  "set_as_default": true
}
```
* **Response 201 Created:**
```json
{
  "status": "success",
  "message": "Card saved securely",
  "data": {
    "id": "crd_8910",
    "card_brand": "Visa",
    "card_number_masked": "•••• •••• •••• 4242"
  }
}
```

#### `DELETE /consumer/payment-methods/:id`
Deletes a saved card or payment instrument.

---

### 4. Delivery Addresses [JWT Protected]

#### `GET /consumer/addresses`
Returns all saved addresses for the consumer.
* **Response 200 OK:**
```json
{
  "status": "success",
  "data": [
    {
      "id": "addr_101",
      "tag": "Home",
      "recipient_name": "Shiva Kumar",
      "recipient_phone": "+919876543210",
      "flat_plot": "Flat 402, Green Meadows",
      "street": "Gachibowli Main Road",
      "landmark": "Near Bio Diversity Park",
      "city": "Hyderabad",
      "state": "Telangana",
      "pincode": "500032",
      "latitude": 17.4399,
      "longitude": 78.3762,
      "is_default": true
    }
  ]
}
```

#### `POST /consumer/addresses`
Adds a new delivery address.

---

### 5. Checkout & Smart Escrow Order Creation [JWT Protected]

#### `POST /consumer/orders/create`
Atomically executes order placement:
1. Validates and deducts farmer produce stock.
2. Creates order record with `PENDING_PICKUP` status.
3. **Generates secret 6-digit Delivery OTP** stored in encrypted escrow vault.
4. Broadcasts trip assignment to nearby delivery partners.
5. Empties consumer's active cart.

* **Request Body:**
```json
{
  "address_id": "addr_101",
  "payment_method": "card", // "card" | "upi" | "cash_on_delivery"
  "payment_card_id": "crd_8910",
  "delivery_instructions": "Leave crate at front door if unavailable"
}
```

* **Response 201 Created:**
```json
{
  "status": "success",
  "message": "Order created successfully. Escrow locked.",
  "data": {
    "order_id": "AGR-9201",
    "tracking_number": "TRK-2026-HYD-092",
    "total_amount": 91.00,
    "payment_status": "ESCROW_HELD",
    "delivery_status": "SEARCHING_DELIVERY_PARTNER",
    "delivery_otp": "749210", // Consumer shows this only upon doorstep verification
    "estimated_delivery_time": "2026-09-12T11:30:00Z",
    "items_count": 1,
    "summary": "2.0 kg Farm Fresh Red Tomatoes"
  }
}
```

---

### 6. Order Tracking & Status [JWT Protected]

#### `GET /consumer/orders`
Returns list of consumer's past and active orders.

#### `GET /consumer/orders/:orderId`
Returns complete order summary, items, timeline, assigned driver, and delivery OTP.
* **Response 200 OK:**
```json
{
  "status": "success",
  "data": {
    "order_id": "AGR-9201",
    "status": "OUT_FOR_DELIVERY",
    "delivery_otp": "749210",
    "driver": {
      "name": "Ravi Teja",
      "phone": "+919123456780",
      "vehicle_number": "TS 09 EV 1024 (Electric Van)",
      "rating": 4.95,
      "current_lat": 17.4350,
      "current_lng": 78.3720
    },
    "timeline": [
      { "title": "Order Placed & Escrow Locked", "time": "09:00 AM", "is_done": true },
      { "title": "Harvest Aggregated at FPO Hub", "time": "09:45 AM", "is_done": true },
      { "title": "Cargo Quality Verified & Dispatched", "time": "10:15 AM", "is_done": true },
      { "title": "Out for Doorstep Delivery", "time": "10:35 AM", "is_done": true },
      { "title": "Delivered & Escrow Released", "time": "Pending OTP", "is_done": false }
    ],
    "items": [
      { "name": "Farm Fresh Red Tomatoes", "qty_kg": 2.0, "amount": 56.00 }
    ],
    "grand_total": 91.00
  }
}
```

---

## 🛵 Module 6: Delivery Partner Logistics API Specification

### 1. Driver Profile & Duty Toggle [JWT Protected]

#### `GET /delivery/profile`
Returns driver credentials, active vehicle, wallet balance, and statistics.
* **Response 200 OK:**
```json
{
  "status": "success",
  "data": {
    "driver_id": "drv_8819",
    "name": "Ravi Teja",
    "phone": "+919123456780",
    "vehicle_type": "ELECTRIC_CARGO_VAN",
    "vehicle_number": "TS 09 EV 1024",
    "is_online": true,
    "current_lat": 17.3850,
    "current_lng": 78.4867,
    "battery_soc_percent": 82,
    "today_earnings": 650.00,
    "wallet_balance": 1820.00,
    "rating": 4.95,
    "completed_trips_today": 8
  }
}
```

#### `POST /delivery/duty/toggle`
Switches driver online/offline status with current GPS coordinates.
* **Request Body:**
```json
{
  "is_online": true,
  "lat": 17.3850,
  "lng": 78.4867
}
```

#### `POST /delivery/location/ping`
Background continuous GPS telemetry ping sent every 10–15 seconds during active trips.
* **Request Body:**
```json
{
  "trip_id": "trp_7710",
  "lat": 17.4320,
  "lng": 78.3750,
  "speed_kmh": 28.5,
  "heading_deg": 180.0
}
```

---

### 2. Trip Discovery & Acceptance [JWT Protected]

#### `GET /delivery/trips/available`
Finds pending delivery trip offers within driver's service radius.
* **Query Parameters:** `lat=17.3850&lng=78.4867&radius_km=10`
* **Response 200 OK:**
```json
{
  "status": "success",
  "data": [
    {
      "trip_id": "trp_7710",
      "order_id": "AGR-9201",
      "total_earning": 65.00,
      "distance_km": 6.8,
      "estimated_duration_mins": 22,
      "pickup": {
        "hub_name": "Chevella FPO Aggregation Hub",
        "address": "Hub #4, Chevella, RR District",
        "lat": 17.3080,
        "lng": 78.1340
      },
      "dropoff": {
        "customer_name": "Shiva Kumar",
        "address": "Flat 402, Green Meadows, Gachibowli",
        "lat": 17.4399,
        "lng": 78.3762
      },
      "cargo_summary": "1 Sealed Vegetable Crate (2.0 kg Tomatoes)",
      "expires_in_seconds": 45
    }
  ]
}
```

#### `POST /delivery/trips/:tripId/accept`
Atomically assigns the trip to the driver via database row-level locking (`SELECT ... FOR UPDATE`), preventing race conditions.
* **Response 200 OK:**
```json
{
  "status": "success",
  "message": "Trip accepted successfully",
  "data": {
    "trip_id": "trp_7710",
    "status": "EN_ROUTE_PICKUP",
    "navigation_route": {
      "waypoints": [
        { "lat": 17.3850, "lng": 78.4867 },
        { "lat": 17.3080, "lng": 78.1340 }
      ]
    }
  }
}
```

---

### 3. Trip Progression & Stage Milestones [JWT Protected]

#### `PUT /delivery/trips/:tripId/step`
Updates the delivery milestone stage.
* **Request Body:**
```json
{
  "step": 1, // 0: En route pickup | 1: At FPO Hub | 2: En route dropoff | 3: At Customer Doorstep
  "current_lat": 17.3080,
  "current_lng": 78.1340
}
```
* **Response 200 OK:**
```json
{
  "status": "success",
  "data": { "trip_id": "trp_7710", "current_step": 1, "status": "AT_PICKUP_HUB" }
}
```

---

### 4. Hub Cargo Verification Checklist [JWT Protected]

#### `POST /delivery/trips/:tripId/verify-checklist`
Mandatory quality assurance step executed at the FPO Aggregation Hub before dispatching cargo.
* **Request Body:**
```json
{
  "is_crate_seal_intact": true,
  "is_weight_accurate": true,
  "scale_weight_kg": 2.05,
  "is_cold_chain_temp_ok": true,
  "is_damage_free": true,
  "cargo_photo_url": "https://storage.agriconnect.org/cargo/chk_9921.jpg"
}
```
* **Response 200 OK:**
```json
{
  "status": "success",
  "message": "Cargo quality verified. Ready for doorstep transit.",
  "data": { "trip_status": "OUT_FOR_DELIVERY" }
}
```

---

### 5. Doorstep Delivery & 6-Digit OTP Escrow Release (CRITICAL) [JWT Protected]

#### `POST /delivery/trips/:tripId/verify-otp`
The final, non-repudiable step of the supply chain.
1. The driver collects the 6-digit OTP displayed on the consumer's mobile app.
2. The backend cryptographically validates the OTP.
3. If valid:
   - Order marked `DELIVERED`.
   - **Escrow Smart Vault executes multi-party payout**:
     - Driver earns delivery payout (e.g. ₹65.00) instantly added to their wallet.
     - Farmer receives 100% produce payment into their verified Jan Dhan / Bank account.
     - FPO receives aggregation facilitation fee.
4. Auto-initiates UPI payout transfer to driver's bank.

* **Request Body:**
```json
{
  "otp": "749210",
  "delivery_notes": "Handed directly to customer. In good condition."
}
```

* **Response 200 OK (Success & Escrow Disbursed):**
```json
{
  "status": "success",
  "message": "OTP verified successfully. Order delivered and Escrow funds disbursed!",
  "data": {
    "trip_id": "trp_7710",
    "order_id": "AGR-9201",
    "payout_amount": 65.00,
    "driver_new_wallet_balance": 1885.00,
    "upi_transaction_ref": "UPI-2026-991240182",
    "delivered_at": "2026-09-12T11:15:30Z"
  }
}
```

* **Error 400 Bad Request (Invalid OTP):**
```json
{
  "status": "error",
  "code": "INVALID_OTP",
  "message": "The entered OTP is incorrect. Please ask customer for the 6-digit code shown in their app."
}
```

---

### 6. Driver Wallet & Payout Ledger [JWT Protected]

#### `GET /delivery/wallet`
Returns balance and earnings history.
* **Response 200 OK:**
```json
{
  "status": "success",
  "data": {
    "wallet_balance": 1885.00,
    "today_earnings": 715.00,
    "weekly_earnings": 4920.00,
    "settled_via_upi": true,
    "transactions": [
      {
        "id": "txn_5501",
        "type": "CREDIT",
        "amount": 65.00,
        "description": "Delivery Payout for Order #AGR-9201",
        "timestamp": "2026-09-12T11:15:30Z"
      }
    ]
  }
}
```

#### `POST /delivery/wallet/withdraw-upi`
Initiates an on-demand payout transfer to the driver's registered VPA.
* **Request Body:**
```json
{
  "amount": 1000.00,
  "vpa": "raviteja@okhdfcbank"
}
```

---

## 📦 Module 7: Consumer Orders History, Reordering & Invoicing API

*These APIs power the Consumer App's Orders History screen, allowing households to track past and ongoing farm-fresh vegetable purchases, download invoices, reorder favorites with one tap, and rate produce quality.*

### 1. Orders List & Filter [JWT Protected]

#### `GET /consumer/orders`
Retrieves the logged-in consumer's complete order history with status filters.
* **Query Parameters:**
  * `status` (optional): `all` | `active` | `delivered` | `cancelled`
  * `page` (optional, default: 1): Page number
  * `limit` (optional, default: 20): Orders per page
* **Response 200 OK:**
```json
{
  "status": "success",
  "data": {
    "total": 3,
    "active_count": 1,
    "delivered_count": 2,
    "orders": [
      {
        "order_id": "AGR-2048",
        "tracking_number": "TRK-2026-HYD-2048",
        "order_date": "2026-09-12T09:48:00Z",
        "status": "OUT_FOR_DELIVERY",
        "status_display": "Out for Delivery",
        "eta": "In 20 mins",
        "delivery_otp": "749210",
        "total_amount": 320.00,
        "payment_method": "UPI (Google Pay)",
        "payment_status": "ESCROW_HELD",
        "items_count": 3,
        "items_summary": [
          "Fresh Farm Tomatoes (2 kg)",
          "Organic Jyoti Potatoes (2 kg)",
          "Nashik Red Onions (1 kg)"
        ],
        "farm_cluster": "Chevella Agro Cluster, Telangana",
        "delivery_address": "Flat 402, Green Acres, Pune",
        "driver": {
          "name": "Mahesh Kumar",
          "phone": "+919123456780",
          "vehicle": "TS 09 EV 1024 (Electric Van)",
          "rating": 4.95
        }
      },
      {
        "order_id": "AGR-1892",
        "tracking_number": "TRK-2026-HYD-1892",
        "order_date": "2026-09-11T07:15:00Z",
        "status": "DELIVERED",
        "status_display": "Delivered",
        "delivered_at": "2026-09-11T08:35:10Z",
        "total_amount": 245.00,
        "payment_method": "UPI (PhonePe)",
        "payment_status": "SETTLED_JAN_DHAN",
        "items_count": 2,
        "items_summary": [
          "Organic Jyoti Potatoes (2.5 kg)",
          "Fresh Farm Tomatoes (2 kg)"
        ],
        "farm_cluster": "Ranga Reddy FPO Cluster Hub",
        "delivery_address": "Flat 402, Green Acres, Pune",
        "can_reorder": true,
        "invoice_available": true
      }
    ]
  }
}
```

---

### 2. Single Order Details & Traceability [JWT Protected]

#### `GET /consumer/orders/:orderId`
Returns complete order manifest, farm lot harvest verification, driver timeline, and settlement details.
* **Response 200 OK:**
```json
{
  "status": "success",
  "data": {
    "order_id": "AGR-2048",
    "status": "OUT_FOR_DELIVERY",
    "delivery_otp": "749210",
    "order_date": "2026-09-12T09:48:00Z",
    "estimated_delivery": "2026-09-12T10:45:00Z",
    "delivery_address": {
      "tag": "Home",
      "recipient_name": "Priya Sharma",
      "recipient_phone": "+919876543210",
      "address_line": "Flat 402, Green Acres, Pune"
    },
    "items": [
      {
        "product_id": "CPRD-88401",
        "name": "Fresh Farm Tomatoes",
        "quantity_kg": 2.0,
        "price_per_kg": 28.00,
        "total": 56.00,
        "farmer_name": "Shiva (Local Farmer)",
        "cluster": "Chevella Cluster",
        "harvest_date": "2026-09-12T06:00:00Z",
        "grade": "Grade A"
      }
    ],
    "bill_breakdown": {
      "item_total": 285.00,
      "fpo_aggregation_fee": 10.00,
      "green_delivery_fee": 25.00,
      "middleman_cut": 0.00,
      "grand_total": 320.00
    },
    "timeline": [
      { "stage": "ORDER_PLACED", "title": "Order Placed & Escrow Locked", "time": "09:48 AM", "done": true },
      { "stage": "HUB_PACKED", "title": "Crate Packed at FPO Hub", "time": "10:05 AM", "done": true },
      { "stage": "OUT_FOR_DELIVERY", "title": "Out for Doorstep Delivery", "time": "10:20 AM", "done": true },
      { "stage": "DELIVERED", "title": "Doorstep Handover & Settlement", "time": "Pending OTP", "done": false }
    ]
  }
}
```

---

### 3. One-Tap Reordering [JWT Protected]

#### `POST /consumer/orders/:orderId/reorder`
Automatically checks live farmer stock for items in the specified past order, validates availability, and loads them directly into the consumer's shopping cart for rapid checkout.
* **Response 200 OK:**
```json
{
  "status": "success",
  "message": "3 items added to your cart from Order #AGR-1892",
  "data": {
    "cart_id": "crt_a9821d",
    "added_items": [
      { "product_id": "CPRD-88401", "name": "Fresh Farm Tomatoes", "quantity_kg": 2.0 },
      { "product_id": "CPRD-88403", "name": "Organic Jyoti Potatoes", "quantity_kg": 2.5 }
    ],
    "cart_count": 2,
    "cart_subtotal": 245.00
  }
}
```

---

### 4. Itemized Invoice & Tax Receipt [JWT Protected]

#### `GET /consumer/orders/:orderId/invoice`
Fetches a verifiable tax-exempt agricultural invoice detailing farmer Jan Dhan direct payouts, FPO aggregation costs, and green delivery charges.
* **Response 200 OK:**
```json
{
  "status": "success",
  "data": {
    "invoice_number": "INV-2026-AGR-2048",
    "invoice_date": "2026-09-12",
    "order_id": "AGR-2048",
    "customer": {
      "name": "Priya Sharma",
      "address": "Flat 402, Green Acres, Pune",
      "phone": "+919876543210"
    },
    "items": [
      { "description": "Farm Fresh Red Tomatoes (Grade A)", "hsn_code": "0702", "qty_kg": 2.0, "rate": 28.00, "amount": 56.00 },
      { "description": "Organic Jyoti Potatoes (Grade A)", "hsn_code": "0701", "qty_kg": 2.0, "rate": 26.00, "amount": 52.00 }
    ],
    "subtotal": 108.00,
    "tax_gst_percent": 0.0, // Fresh unprocessed agricultural produce is 0% GST exempt
    "fpo_aggregation_fee": 10.00,
    "delivery_charge": 25.00,
    "grand_total": 143.00,
    "payment_method": "UPI (Google Pay)",
    "escrow_disbursement": {
      "farmer_payout": 108.00,
      "settlement_status": "DIRECT_JAN_DHAN_CREDIT",
      "transaction_ref": "NPCI-UPI-2026-0912-99120"
    }
  }
}
```

---

### 5. Freshness Quality Rating & Driver Review [JWT Protected]

#### `POST /consumer/orders/:orderId/rate`
Allows the consumer to submit ratings for produce freshness and delivery speed once the order is delivered.
* **Request Body:**
```json
{
  "produce_rating": 5, // 1 to 5 stars
  "delivery_rating": 5,
  "review_text": "Crate was sealed and vegetables were freshly harvested this morning. Zero chemical smell!",
  "tags": ["CRISP_FRESH", "TIMELY_DELIVERY", "NEAT_PACKAGING"]
}
```
* **Response 200 OK:**
```json
{
  "status": "success",
  "message": "Thank you! Your feedback helps local farmers improve their quality tier."
}
```

---

## 🗄️ Database Tables (PostgreSQL Schema)

```sql
-- 1. Consumer Products (populated dynamically by farmer produce trigger)
CREATE TABLE IF NOT EXISTS consumer_products (
    id VARCHAR(50) PRIMARY KEY,
    produce_id VARCHAR(50) REFERENCES produce_items(id) ON DELETE CASCADE,
    farmer_id VARCHAR(50) NOT NULL,
    farmer_name VARCHAR(100) NOT NULL,
    farm_cluster_name VARCHAR(150),
    name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    variety VARCHAR(100),
    image_url TEXT,
    price_per_kg NUMERIC(10,2) NOT NULL,
    available_stock_kg NUMERIC(10,2) NOT NULL DEFAULT 0,
    min_order_quantity_kg NUMERIC(10,2) NOT NULL DEFAULT 0.5,
    grade VARCHAR(20) DEFAULT 'Grade A',
    is_organic BOOLEAN DEFAULT TRUE,
    harvest_date TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Consumer Shopping Carts
CREATE TABLE IF NOT EXISTS consumer_carts (
    id VARCHAR(50) PRIMARY KEY,
    consumer_id VARCHAR(50) NOT NULL UNIQUE,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS consumer_cart_items (
    id VARCHAR(50) PRIMARY KEY,
    cart_id VARCHAR(50) REFERENCES consumer_carts(id) ON DELETE CASCADE,
    product_id VARCHAR(50) REFERENCES consumer_products(id),
    quantity_kg NUMERIC(10,2) NOT NULL CHECK (quantity_kg > 0),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(cart_id, product_id)
);

-- 3. Consumer Saved Payment Cards
CREATE TABLE IF NOT EXISTS consumer_payment_cards (
    id VARCHAR(50) PRIMARY KEY,
    consumer_id VARCHAR(50) NOT NULL,
    card_holder_name VARCHAR(100) NOT NULL,
    card_number_masked VARCHAR(20) NOT NULL,
    card_brand VARCHAR(30) NOT NULL,
    expiry_month VARCHAR(2) NOT NULL,
    expiry_year VARCHAR(2) NOT NULL,
    gateway_token VARCHAR(255) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Consumer Orders & Escrow Vault
CREATE TABLE IF NOT EXISTS consumer_orders (
    id VARCHAR(50) PRIMARY KEY,
    consumer_id VARCHAR(50) NOT NULL,
    address_id VARCHAR(50) NOT NULL,
    total_amount NUMERIC(10,2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL, -- 'card', 'upi', 'cash_on_delivery'
    payment_status VARCHAR(30) DEFAULT 'ESCROW_HELD', -- 'ESCROW_HELD', 'SETTLED', 'REFUNDED'
    delivery_status VARCHAR(40) DEFAULT 'PENDING_PICKUP', -- 'PENDING_PICKUP', 'ASSIGNED', 'OUT_FOR_DELIVERY', 'DELIVERED'
    delivery_otp VARCHAR(6) NOT NULL, -- Cryptographic Escrow Key
    assigned_driver_id VARCHAR(50),
    estimated_delivery TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    delivered_at TIMESTAMPTZ
);

-- 5. Delivery Partner Trips & Checklist Audit
CREATE TABLE IF NOT EXISTS delivery_trips (
    id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50) REFERENCES consumer_orders(id),
    driver_id VARCHAR(50) NOT NULL,
    status VARCHAR(40) DEFAULT 'EN_ROUTE_PICKUP',
    payout_amount NUMERIC(10,2) NOT NULL DEFAULT 65.00,
    distance_km NUMERIC(6,2),
    is_seal_intact BOOLEAN DEFAULT FALSE,
    is_weight_accurate BOOLEAN DEFAULT FALSE,
    is_damage_free BOOLEAN DEFAULT FALSE,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);
```

---

## ⚡ WebSocket Live Tracking Events (`/ws/tracking`)

Connect to the WebSocket server to stream driver movement and state changes in real time:
```javascript
// Example: Listening to live order tracking in mobile app
const socket = new WebSocket('wss://agriconnect-api-fiz5.onrender.com/ws/tracking?token=' + jwtToken);

socket.onmessage = (event) => {
  const data = JSON.parse(event.data);
  switch (data.type) {
    case 'DRIVER_LOCATION_UPDATE':
      // data: { trip_id, lat: 17.4350, lng: 78.3720, bearing: 180, speed: 28 }
      updateMapMarker(data.lat, data.lng, data.bearing);
      break;
    case 'ORDER_DELIVERED':
      // data: { order_id, delivered_at }
      showDeliverySuccessCelebration();
      break;
  }
};
```

---

## 🛡️ Error Codes & Standards

| HTTP Status | Error Code | Description | Recommended Action |
| :--- | :--- | :--- | :--- |
| **400** | `INSUFFICIENT_STOCK` | Requested quantity exceeds farmer's stock | Show max available stock in UI |
| **400** | `INVALID_OTP` | Provided delivery OTP does not match escrow | Prompt customer to check mobile app |
| **401** | `UNAUTHORIZED` | Expired or missing JWT token | Redirect to login screen |
| **404** | `TRIP_ALREADY_ACCEPTED`| Another driver claimed this trip | Remove offer card from list |
| **409** | `STOCK_LOCK_CONFLICT` | Simultaneous checkout on same lot | Retry transaction with latest stock |
| **500** | `ESCROW_DISBURSE_FAILED`| Banking gateway timeout | Auto-enqueued to retry queue |

---

*Authored for AgriConnect Mobile & Backend Teams.*
