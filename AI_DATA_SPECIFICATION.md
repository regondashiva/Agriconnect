# 🌾 AgriConnect: AI Models & Data Fields Specification Document

> **Document Version**: 1.0.0  
> **Target Audience**: AI / ML Engineering Team, Backend Developers, Data Scientists  
> **Platform**: AgriConnect (Smart Agricultural Coordination Platform - SIH 2026)

---

## 📌 Executive Summary
AgriConnect relies on **5 core AI/ML engines** to empower farmers, optimize supply chains, ensure crop quality, and streamline farm-to-fork logistics:
1. **AI Smart Match & Aggregation Engine** (Supply & Demand Matching)
2. **Computer Vision Crop Quality Grading** (Defect & Grade Assessment)
3. **Multilingual Voice-to-Form Registration NLP** (Vernacular Voice AI)
4. **Smart Multi-Pickup Logistics & CVRP Route Optimizer** (Routing AI)
5. **Mandi Price Prediction & Demand Forecasting AI** (Price Trends & Market Advisory)

---

## 1. 🤖 AI Smart Match & Aggregation Engine

### Purpose:
Matches large-scale bulk procurement requirements from buyers/processors with multiple smallholder farmers and FPO clusters based on crop type, quality standards, geographic proximity, and availability dates.

### 📥 Input Payload Schema (`POST /api/v1/ai/match-demand`):
```json
{
  "buyer_requirement": {
    "requirement_id": "REQ-2026-001",
    "buyer_id": "BUYER-102",
    "buyer_name": "FreshBasket Corp",
    "crop_name": "Wheat",
    "variety": "Sharbati / MP Organic",
    "required_quantity_kg": 500000.0,
    "quality_grade_required": "gradeA",
    "target_price_min": 25.0,
    "target_price_max": 28.5,
    "required_by_date": "2026-09-15T00:00:00Z",
    "delivery_location": {
      "city": "Pune",
      "state": "Maharashtra",
      "latitude": 18.5204,
      "longitude": 73.8567
    }
  },
  "candidate_farmer_supplies": [
    {
      "produce_id": "PROD-101",
      "farmer_id": "FARMER-88",
      "farmer_name": "Ramesh Kumar",
      "crop_name": "Wheat",
      "available_quantity_kg": 15000.0,
      "quality_grade": "gradeA",
      "quality_score": 88.5,
      "confidence_score": 91.0,
      "expected_price_per_kg": 26.0,
      "harvest_ready_date": "2026-09-10T00:00:00Z",
      "pickup_location": {
        "village": "Shirur",
        "district": "Pune",
        "latitude": 18.8268,
        "longitude": 74.3788
      }
    }
  ]
}
```

### 📤 AI Output Schema:
```json
{
  "match_id": "MATCH-7782",
  "requirement_id": "REQ-2026-001",
  "crop_name": "Wheat",
  "required_quantity_kg": 500000.0,
  "matched_quantity_kg": 500000.0,
  "match_score_percent": 94.2,
  "overall_quality_score": 87.5,
  "confidence_score": 91.0,
  "is_fully_fulfilled": true,
  "total_estimated_value": 13250000.0,
  "selected_contributors": [
    {
      "farmer_id": "FARMER-88",
      "farmer_name": "Ramesh Kumar",
      "allocated_quantity_kg": 15000.0,
      "payout_amount": 390000.0,
      "pickup_location": "Shirur, Pune",
      "distance_to_hub_km": 14.2
    }
  ],
  "aggregation_hub_suggested": "Sahyadri FPO Cluster Hub #2",
  "logistics_summary": {
    "total_distance_km": 34.5,
    "estimated_travel_time": "1 hr 45 min",
    "recommended_vehicle": "1.2 Ton Mini-Truck"
  }
}
```

---

## 2. 📸 Computer Vision Crop Quality Grading AI

### Purpose:
Predicts commercial grade (`Grade A`, `Grade B`, `Grade C`), defect percentage, freshness index, and shelf life from mobile crop photos.

### 📥 Input Payload Schema (`POST /api/v1/ai/grade-produce`):
| Field | Type | Description |
| :--- | :--- | :--- |
| `crop_name` | `string` | Name of the commodity (e.g. `Tomato`, `Wheat`, `Onion`) |
| `images` | `List<string/base64>` | 3-6 multi-angle crop images |
| `harvest_timestamp` | `string (ISO 8601)` | Timestamp when harvest was gathered |
| `farm_coordinates` | `object { lat, lng }` | Geotagging for climate verification |
| `moisture_level` *(optional)* | `float` | Moisture sensor reading (e.g., `12.5`) |

### 📤 AI Output Schema:
```json
{
  "predicted_grade": "gradeA",
  "quality_score": 89.4,
  "confidence_score": 93.8,
  "risk_level": "LOW",
  "defect_percentage": 2.1,
  "observations": [
    "High color consistency across produce batch",
    "Uniform grain / fruit size distribution",
    "No visible pest punctures or rot detected",
    "Optimal moisture reflectance"
  ],
  "estimated_shelf_life_days": 14,
  "suggested_price_multiplier": 1.08
}
```

---

## 3. 🎙️ Multilingual Voice-to-Form Registration NLP

### Purpose:
Enables regional and non-literate farmers to list produce or register by speaking in Hindi, Telugu, Marathi, Tamil, Kannada, or English.

### 📥 Input Payload Schema (`POST /api/v1/ai/voice-parse`):
| Field | Type | Description |
| :--- | :--- | :--- |
| `audio_stream` | `binary / wav / m4a` | Recorded voice input from mobile mic |
| `source_language` | `string` | Language code (e.g. `te-IN`, `hi-IN`, `mr-IN`, `en-IN`) |
| `target_entity_type` | `string` | `produce_listing` \| `farmer_onboarding` |

### 📤 AI Output Schema:
```json
{
  "transcribed_text": "నా దగ్గర 20 క్వింటాళ్ల సోనా మసూరి వరి ఉంది, కిలో 25 రూపాయలకు అమ్మాలనుకుంటున్నాను",
  "english_translation": "I have 20 quintals of Sona Masoori paddy, looking to sell at 25 rupees per kg",
  "extracted_entities": {
    "crop_name": "Paddy (Sona Masoori)",
    "variety": "Sona Masoori",
    "quantity_kg": 2000.0,
    "expected_price_per_kg": 25.0,
    "harvest_status": "Ready for Harvest",
    "pickup_district": "Khammam",
    "payment_mode_preference": "UPI / Bank Transfer"
  },
  "missing_required_fields": ["available_date", "photos"],
  "confidence": 0.96
}
```

---

## 4. 🚚 Smart Multi-Pickup Logistics & Route Optimization AI

### Purpose:
Calculates the optimal vehicle route for collecting produce from multiple farm hubs with minimum travel time, fuel cost, and carbon emissions.

### 📥 Input Payload Schema (`POST /api/v1/ai/optimize-route`):
```json
{
  "vehicle_config": {
    "vehicle_id": "TRUCK-MH-12-8802",
    "vehicle_type": "1.2 Ton Mini-Truck",
    "max_capacity_kg": 1200.0,
    "avg_fuel_consumption_km_per_l": 14.0
  },
  "depot_start_point": {
    "name": "Sahyadri FPO Central Hub",
    "latitude": 18.5204,
    "longitude": 73.8567
  },
  "buyer_destination": {
    "name": "FreshBasket Distribution Center",
    "latitude": 18.6500,
    "longitude": 73.9300
  },
  "pickup_stops": [
    {
      "stop_id": "STOP-01",
      "farmer_name": "Ramesh Kumar",
      "crop": "Wheat",
      "quantity_kg": 400.0,
      "latitude": 18.5500,
      "longitude": 73.8700,
      "time_window_start": "08:00",
      "time_window_end": "09:00"
    },
    {
      "stop_id": "STOP-02",
      "farmer_name": "Suresh Patil",
      "crop": "Wheat",
      "quantity_kg": 500.0,
      "latitude": 18.5800,
      "longitude": 73.8900,
      "time_window_start": "09:00",
      "time_window_end": "10:00"
    }
  ]
}
```

### 📤 AI Output Schema:
```json
{
  "route_id": "ROUTE-OPT-2026-902",
  "optimized_stop_sequence": [
    "STOP-01",
    "STOP-02",
    "BUYER_DROPOFF"
  ],
  "total_distance_km": 28.4,
  "total_weight_loaded_kg": 900.0,
  "estimated_duration_minutes": 75,
  "estimated_fuel_cost_inr": 380.0,
  "co2_emissions_kg": 4.2,
  "polyline_waypoints": [
    { "latitude": 18.5204, "longitude": 73.8567 },
    { "latitude": 18.5500, "longitude": 73.8700 },
    { "latitude": 18.5800, "longitude": 73.8900 },
    { "latitude": 18.6500, "longitude": 73.9300 }
  ]
}
```

---

## 5. 📈 Mandi Price Prediction & Demand Forecasting AI

### Purpose:
Forecasts market mandi modal prices for 7 to 30 days ahead and gives farmers actionable advisory on whether to hold or sell.

### 📥 Input Payload Schema (`POST /api/v1/ai/forecast-price`):
| Field | Type | Description |
| :--- | :--- | :--- |
| `commodity` | `string` | Commodity name (e.g. `Tomato`, `Wheat`, `Soybean`) |
| `mandi_id` | `string` | Agmarknet / APMC Market ID |
| `state_district` | `string` | e.g. `Nashik, Maharashtra` |
| `historical_prices_7d` | `List<float>` | Daily modal prices for last 7-30 days |
| `weather_context` *(optional)* | `object` | Rainfall, temperature index |

### 📤 AI Output Schema:
```json
{
  "commodity": "Wheat",
  "current_mandi_price_per_kg": 27.50,
  "predicted_price_7_days": 30.80,
  "price_trend_direction": "BULLISH_UP",
  "trend_percentage": "+12.0%",
  "action_recommendation": "HOLD_2_DAYS",
  "market_insight": "Regional supply shortage expected due to rain disruption in transport corridors.",
  "confidence_range": {
    "lower_bound": 29.20,
    "upper_bound": 32.40
  }
}
```

---

## 🏗️ Technology Stack Recommendation for AI Team

| Component | Recommended Framework / Models |
| :--- | :--- |
| **API Serving** | FastAPI / Python 3.11 with Pydantic & Uvicorn |
| **Computer Vision** | PyTorch / YOLOv8 / EfficientNet-B4 / OpenCV |
| **NLP & Voice** | OpenAI Whisper / Google Gemini 1.5 Flash / spaCy |
| **Matching & Routing** | Google OR-Tools (CVRP) / SciPy / NetworkX |
| **Time Series Forecasting** | Prophet / LightGBM / XGBoost / DLinear |
| **Deployment** | Docker / Google Cloud Run / AWS ECS |
