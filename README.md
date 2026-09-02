# AgriConnect — AI-Powered Agricultural Coordination Platform
### Smart India Hackathon 2026 | Problem Statement: SIH26033

> **Tagline**: *"Connecting Farms to Opportunities"*  
> **Target**: Flutter Mobile Application (Android-First)  
> **Design Source of Truth**: Google Stitch Prototype (`projects/3049556434624588798`)

---

## 🌾 Overview
AgriConnect is an end-to-end agricultural supply-demand coordination platform designed to eliminate intermediaries and optimize fresh produce delivery through:
1. **Intelligent Multi-Farmer Supply Aggregation** (Combining smallholder batches into institutional wholesale lots)
2. **AI-Assisted Quality Evidence** (Computer-vision grading with assistive confidence metrics)
3. **Smart Multi-Stop Logistics Route Planning** (Optimized pickup sequence across farm clusters)
4. **Direct Jan Dhan / Bank Settlement** (100% fair payout with zero middleman deductions)
5. **Consumer Demand Intelligence Loop** (Household grocery purchases dynamically forecasting farmer crop planning)

---

## 👥 Four User Roles & Workflows

### 1. Farmer (Ramesh Reddy)
- **Voice Agent Registration**: Natural speech onboarding in Telugu/Hindi/English with live entity extraction.
- **Produce Listing**: Add harvest with photo upload and AI batch scanner.
- **Buyer Opportunities**: 92% match score against 500 kg Tomato requirement.
- **Settlement Tracking**: Direct ₹2,000 payout upon Mandi gate entry for Order `#AGR-1024`.

### 2. FPO Coordinator (Suresh Rao)
- **Manage Member Farmers**: Real-time harvest readiness across 48 cluster farmers.
- **Lot Aggregation**: Batch bundling of Ramesh (100kg), Suresh (150kg), and Ravi (250kg) = 500kg lot.
- **Consignment Dispatch**: Logistics dispatch to wholesale Mandi.

### 3. Bulk Wholesale Buyer (FreshBasket Mandi)
- **Post Demand**: 500 kg Tomato Grade A demand with AI price intelligence (₹19–₹22/kg).
- **Matched Supply**: 3-farmer aggregated lot with 91% quality confidence.
- **Place Order & Live Tracking**: Real-time multi-stop transit monitoring.

### 4. Consumer / Household (Ananya Sharma)
- **Direct Farm Grocery**: Buy 2kg Tomatoes + 1kg Potatoes directly from FPO hub.
- **Instant Delivery**: Live delivery agent tracking for Order `#AGR-2048`.
- **Demand Feedback Loop**: Household purchase data forecasts future farmer demand (+18%).

---

## 🚀 Running the Project

```bash
# 1. Get Flutter dependencies
flutter pub get

# 2. Run on connected Android device / emulator
flutter run
```

---

## 📱 Quick Role Switcher for SIH Evaluators
Tap the **Role Badge** on any screen's header to open the **Role Switcher Sheet** and test all 4 user journeys instantly.

---

## 🤖 AI Engineering & Backend Integration
For the complete schema, payloads, and ML model requirements, see:
- [AI Data Fields Specification Document](file:///c:/Users/shiva/OneDrive/Desktop/Agriconnect/AI_DATA_SPECIFICATION.md)

