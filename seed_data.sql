-- =============================================================================
-- AgriConnect (SIH 2026) — Production Database Seed Script
-- Platform: PostgreSQL / Supabase / MySQL (Standard ANSI SQL)
-- Version: 1.0.0
-- Generated: 2026-09-07
-- Description: Complete schema DDL and relational seed data for backend API.
-- =============================================================================

-- Clean existing tables (drop in reverse FK order)
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS route_stops CASCADE;
DROP TABLE IF EXISTS logistics_routes CASCADE;
DROP TABLE IF EXISTS farmer_settlements CASCADE;
DROP TABLE IF EXISTS order_timeline CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS match_contributors CASCADE;
DROP TABLE IF EXISTS supply_matches CASCADE;
DROP TABLE IF EXISTS buyer_requirements CASCADE;
DROP TABLE IF EXISTS produce_listings CASCADE;
DROP TABLE IF EXISTS consumer_products CASCADE;
DROP TABLE IF EXISTS mandi_price_forecasts CASCADE;
DROP TABLE IF EXISTS commodities CASCADE;
DROP TABLE IF EXISTS fpo_hubs CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- -----------------------------------------------------------------------------
-- 1. USERS & PROFILES
-- -----------------------------------------------------------------------------
CREATE TABLE users (
    id VARCHAR(64) PRIMARY KEY,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    role VARCHAR(32) NOT NULL CHECK (role IN ('farmer', 'fpo', 'bulk_buyer', 'consumer')),
    full_name VARCHAR(128) NOT NULL,
    business_name VARCHAR(128),
    location VARCHAR(255) NOT NULL,
    latitude DECIMAL(10, 6),
    longitude DECIMAL(10, 6),
    preferred_language VARCHAR(64) DEFAULT 'Telugu / English',
    fpo_cluster_assigned VARCHAR(128),
    verified_id VARCHAR(64),
    is_verified BOOLEAN DEFAULT TRUE,
    bank_name VARCHAR(128),
    account_number_masked VARCHAR(32),
    ifsc_code VARCHAR(32),
    upi_id VARCHAR(64),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (id, phone_number, role, full_name, business_name, location, latitude, longitude, preferred_language, fpo_cluster_assigned, verified_id, is_verified, bank_name, account_number_masked, ifsc_code, upi_id) VALUES
('usr_farmer_001', '+919876543210', 'farmer', 'Ramesh Reddy', NULL, 'Chevella Village, Ranga Reddy Dist, Telangana', 17.3075, 78.1362, 'Telugu / English', 'Ranga Reddy Organic Producers FPO', 'SIH-AP-FARMER-2026', TRUE, 'State Bank of India (Jan Dhan)', 'XXXX-XXXX-4912', 'SBIN0001234', 'ramesh.reddy@okaxis'),
('usr_farmer_002', '+919876543214', 'farmer', 'Suresh Patil', NULL, 'Shabad North Cluster, Ranga Reddy Dist, Telangana', 17.2150, 78.2380, 'Telugu / English', 'Ranga Reddy Organic Producers FPO', 'SIH-AP-FARMER-2027', TRUE, 'Andhra Pragathi Grameena Bank', 'XXXX-XXXX-8821', 'APGB0002194', 'sureshpatil@ybl'),
('usr_farmer_003', '+919876543215', 'farmer', 'Ravi Patel', NULL, 'Moinabad Cluster, Ranga Reddy Dist, Telangana', 17.3200, 78.2800, 'Telugu / Hindi', 'Ranga Reddy Organic Producers FPO', 'SIH-AP-FARMER-2028', TRUE, 'Telangana Grameena Bank', 'XXXX-XXXX-1934', 'TGBB0001004', 'ravipatel@okhdfcbank'),
('usr_fpo_001', '+919876543211', 'fpo', 'Suresh Rao', 'Ranga Reddy Farmers Producer Co-op', 'Shabad Center, Hyderabad Rural, Telangana', 17.2000, 78.2500, 'Telugu / English', 'Ranga Reddy Organic Producers FPO', 'FPO-TS-RR-2026-089', TRUE, 'HDFC Bank (Current A/C)', 'XXXX-XXXX-9900', 'HDFC0000450', 'rrfpo@hdfcbank'),
('usr_buyer_001', '+919876543212', 'bulk_buyer', 'Vikram Mehta', 'FreshBasket Wholesale Mandi Pvt Ltd', 'Kothapet Wholesale Mandi, Hyderabad, Telangana', 17.3688, 78.5398, 'English / Hindi', NULL, '36AABCF1234Z1ZX', TRUE, 'ICICI Bank (Corporate A/C)', 'XXXX-XXXX-4001', 'ICIC0000041', 'freshbasket@icici'),
('usr_consumer_001', '+919876543213', 'consumer', 'Ananya Sharma', NULL, 'Flat 402, Green Meadows, Madhapur, Hyderabad - 500081', 17.4483, 78.3915, 'English', NULL, 'KYC-CONSUMER-2026-44', TRUE, 'HDFC Bank', 'XXXX-XXXX-6102', 'HDFC0001202', 'ananya.sharma@okaxis');

-- -----------------------------------------------------------------------------
-- 2. FPO HUBS
-- -----------------------------------------------------------------------------
CREATE TABLE fpo_hubs (
    id VARCHAR(64) PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    registration_id VARCHAR(64) NOT NULL UNIQUE,
    coordinator_user_id VARCHAR(64) REFERENCES users(id),
    location VARCHAR(255) NOT NULL,
    latitude DECIMAL(10, 6) NOT NULL,
    longitude DECIMAL(10, 6) NOT NULL,
    member_farmers_count INT DEFAULT 0,
    aggregation_capacity_ton DECIMAL(8, 2) DEFAULT 0.0,
    cold_storage_capacity_ton DECIMAL(8, 2) DEFAULT 0.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO fpo_hubs (id, name, registration_id, coordinator_user_id, location, latitude, longitude, member_farmers_count, aggregation_capacity_ton, cold_storage_capacity_ton) VALUES
('fpo_001', 'Ranga Reddy Organic Producers FPO', 'FPO-TS-RR-2026-089', 'usr_fpo_001', 'Shabad Center, Hyderabad Rural, Telangana', 17.2000, 78.2500, 48, 25.0, 8.0),
('fpo_002', 'Sahyadri Farmers Producer Co-op', 'FPO-MH-PUN-2026-012', 'usr_fpo_001', 'Shirur Center, Pune Rural, Maharashtra', 18.8268, 74.3788, 82, 50.0, 15.0);

-- -----------------------------------------------------------------------------
-- 3. COMMODITIES / CROPS MASTER
-- -----------------------------------------------------------------------------
CREATE TABLE commodities (
    id VARCHAR(64) PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    category VARCHAR(64) NOT NULL,
    standard_unit VARCHAR(16) DEFAULT 'kg',
    shelf_life_days INT DEFAULT 7,
    msp_benchmark_inr_per_kg DECIMAL(8, 2) DEFAULT 0.0,
    icon_emoji VARCHAR(8),
    image_url VARCHAR(512)
);

INSERT INTO commodities (id, name, category, standard_unit, shelf_life_days, msp_benchmark_inr_per_kg, icon_emoji, image_url) VALUES
('crop_tomato', 'Tomato', 'Vegetables', 'kg', 10, 18.50, '🍅', 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&auto=format&fit=crop&q=80'),
('crop_potato', 'Potato', 'Vegetables', 'kg', 35, 20.00, '🥔', 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&auto=format&fit=crop&q=80'),
('crop_onion', 'Onion', 'Vegetables', 'kg', 30, 24.00, '🧅', 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=600&auto=format&fit=crop&q=80'),
('crop_wheat', 'Wheat', 'Grains', 'kg', 180, 24.50, '🌾', 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=600&auto=format&fit=crop&q=80'),
('crop_paddy', 'Paddy / Rice', 'Grains', 'kg', 240, 23.20, '🍚', 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&auto=format&fit=crop&q=80'),
('crop_chillies', 'Green Chillies', 'Vegetables', 'kg', 14, 38.00, '🌶️', 'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=600&auto=format&fit=crop&q=80'),
('crop_mango', 'Banganapalli Sweet Mangoes', 'Fruits', 'kg', 7, 85.00, '🥭', 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600&auto=format&fit=crop&q=80'),
('crop_papaya', 'Red Lady Sweet Papaya', 'Fruits', 'kg', 6, 25.00, '🍈', 'https://images.unsplash.com/photo-1517282009859-f000ec3b26fe?w=600&auto=format&fit=crop&q=80'),
('crop_guava', 'Allahabad Safeda Guavas', 'Fruits', 'kg', 8, 30.00, '🍐', 'https://images.unsplash.com/photo-1536511135898-3f5f3e4e9f3b?w=600&auto=format&fit=crop&q=80'),
('crop_orange', 'Nagpur Juicy Oranges', 'Fruits', 'kg', 15, 45.00, '🍊', 'https://images.unsplash.com/photo-1582979512210-99b6a53386f9?w=600&auto=format&fit=crop&q=80'),
('crop_grapes', 'Crisp Seedless Grapes', 'Fruits', 'kg', 10, 55.00, '🍇', 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=600&auto=format&fit=crop&q=80'),
('crop_watermelon', 'Kiran Sweet Watermelon', 'Fruits', 'kg', 14, 18.00, '🍉', 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=600&auto=format&fit=crop&q=80'),
('crop_gongura', 'Fresh Tangy Gongura (Sorrel Leaves)', 'Greens', 'kg', 3, 20.00, '🌿', 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600&auto=format&fit=crop&q=80'),
('crop_amaranth', 'Red Amaranth (Thotakura)', 'Greens', 'kg', 3, 18.00, '🥬', 'https://images.unsplash.com/photo-1524179091875-bf99a9a6fa57?w=600&auto=format&fit=crop&q=80'),
('crop_curry_leaves', 'Fresh Aromatic Curry Leaves', 'Greens', 'kg', 7, 25.00, '🍃', 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=600&auto=format&fit=crop&q=80'),
('crop_moringa_leaves', 'Tender Moringa Drumstick Leaves', 'Greens', 'kg', 4, 30.00, '🌿', 'https://images.unsplash.com/photo-1515543237350-b3eea1ec8082?w=600&auto=format&fit=crop&q=80');

-- -----------------------------------------------------------------------------
-- 4. FARMER PRODUCE LISTINGS (SUPPLY)
-- -----------------------------------------------------------------------------
CREATE TABLE produce_listings (
    id VARCHAR(64) PRIMARY KEY,
    farmer_id VARCHAR(64) REFERENCES users(id),
    crop_name VARCHAR(64) NOT NULL,
    variety VARCHAR(64) DEFAULT 'Standard',
    total_quantity_kg DECIMAL(10, 2) NOT NULL,
    available_quantity_kg DECIMAL(10, 2) NOT NULL,
    expected_price_per_kg DECIMAL(8, 2) NOT NULL,
    quality_grade VARCHAR(16) DEFAULT 'gradeA',
    quality_score DECIMAL(5, 2) DEFAULT 85.0,
    confidence_score DECIMAL(5, 2) DEFAULT 90.0,
    risk_level VARCHAR(16) DEFAULT 'LOW',
    photo_count INT DEFAULT 0,
    harvest_date TIMESTAMP WITH TIME ZONE NOT NULL,
    pickup_address VARCHAR(255) NOT NULL,
    pickup_latitude DECIMAL(10, 6) NOT NULL,
    pickup_longitude DECIMAL(10, 6) NOT NULL,
    status VARCHAR(32) DEFAULT 'Listed',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO produce_listings (id, farmer_id, crop_name, variety, total_quantity_kg, available_quantity_kg, expected_price_per_kg, quality_grade, quality_score, confidence_score, risk_level, photo_count, harvest_date, pickup_address, pickup_latitude, pickup_longitude, status) VALUES
('prod_tomato_001', 'usr_farmer_001', 'Tomato', 'Hybrid Roma', 100.0, 100.0, 20.0, 'gradeA', 89.4, 93.8, 'LOW', 4, '2026-09-08 06:00:00+00', 'Chevella Village, Ranga Reddy Dist, Telangana', 17.3075, 78.1362, 'Listed'),
('prod_potato_001', 'usr_farmer_001', 'Potato', 'Kufri Jyoti', 250.0, 250.0, 18.0, 'gradeA', 91.2, 94.5, 'LOW', 4, '2026-09-07 06:00:00+00', 'Chevella Village, Ranga Reddy Dist, Telangana', 17.3075, 78.1362, 'Listed'),
('prod_onion_001', 'usr_farmer_001', 'Onion', 'Nashik Red', 300.0, 300.0, 24.0, 'gradeA', 88.0, 92.0, 'LOW', 3, '2026-09-06 07:00:00+00', 'Chevella Village, Ranga Reddy Dist, Telangana', 17.3075, 78.1362, 'Listed'),
('prod_chilli_001', 'usr_farmer_001', 'Green Chillies', 'Guntur Teja', 80.0, 80.0, 42.0, 'gradeA', 90.5, 93.0, 'LOW', 4, '2026-09-08 05:30:00+00', 'Chevella Village, Ranga Reddy Dist, Telangana', 17.3075, 78.1362, 'Listed'),
('prod_capsicum_001', 'usr_farmer_001', 'Capsicum', 'Indra Green', 120.0, 120.0, 35.0, 'gradeA', 89.0, 91.5, 'LOW', 5, '2026-09-08 06:00:00+00', 'Chevella Village, Ranga Reddy Dist, Telangana', 17.3075, 78.1362, 'Listed'),
('prod_tomato_002', 'usr_farmer_002', 'Tomato', 'Hybrid Roma', 150.0, 150.0, 20.0, 'gradeA', 87.2, 90.5, 'LOW', 3, '2026-09-08 06:30:00+00', 'Shabad North Cluster, Ranga Reddy Dist, Telangana', 17.2150, 78.2380, 'Listed'),
('prod_tomato_003', 'usr_farmer_003', 'Tomato', 'Hybrid Roma', 250.0, 250.0, 20.0, 'gradeA', 86.8, 89.9, 'LOW', 5, '2026-09-08 07:00:00+00', 'Moinabad Cluster, Ranga Reddy Dist, Telangana', 17.3200, 78.2800, 'Listed'),
('prod_wheat_001', 'usr_farmer_002', 'Wheat', 'Sharbati / MP Organic', 15000.0, 15000.0, 26.0, 'gradeA', 88.5, 91.0, 'LOW', 6, '2026-09-10 00:00:00+00', 'Shabad North Cluster, Telangana', 17.2150, 78.2380, 'Listed'),
('prod_paddy_001', 'usr_farmer_003', 'Paddy / Rice', 'Sona Masoori', 2000.0, 2000.0, 25.0, 'gradeA', 91.0, 94.0, 'LOW', 3, '2026-09-15 00:00:00+00', 'Moinabad Cluster, Telangana', 17.3200, 78.2800, 'Listed');

-- -----------------------------------------------------------------------------
-- 5. BUYER BULK DEMAND REQUIREMENTS
-- -----------------------------------------------------------------------------
CREATE TABLE buyer_requirements (
    id VARCHAR(64) PRIMARY KEY,
    buyer_id VARCHAR(64) REFERENCES users(id),
    crop_name VARCHAR(64) NOT NULL,
    variety VARCHAR(64) DEFAULT 'Standard',
    required_quantity_kg DECIMAL(10, 2) NOT NULL,
    quality_grade VARCHAR(16) DEFAULT 'gradeA',
    target_price_min DECIMAL(8, 2) DEFAULT 0.0,
    target_price_max DECIMAL(8, 2) NOT NULL,
    required_by_date TIMESTAMP WITH TIME ZONE NOT NULL,
    delivery_address VARCHAR(255) NOT NULL,
    delivery_latitude DECIMAL(10, 6) NOT NULL,
    delivery_longitude DECIMAL(10, 6) NOT NULL,
    status VARCHAR(32) DEFAULT 'Matching',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO buyer_requirements (id, buyer_id, crop_name, variety, required_quantity_kg, quality_grade, target_price_min, target_price_max, required_by_date, delivery_address, delivery_latitude, delivery_longitude, status) VALUES
('req_tomato_001', 'usr_buyer_001', 'Tomato', 'Hybrid Roma', 500.0, 'gradeA', 19.00, 22.00, '2026-09-09 18:00:00+00', 'Kothapet Wholesale Mandi, Hyderabad, Telangana', 17.3688, 78.5398, 'Matching'),
('req_wheat_001', 'usr_buyer_001', 'Wheat', 'Sharbati / MP Organic', 10000.0, 'gradeA', 25.00, 28.50, '2026-09-15 00:00:00+00', 'Kothapet Wholesale Mandi, Hyderabad, Telangana', 17.3688, 78.5398, 'Matching'),
('req_potato_001', 'usr_buyer_001', 'Potato', 'Jyoti', 2000.0, 'gradeA', 20.00, 24.00, '2026-09-12 12:00:00+00', 'Kothapet Wholesale Mandi, Hyderabad, Telangana', 17.3688, 78.5398, 'Open');

-- -----------------------------------------------------------------------------
-- 6. AI SMART MATCHES & MULTI-FARMER CONTRIBUTORS
-- -----------------------------------------------------------------------------
CREATE TABLE supply_matches (
    id VARCHAR(64) PRIMARY KEY,
    requirement_id VARCHAR(64) REFERENCES buyer_requirements(id),
    crop_name VARCHAR(64) NOT NULL,
    required_quantity_kg DECIMAL(10, 2) NOT NULL,
    matched_quantity_kg DECIMAL(10, 2) NOT NULL,
    match_score_percent DECIMAL(5, 2) NOT NULL,
    quality_score DECIMAL(5, 2) NOT NULL,
    confidence_score DECIMAL(5, 2) NOT NULL,
    is_fully_fulfilled BOOLEAN DEFAULT TRUE,
    total_estimated_value DECIMAL(12, 2) NOT NULL,
    aggregation_hub_name VARCHAR(128),
    total_distance_km DECIMAL(8, 2) DEFAULT 0.0,
    estimated_travel_time VARCHAR(64),
    vehicle_capacity VARCHAR(64) DEFAULT '1.2 Ton Mini-Truck',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO supply_matches (id, requirement_id, crop_name, required_quantity_kg, matched_quantity_kg, match_score_percent, quality_score, confidence_score, is_fully_fulfilled, total_estimated_value, aggregation_hub_name, total_distance_km, estimated_travel_time, vehicle_capacity) VALUES
('match_001', 'req_tomato_001', 'Tomato', 500.0, 500.0, 94.20, 88.50, 91.00, TRUE, 10000.00, 'Ranga Reddy Organic Producers FPO (Shabad)', 42.60, '1 hr 45 min', '1.2 Ton Mini-Truck');

CREATE TABLE match_contributors (
    id SERIAL PRIMARY KEY,
    match_id VARCHAR(64) REFERENCES supply_matches(id),
    farmer_id VARCHAR(64) REFERENCES users(id),
    produce_id VARCHAR(64) REFERENCES produce_listings(id),
    quantity_kg DECIMAL(10, 2) NOT NULL,
    payout_amount DECIMAL(10, 2) NOT NULL,
    pickup_location VARCHAR(255) NOT NULL,
    distance_to_hub_km DECIMAL(6, 2) DEFAULT 0.0
);

INSERT INTO match_contributors (match_id, farmer_id, produce_id, quantity_kg, payout_amount, pickup_location, distance_to_hub_km) VALUES
('match_001', 'usr_farmer_001', 'prod_tomato_001', 100.0, 2000.00, 'Chevella Village, Ranga Reddy Dist', 14.2),
('match_001', 'usr_farmer_002', 'prod_tomato_002', 150.0, 3000.00, 'Shabad North Cluster', 4.5),
('match_001', 'usr_farmer_003', 'prod_tomato_003', 250.0, 5000.00, 'Moinabad Cluster', 11.8);

-- -----------------------------------------------------------------------------
-- 7. ORDERS & WORKFLOW TIMELINES
-- -----------------------------------------------------------------------------
CREATE TABLE orders (
    order_id VARCHAR(64) PRIMARY KEY,
    type VARCHAR(32) NOT NULL CHECK (type IN ('bulkCoordination', 'householdConsumer')),
    requirement_id VARCHAR(64),
    match_id VARCHAR(64),
    crop_name VARCHAR(128) NOT NULL,
    total_quantity_kg DECIMAL(10, 2) NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL,
    buyer_id VARCHAR(64) REFERENCES users(id),
    buyer_name VARCHAR(128) NOT NULL,
    delivery_address VARCHAR(255) NOT NULL,
    current_stage VARCHAR(64) NOT NULL,
    current_status_text VARCHAR(255) NOT NULL,
    eta VARCHAR(64),
    route_id VARCHAR(64),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO orders (order_id, type, requirement_id, match_id, crop_name, total_quantity_kg, total_amount, buyer_id, buyer_name, delivery_address, current_stage, current_status_text, eta, route_id) VALUES
('AGR-1024', 'bulkCoordination', 'req_tomato_001', 'match_001', 'Tomato (Hybrid Roma)', 500.0, 10000.00, 'usr_buyer_001', 'FreshBasket Wholesale Mandi Pvt Ltd', 'Kothapet Wholesale Mandi, Hyderabad', 'inTransit', 'In Transit to Kothapet Mandi', 'Today, 4:30 PM', 'ROUTE-OPT-2026-902'),
('AGR-2048', 'householdConsumer', NULL, NULL, 'Organic Household Veggie Basket', 3.0, 110.00, 'usr_consumer_001', 'Ananya Sharma', 'Flat 402, Green Meadows, Madhapur, Hyderabad - 500081', 'inTransit', 'Delivery partner is 1.8 km away', 'In 15-25 mins', NULL);

CREATE TABLE order_timeline (
    id SERIAL PRIMARY KEY,
    order_id VARCHAR(64) REFERENCES orders(order_id),
    stage VARCHAR(64) NOT NULL,
    title VARCHAR(128) NOT NULL,
    subtitle VARCHAR(255),
    timestamp TIMESTAMP WITH TIME ZONE,
    is_completed BOOLEAN DEFAULT FALSE,
    is_current BOOLEAN DEFAULT FALSE,
    step_order INT NOT NULL
);

INSERT INTO order_timeline (order_id, stage, title, subtitle, timestamp, is_completed, is_current, step_order) VALUES
('AGR-1024', 'orderCreated', 'Requirement Posted', '500kg Tomato Grade A requested by FreshBasket', '2026-09-07 06:00:00+00', TRUE, FALSE, 1),
('AGR-1024', 'supplyMatched', 'AI Multi-Farmer Supply Matched', 'Combined Ramesh (100kg), Suresh (150kg), Ravi (250kg)', '2026-09-07 08:15:00+00', TRUE, FALSE, 2),
('AGR-1024', 'supplyAggregated', 'FPO Lot Consolidated', 'Aggregated at Shabad Hub #1 (25-ton cold chamber)', '2026-09-07 10:45:00+00', TRUE, FALSE, 3),
('AGR-1024', 'qualityEvidence', 'AI Computer Vision Grading Certified', 'Grade A Verified (91.0% confidence, 2.1% defect rate)', '2026-09-07 11:30:00+00', TRUE, FALSE, 4),
('AGR-1024', 'pickupScheduled', 'Multi-Stop Pickup Dispatched', '1.2 Ton Mini-Truck (TS-08-AB-4412) loaded across 3 farms', '2026-09-07 12:00:00+00', TRUE, FALSE, 5),
('AGR-1024', 'inTransit', 'Consignment In Transit', 'En route to Kothapet Mandi (Current: Outer Ring Road Exit 14)', '2026-09-07 13:45:00+00', TRUE, TRUE, 6),
('AGR-1024', 'delivered', 'Mandi Weighbridge & Gate Entry', 'Verification scan at Wholesale Mandi Gate 2', NULL, FALSE, FALSE, 7),
('AGR-1024', 'settlementCompleted', 'Direct Jan Dhan Payout Settled', 'Instant 100% bank transfer with zero middleman fee', NULL, FALSE, FALSE, 8);

-- -----------------------------------------------------------------------------
-- 8. SMART MULTI-STOP LOGISTICS ROUTES & STOPS (CVRP)
-- -----------------------------------------------------------------------------
CREATE TABLE logistics_routes (
    route_id VARCHAR(64) PRIMARY KEY,
    route_name VARCHAR(128) NOT NULL,
    vehicle_id VARCHAR(64) NOT NULL,
    vehicle_type VARCHAR(64) DEFAULT '1.2 Ton Mini-Truck',
    total_distance_km DECIMAL(8, 2) NOT NULL,
    total_weight_loaded_kg DECIMAL(10, 2) NOT NULL,
    estimated_duration_minutes INT NOT NULL,
    estimated_fuel_cost_inr DECIMAL(8, 2) NOT NULL,
    co2_emissions_kg DECIMAL(6, 2) NOT NULL,
    status VARCHAR(32) DEFAULT 'optimized',
    current_lat DECIMAL(10, 6),
    current_lng DECIMAL(10, 6),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO logistics_routes (route_id, route_name, vehicle_id, vehicle_type, total_distance_km, total_weight_loaded_kg, estimated_duration_minutes, estimated_fuel_cost_inr, co2_emissions_kg, status, current_lat, current_lng) VALUES
('ROUTE-OPT-2026-902', 'Cluster #4 Shabad - Kothapet Express', 'TRUCK-TS-08-AB-4412', '1.2 Ton Mini-Truck', 42.60, 500.0, 105, 580.00, 6.40, 'inTransit', 17.3400, 78.4200);

CREATE TABLE route_stops (
    id VARCHAR(64) PRIMARY KEY,
    route_id VARCHAR(64) REFERENCES logistics_routes(route_id),
    label VARCHAR(64) NOT NULL,
    person_name VARCHAR(128) NOT NULL,
    crop VARCHAR(64) NOT NULL,
    quantity_kg DECIMAL(10, 2) NOT NULL,
    scheduled_time VARCHAR(32) NOT NULL,
    latitude DECIMAL(10, 6) NOT NULL,
    longitude DECIMAL(10, 6) NOT NULL,
    type VARCHAR(32) NOT NULL CHECK (type IN ('farmPickup', 'buyerDropoff', 'fpoHub', 'consumerDelivery')),
    is_completed BOOLEAN DEFAULT FALSE,
    stop_sequence INT NOT NULL
);

INSERT INTO route_stops (id, route_id, label, person_name, crop, quantity_kg, scheduled_time, latitude, longitude, type, is_completed, stop_sequence) VALUES
('STOP-01', 'ROUTE-OPT-2026-902', 'Farm Stop #1', 'Ramesh Reddy', 'Tomato', 100.0, '09:30 AM', 17.3075, 78.1362, 'farmPickup', TRUE, 1),
('STOP-02', 'ROUTE-OPT-2026-902', 'Farm Stop #2', 'Suresh Patil', 'Tomato', 150.0, '10:15 AM', 17.2150, 78.2380, 'farmPickup', TRUE, 2),
('STOP-03', 'ROUTE-OPT-2026-902', 'Farm Stop #3', 'Ravi Patel', 'Tomato', 250.0, '11:00 AM', 17.3200, 78.2800, 'farmPickup', TRUE, 3),
('STOP-04', 'ROUTE-OPT-2026-902', 'Wholesale Mandi', 'Vikram Mehta (FreshBasket)', 'Tomato (Aggregated)', 500.0, '01:30 PM', 17.3688, 78.5398, 'buyerDropoff', FALSE, 4);

-- -----------------------------------------------------------------------------
-- 9. JAN DHAN & DIRECT BANK SETTLEMENTS (ZERO MIDDLEMAN FEE)
-- -----------------------------------------------------------------------------
CREATE TABLE farmer_settlements (
    id VARCHAR(64) PRIMARY KEY,
    order_id VARCHAR(64) REFERENCES orders(order_id),
    farmer_id VARCHAR(64) REFERENCES users(id),
    farmer_name VARCHAR(128) NOT NULL,
    produce_id VARCHAR(64) REFERENCES produce_listings(id),
    crop_name VARCHAR(64) NOT NULL,
    quantity_kg DECIMAL(10, 2) NOT NULL,
    rate_per_kg DECIMAL(8, 2) NOT NULL,
    gross_amount DECIMAL(10, 2) NOT NULL,
    intermediary_deduction DECIMAL(10, 2) DEFAULT 0.00,
    net_payout_amount DECIMAL(10, 2) NOT NULL,
    bank_name VARCHAR(128) NOT NULL,
    account_masked VARCHAR(32) NOT NULL,
    ifsc VARCHAR(32) NOT NULL,
    utr_number VARCHAR(64) NOT NULL,
    trigger_event VARCHAR(64) DEFAULT 'Mandi Gate Weighbridge Entry',
    status VARCHAR(32) DEFAULT 'COMPLETED',
    settled_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO farmer_settlements (id, order_id, farmer_id, farmer_name, produce_id, crop_name, quantity_kg, rate_per_kg, gross_amount, intermediary_deduction, net_payout_amount, bank_name, account_masked, ifsc, utr_number, trigger_event, status, settled_at) VALUES
('stl_001', 'AGR-1024', 'usr_farmer_001', 'Ramesh Reddy', 'prod_tomato_001', 'Tomato', 100.0, 20.00, 2000.00, 0.00, 2000.00, 'State Bank of India (Jan Dhan)', 'XXXX-XXXX-4912', 'SBIN0001234', 'SIH2026TXN991823', 'Mandi Gate Weighbridge Entry', 'COMPLETED', '2026-09-07 13:50:00+00'),
('stl_002', 'AGR-1024', 'usr_farmer_002', 'Suresh Patil', 'prod_tomato_002', 'Tomato', 150.0, 20.00, 3000.00, 0.00, 3000.00, 'Andhra Pragathi Grameena Bank', 'XXXX-XXXX-8821', 'APGB0002194', 'SIH2026TXN991824', 'Mandi Gate Weighbridge Entry', 'COMPLETED', '2026-09-07 13:50:00+00'),
('stl_003', 'AGR-1024', 'usr_farmer_003', 'Ravi Patel', 'prod_tomato_003', 'Tomato', 250.0, 20.00, 5000.00, 0.00, 5000.00, 'Telangana Grameena Bank', 'XXXX-XXXX-1934', 'TGBB0001004', 'SIH2026TXN991825', 'Mandi Gate Weighbridge Entry', 'COMPLETED', '2026-09-07 13:50:00+00');

-- -----------------------------------------------------------------------------
-- 10. CONSUMER PRODUCTS CATALOG (DIRECT FPO FARM-TO-FORK)
-- -----------------------------------------------------------------------------
CREATE TABLE consumer_products (
    id VARCHAR(64) PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    category VARCHAR(64) NOT NULL,
    price_per_kg DECIMAL(8, 2) NOT NULL,
    mrp_price DECIMAL(8, 2) NOT NULL,
    unit VARCHAR(32) DEFAULT '1 kg',
    available_quantity_kg DECIMAL(10, 2) NOT NULL,
    source VARCHAR(128) NOT NULL,
    distance_km DECIMAL(6, 2) NOT NULL,
    quality_grade VARCHAR(16) DEFAULT 'Grade A',
    icon_emoji VARCHAR(8),
    image_url VARCHAR(512),
    rating DECIMAL(3, 2) DEFAULT 4.8,
    rating_count INT DEFAULT 50,
    delivery_time VARCHAR(32) DEFAULT '15-25 mins',
    is_bestseller BOOLEAN DEFAULT FALSE,
    harvest_freshness VARCHAR(64) DEFAULT 'Harvested Today'
);

INSERT INTO consumer_products (id, name, category, price_per_kg, mrp_price, unit, available_quantity_kg, source, distance_km, quality_grade, icon_emoji, image_url, rating, rating_count, delivery_time, is_bestseller, harvest_freshness) VALUES
('cp_001', 'Hybrid Farm Fresh Tomatoes', 'Vegetables', 24.00, 35.00, '1 kg', 120.0, 'Direct from FPO (Ranga Reddy Hub)', 6.4, 'Grade A', '🍅', 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&auto=format&fit=crop&q=80', 4.9, 142, '15-25 mins', TRUE, 'Harvested 3h ago'),
('cp_002', 'Organic Jyoti Potatoes', 'Vegetables', 28.00, 40.00, '1 kg', 350.0, 'Direct from Farmer (Chevella)', 8.1, 'Grade A', '🥔', 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&auto=format&fit=crop&q=80', 4.8, 98, '15-25 mins', TRUE, 'Cleaned & Soil-Free'),
('cp_003', 'Nashik Red Fresh Onions', 'Vegetables', 32.00, 45.00, '1 kg', 210.0, 'Direct from FPO (Ranga Reddy Hub)', 6.4, 'Grade A', '🧅', 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=600&auto=format&fit=crop&q=80', 4.7, 76, '15-25 mins', FALSE, 'Cured & Dry'),
('cp_004', 'Fresh Green Palak (Spinach)', 'Greens', 18.00, 25.00, '1 bunch (250g)', 45.0, 'Direct from Farmer (Moinabad)', 5.2, 'Grade A', '🥬', 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600&auto=format&fit=crop&q=80', 4.9, 115, '15-25 mins', TRUE, 'Harvested at 5 AM Today'),
('cp_005', 'Spicy Guntur Green Chillies', 'Vegetables', 64.00, 88.00, '250 g', 50.0, 'Direct from Farmer (Chevella)', 7.3, 'Grade A', '🌶️', 'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=600&auto=format&fit=crop&q=80', 4.8, 64, '15-25 mins', FALSE, 'Hand-picked'),
('cp_006', 'Premium Sona Masoori Rice (Aged)', 'Grains', 56.00, 72.00, '5 kg bag', 500.0, 'Direct from FPO (Shabad Mill)', 9.0, 'Grade A', '🌾', 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&auto=format&fit=crop&q=80', 4.9, 210, '30-45 mins', TRUE, '1-Year Aged Grain'),
('cp_007', 'Farm Fresh Green Peas (Matar)', 'Vegetables', 45.00, 60.00, '500 g', 80.0, 'Direct from FPO (Ranga Reddy Hub)', 6.4, 'Grade A', '🫛', 'https://images.unsplash.com/photo-1587735243615-c03f25aaff15?w=600&auto=format&fit=crop&q=80', 4.7, 52, '15-25 mins', FALSE, 'Crisp & Sweet Pods'),
('cp_008', 'Organic Ginger (Adrak)', 'Herbs', 75.00, 100.00, '250 g', 40.0, 'Direct from Farmer (Chevella)', 7.3, 'Grade A', '🫚', 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=600&auto=format&fit=crop&q=80', 4.8, 39, '15-25 mins', FALSE, 'Aromatic & Unwashed'),
('cp_009', 'Fresh Crunchy Orange Carrots', 'Vegetables', 42.00, 55.00, '1 kg', 160.0, 'Direct from Farmer (Chevella)', 7.5, 'Grade A', '🥕', 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=600&auto=format&fit=crop&q=80', 4.8, 88, '15-25 mins', TRUE, 'Harvested Today'),
('cp_010', 'Farm Fresh White Cauliflower', 'Vegetables', 38.00, 50.00, '1 piece (~800g)', 95.0, 'Direct from FPO (Shabad Hub)', 6.8, 'Grade A', '🥦', 'https://images.unsplash.com/photo-1568584711075-3d021a7c3ca3?w=600&auto=format&fit=crop&q=80', 4.7, 65, '15-25 mins', FALSE, 'Firm & Compact Head'),
('cp_011', 'Green Bell Peppers (Capsicum)', 'Vegetables', 50.00, 65.00, '500 g', 110.0, 'Direct from FPO (Polyhouse Cluster)', 8.5, 'Grade A', '🫑', 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=600&auto=format&fit=crop&q=80', 4.9, 110, '15-25 mins', TRUE, 'Glossy & Crisp'),
('cp_012', 'Country Fresh Garlic (Lahsun)', 'Herbs', 120.0, 160.00, '250 g', 75.0, 'Direct from Farmer (Chevella)', 7.3, 'Grade A', '🧄', 'https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?w=600&auto=format&fit=crop&q=80', 4.8, 54, '15-25 mins', FALSE, 'Sun-cured & Dry'),
('cp_021', 'Yelakki Farm Bananas', 'Fruits', 45.00, 60.00, '500 g (~6 pcs)', 90.0, 'Direct from Farmer (Chevella)', 6.8, 'Grade A', '🍌', 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=600&auto=format&fit=crop&q=80', 4.9, 145, '15-25 mins', TRUE, 'Naturally Ripened'),
('cp_022', 'Royal Gala Crisp Apples', 'Fruits', 140.00, 180.00, '4 pcs (~650g)', 60.0, 'Direct from FPO (Himachal Link)', 12.5, 'Grade A', '🍎', 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600&auto=format&fit=crop&q=80', 4.8, 92, '15-25 mins', TRUE, 'Crisp & Sweet'),
('cp_023', 'Fresh Ruby Pomegranates (Anaar)', 'Fruits', 95.00, 130.00, '2 pcs (~500g)', 45.0, 'Direct from FPO (Solapur Belt)', 11.0, 'Grade A', '🫐', 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=600&auto=format&fit=crop&q=80', 4.7, 58, '15-25 mins', FALSE, 'Deep Red Arils'),
('cp_031', 'Fresh Banganapalli Sweet Mangoes', 'Fruits', 120.00, 160.00, '1 kg', 150.0, 'Direct from Orchard (Khammam Cluster)', 9.2, 'Grade A', '🥭', 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600&auto=format&fit=crop&q=80', 4.9, 184, '15-25 mins', TRUE, 'Tree Ripe & Sweet'),
('cp_032', 'Farm Fresh Sweet Papaya (Red Lady)', 'Fruits', 42.00, 60.00, '1 piece (~900g)', 95.0, 'Direct from Farmer (Moinabad)', 5.8, 'Grade A', '🍈', 'https://images.unsplash.com/photo-1517282009859-f000ec3b26fe?w=600&auto=format&fit=crop&q=80', 4.8, 77, '15-25 mins', TRUE, 'Naturally Ripened'),
('cp_033', 'Allahabad Sweet White Guavas', 'Fruits', 38.00, 55.00, '500 g', 70.0, 'Direct from Orchard (Chevella)', 7.5, 'Grade A', '🍐', 'https://images.unsplash.com/photo-1536511135898-3f5f3e4e9f3b?w=600&auto=format&fit=crop&q=80', 4.7, 52, '15-25 mins', FALSE, 'Crisp & Sweet White Flesh'),
('cp_034', 'Nagpur Sweet Juicy Oranges (Santra)', 'Fruits', 65.00, 85.00, '1 kg (~6-7 pcs)', 120.0, 'Direct from FPO (Nagpur Link)', 12.0, 'Grade A', '🍊', 'https://images.unsplash.com/photo-1582979512210-99b6a53386f9?w=600&auto=format&fit=crop&q=80', 4.8, 112, '15-25 mins', TRUE, 'Juicy & High Vitamin C'),
('cp_035', 'Fresh Crisp Black Seedless Grapes', 'Fruits', 75.00, 100.00, '500 g box', 85.0, 'Direct from Vineyard (Nashik Hub)', 10.5, 'Grade A', '🍇', 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=600&auto=format&fit=crop&q=80', 4.9, 134, '15-25 mins', TRUE, 'Plump & Sugar Sweet'),
('cp_036', 'Thompson Fresh Green Grapes', 'Fruits', 65.00, 90.00, '500 g box', 90.0, 'Direct from Vineyard (Nashik Hub)', 10.5, 'Grade A', '🍇', 'https://images.unsplash.com/photo-1596363505729-4190a9506133?w=600&auto=format&fit=crop&q=80', 4.7, 68, '15-25 mins', FALSE, 'Crisp & Tangy-Sweet'),
('cp_037', 'Sweet Red Kiran Watermelon', 'Fruits', 65.00, 90.00, '1 piece (~2.5 kg)', 80.0, 'Direct from Farmer (Moinabad)', 6.0, 'Grade A', '🍉', 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=600&auto=format&fit=crop&q=80', 4.9, 160, '15-25 mins', TRUE, 'Deep Red & Hydrating'),
('cp_038', 'Sweet Honey Muskmelon (Kharbooja)', 'Fruits', 48.00, 70.00, '1 piece (~1 kg)', 75.0, 'Direct from Farmer (Chevella)', 7.2, 'Grade A', '🍈', 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=600&auto=format&fit=crop&q=80', 4.8, 81, '15-25 mins', FALSE, 'Aromatic & Golden Center'),
('cp_039', 'Sweet Brown Sapota (Chikoo)', 'Fruits', 35.00, 50.00, '500 g', 65.0, 'Direct from Orchard (Moinabad)', 5.5, 'Grade A', '🥔', 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?w=600&auto=format&fit=crop&q=80', 4.7, 44, '15-25 mins', FALSE, 'Caramel Sweet & Soft'),
('cp_040', 'Fresh Sweet Queen Pineapple', 'Fruits', 55.00, 75.00, '1 piece (~1 kg)', 60.0, 'Direct from FPO (South Hub)', 11.0, 'Grade A', '🍍', 'https://images.unsplash.com/photo-1550258987-190a2d41a8ba?w=600&auto=format&fit=crop&q=80', 4.8, 92, '15-25 mins', TRUE, 'Fragrant Golden Core'),
('cp_041', 'Fresh Tangy Gongura (Sorrel Leaves)', 'Greens', 15.00, 22.00, '1 bunch (~200g)', 75.0, 'Direct from Farmer (Moinabad)', 5.2, 'Grade A', '🌿', 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600&auto=format&fit=crop&q=80', 4.9, 120, '15-25 mins', TRUE, 'Harvested 4 AM Today'),
('cp_042', 'Fresh Red Amaranth Leaves (Thotakura)', 'Greens', 16.00, 25.00, '1 bunch (~250g)', 60.0, 'Direct from Farmer (Chevella)', 6.8, 'Grade A', '🥬', 'https://images.unsplash.com/photo-1524179091875-bf99a9a6fa57?w=600&auto=format&fit=crop&q=80', 4.8, 64, '15-25 mins', FALSE, 'Rich Iron & Mineral Packed'),
('cp_043', 'Aromatic Fresh Curry Leaves (Kadi Patta)', 'Greens', 12.00, 18.00, '1 bunch (~100g)', 100.0, 'Direct from Farmer (Moinabad)', 4.9, 'Grade A', '🍃', 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=600&auto=format&fit=crop&q=80', 4.9, 210, '15-25 mins', TRUE, 'Crisp Dark Green Aroma'),
('cp_044', 'Tender Moringa Leaves (Munagaku)', 'Greens', 18.00, 28.00, '1 bunch (~150g)', 40.0, 'Direct from Farmer (Chevella)', 7.1, 'Grade A', '🌿', 'https://images.unsplash.com/photo-1515543237350-b3eea1ec8082?w=600&auto=format&fit=crop&q=80', 4.9, 88, '15-25 mins', TRUE, 'Superfood Morning Harvest'),
('cp_045', 'Tender Malabar Spinach (Bachali Kura)', 'Greens', 16.00, 24.00, '1 bunch (~250g)', 50.0, 'Direct from Farmer (Moinabad)', 5.3, 'Grade A', '🥬', 'https://images.unsplash.com/photo-1628771065518-0d82f1938462?w=600&auto=format&fit=crop&q=80', 4.7, 42, '15-25 mins', FALSE, 'Plump Succulent Leaves'),
('cp_046', 'Crisp Farm Spring Onion Greens (Hari Pyaz)', 'Greens', 22.00, 32.00, '1 bunch (~200g)', 65.0, 'Direct from Farmer (Chevella)', 6.5, 'Grade A', '🧅', 'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=600&auto=format&fit=crop&q=80', 4.8, 95, '15-25 mins', FALSE, 'Crisp Green Stalks'),
('cp_047', 'Fresh Fragrant Dill Leaves (Shepu / Suva)', 'Greens', 18.00, 26.00, '1 bunch (~150g)', 45.0, 'Direct from Farmer (Moinabad)', 5.2, 'Grade A', '🌿', 'https://images.unsplash.com/photo-1509358271058-acd22cc93898?w=600&auto=format&fit=crop&q=80', 4.8, 53, '15-25 mins', FALSE, 'Feathery Fragrant Leaves'),
('cp_048', 'Crunchy Green Lettuce & Salad Leaves', 'Greens', 35.00, 50.00, '1 head (~200g)', 40.0, 'Direct from Hydroponic Hub (Ranga Reddy)', 8.5, 'Grade A', '🥗', 'https://images.unsplash.com/photo-1556801712-76c8eb07bbc9?w=600&auto=format&fit=crop&q=80', 4.9, 114, '15-25 mins', TRUE, 'Clean Hydroponic Pluck'),
('cp_049', 'Winter Fresh Mustard Greens (Sarson Ka Saag)', 'Greens', 20.00, 30.00, '1 bunch (~250g)', 55.0, 'Direct from Farmer (Moinabad)', 5.4, 'Grade A', '🥬', 'https://images.unsplash.com/photo-1518843875459-f738682238a6?w=600&auto=format&fit=crop&q=80', 4.8, 67, '15-25 mins', FALSE, 'Peppery Tender Green Leaves');

-- -----------------------------------------------------------------------------
-- 11. MANDI MARKET TRENDS & AI PRICE FORECASTS
-- -----------------------------------------------------------------------------
CREATE TABLE mandi_price_forecasts (
    id SERIAL PRIMARY KEY,
    commodity VARCHAR(64) NOT NULL,
    mandi_id VARCHAR(64) NOT NULL,
    mandi_name VARCHAR(128) NOT NULL,
    state_district VARCHAR(128) NOT NULL,
    current_mandi_price_per_kg DECIMAL(8, 2) NOT NULL,
    predicted_price_7_days DECIMAL(8, 2) NOT NULL,
    price_trend_direction VARCHAR(32) NOT NULL,
    trend_percentage VARCHAR(16) NOT NULL,
    action_recommendation VARCHAR(64) NOT NULL,
    market_insight TEXT,
    lower_bound DECIMAL(8, 2),
    upper_bound DECIMAL(8, 2),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO mandi_price_forecasts (commodity, mandi_id, mandi_name, state_district, current_mandi_price_per_kg, predicted_price_7_days, price_trend_direction, trend_percentage, action_recommendation, market_insight, lower_bound, upper_bound) VALUES
('Tomato', 'APMC-KOTHAPET-01', 'Kothapet Wholesale Mandi', 'Hyderabad, Telangana', 20.50, 23.80, 'BULLISH_UP', '+16.1%', 'HOLD_2_DAYS', 'Regional wholesale arrival down 14% due to rainfall in Anantapur corridor. Expect higher price realization in 48 hours.', 22.10, 25.50),
('Wheat', 'APMC-BOWENPALLY-02', 'Bowenpally Market Yard', 'Secunderabad, Telangana', 27.50, 30.80, 'BULLISH_UP', '+12.0%', 'HOLD_2_DAYS', 'Institutional milling demand increasing ahead of festival cycle.', 29.20, 32.40),
('Potato', 'APMC-KOTHAPET-01', 'Kothapet Wholesale Mandi', 'Hyderabad, Telangana', 22.00, 21.50, 'STABLE', '-2.2%', 'SELL_NOW', 'Cold storage offloading expected from Agra-Hathras belt next week. Liquidate current batches.', 20.80, 22.20),
('Onion', 'APMC-VASHI-04', 'Vashi APMC Mandi', 'Navi Mumbai, Maharashtra', 28.00, 34.00, 'BULLISH_UP', '+21.4%', 'HOLD_4_DAYS', 'Nashik arrivals hindered by local transport strikes. Tight supply in major distribution markets.', 32.50, 36.00);

-- -----------------------------------------------------------------------------
-- 12. NOTIFICATIONS & ALERTS
-- -----------------------------------------------------------------------------
CREATE TABLE notifications (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) REFERENCES users(id),
    title VARCHAR(128) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(64) NOT NULL,
    reference_id VARCHAR(64),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO notifications (id, user_id, title, message, type, reference_id, is_read, created_at) VALUES
('notif_001', 'usr_farmer_001', '🎉 92% Buyer Match Found!', 'FreshBasket Mandi needs 500kg Tomatoes. Your 100kg batch has been selected for ₹2,000 payout.', 'opportunity_match', 'AGR-1024', FALSE, '2026-09-07 08:16:00+00'),
('notif_002', 'usr_farmer_001', '💰 Jan Dhan Settlement Triggered', '₹2,000 transferred to SBI A/C (ending 4912) upon Mandi gate entry. Zero deductions!', 'payment_settled', 'SIH2026TXN991823', FALSE, '2026-09-07 13:51:00+00'),
('notif_003', 'usr_fpo_001', '📦 3-Farmer Lot Ready for Consolidation', 'Ramesh, Suresh, and Ravi produce batches aggregated into 500kg lot for Order #AGR-1024.', 'fpo_consolidation', 'AGR-1024', TRUE, '2026-09-07 10:45:00+00'),
('notif_004', 'usr_buyer_001', '🚚 Truck In Transit to Kothapet Mandi', '1.2 Ton Mini-Truck (TS-08-AB-4412) loaded with 500kg Grade A Tomatoes. ETA 4:30 PM.', 'logistics_transit', 'ROUTE-OPT-2026-902', FALSE, '2026-09-07 13:45:00+00'),
('notif_005', 'usr_consumer_001', '🛵 Farm Basket Out for Delivery', 'Krishna Murthy (+91 9876543299) is arriving with your order #AGR-2048 in 15 mins.', 'consumer_delivery', 'AGR-2048', FALSE, '2026-09-07 14:40:00+00'),
('notif_006', 'usr_farmer_001', '📈 Tomato Prices Rising (+16%)', 'AI Advisory recommends holding your upcoming tomato batch for 2 days for higher margins.', 'price_advisory', 'crop_tomato', TRUE, '2026-09-07 07:00:00+00');
