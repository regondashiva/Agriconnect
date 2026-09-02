# 📋 AgriConnect: User Registration & Onboarding Schema Document

> **Document Version**: 1.0.0  
> **Platform**: AgriConnect (Smart Agricultural Coordination Platform - SIH 2026)  
> **Target Audience**: Backend Engineers, Database Architects, Frontend Integrators  

---

## 📌 Architecture Overview

```
                      [ Phone Number + OTP Verification ]
                                     ↓
                      [ Role Selection (4 User Roles) ]
                                     ↓
   ┌──────────────────┬──────────────────┬──────────────────┬──────────────────┐
   ↓                  ↓                  ↓                  ↓                  ↓
[ Farmer ]         [ Farmer ]          [ FPO ]        [ Bulk Buyer ]     [ Consumer ]
 (Manual)          (Voice AI)      (Coordinator)       (Wholesale)      (Household)
```

---

## 1. 📱 Common Authentication (Pre-Registration)
Before role-specific registration, all users authenticate via their mobile number and OTP.

### Schema:
```json
{
  "phone_number": "+91 9876543210",
  "country_code": "+91",
  "otp_code": "123456",
  "is_verified": true,
  "auth_timestamp": "2026-09-02T13:15:00Z"
}
```

---

## 2. 🌾 Role 1: Farmer Registration

### A. Manual Farmer Registration Schema
* **Flutter Screen**: `ManualRegistrationScreen`  
* **API Endpoint**: `POST /api/v1/users/register/farmer`

```json
{
  "user_id": "FARMER-2026-001",
  "role": "farmer",
  "full_name": "Ramesh Reddy",
  "phone_number": "+91 9876543210",
  "farm_location": "Chevella Village, Ranga Reddy Dist, Telangana",
  "coordinates": {
    "latitude": 17.3075,
    "longitude": 78.1362
  },
  "primary_crops": [
    "Tomato",
    "Potato",
    "Chillies"
  ],
  "preferred_language": "Telugu / English",
  "fpo_cluster_assigned": "Ranga Reddy Organic Producers FPO",
  "verified_id": "SIH-AP-FARMER-2026"
}
```

### B. Voice AI Farmer Registration Schema
* **Flutter Screen**: `VoiceRegistrationScreen`  
* **API Endpoint**: `POST /api/v1/ai/voice-registration`

```json
{
  "audio_recording_url": "s3://agriconnect-voice/audio_098.wav",
  "detected_language": "te-IN",
  "transcribed_text": "నా పేరు రమేష్ రెడ్డి, చేవెళ్ల గ్రామం. నేను టొమాటో మరియు మిరప పండిస్తున్నాను.",
  "extracted_entities": {
    "name": "Ramesh Reddy",
    "village": "Chevella",
    "crops": ["Tomato", "Chillies"],
    "language": "Telugu"
  },
  "confidence_score": 0.96
}
```

---

## 3. 🏢 Role 2: FPO Coordinator Registration
* **Flutter Screen**: `FpoRegistrationScreen`  
* **API Endpoint**: `POST /api/v1/users/register/fpo`

```json
{
  "user_id": "FPO-TS-RR-089",
  "role": "fpo",
  "fpo_name": "Ranga Reddy Farmers Producer Co-op",
  "registration_id": "FPO-TS-RR-2026-089",
  "contact_person_name": "Suresh Rao",
  "phone_number": "+91 9876543211",
  "hub_location": "Shabad Center, Hyderabad Rural, Telangana",
  "coordinates": {
    "latitude": 17.2000,
    "longitude": 78.2500
  },
  "member_farmers_count": 48,
  "aggregation_capacity_ton": 25.0,
  "active_crop_clusters": [
    "Tomato",
    "Wheat",
    "Paddy",
    "Onion"
  ]
}
```

---

## 4. 🏬 Role 3: Bulk Buyer / Processor Registration
* **Flutter Screen**: `BuyerRegistrationScreen`  
* **API Endpoint**: `POST /api/v1/users/register/buyer`

```json
{
  "user_id": "BUYER-HYD-102",
  "role": "bulkBuyer",
  "representative_name": "Vikram Mehta",
  "business_name": "FreshBasket Wholesale Mandi Pvt Ltd",
  "business_type": "Wholesale Mandi Trader",
  "phone_number": "+91 9876543212",
  "delivery_hub_location": "Kothapet Wholesale Mandi, Hyderabad",
  "coordinates": {
    "latitude": 17.3688,
    "longitude": 78.5398
  },
  "gstin_tax_id": "36AABCF1234Z1ZX",
  "preferred_commodities": [
    "Tomato",
    "Potato",
    "Onion",
    "Wheat"
  ],
  "monthly_procurement_volume_ton": 150.0
}
```

---

## 5. 🛒 Role 4: Household Consumer Registration
* **Flutter Screen**: `ConsumerRegistrationScreen`  
* **API Endpoint**: `POST /api/v1/users/register/consumer`

```json
{
  "user_id": "CONSUMER-HYD-504",
  "role": "consumer",
  "full_name": "Ananya Sharma",
  "phone_number": "+91 9876543213",
  "delivery_address": "Flat 402, Green Meadows, Madhapur, Hyderabad - 500081",
  "coordinates": {
    "latitude": 17.4483,
    "longitude": 78.3915
  },
  "preferred_basket_type": "Weekly Organic Veggie Box",
  "payment_preference": "UPI / Cash on Delivery"
}
```

---

## 📊 Summary Schema Reference Table

| Field Name | Data Type | Mandatory | Applicable Roles | Description |
| :--- | :--- | :---: | :--- | :--- |
| `id` | `String (UUID)` | Yes | All Roles | Unique user identifier |
| `name` | `String` | Yes | All Roles | Full Name / Representative Name |
| `phoneNumber` | `String` | Yes | All Roles | Verified 10-digit mobile number (`+91`) |
| `role` | `Enum` | Yes | All Roles | `farmer` \| `fpo` \| `bulkBuyer` \| `consumer` |
| `location` | `String` | Yes | All Roles | Farm Village / FPO Hub / Delivery Address |
| `businessName` | `String?` | Optional | `fpo`, `bulkBuyer` | Registered business/cooperative name |
| `registrationId` | `String?` | Optional | `fpo`, `bulkBuyer` | FPO Reg ID / GSTIN |
| `primaryCrops` | `List<String>?` | Optional | `farmer` | Crops harvested by the farmer |
| `preferredLanguage`| `String?` | Optional | `farmer`, `fpo` | `Telugu / English` \| `Hindi` \| `English` |
| `fpoCluster` | `String?` | Optional | `farmer`, `fpo` | Assigned local aggregation hub |
