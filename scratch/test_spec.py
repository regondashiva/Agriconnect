import urllib.request
import urllib.error
import json

token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2YTJjMmJhYi1iNjYxLTRmOTUtYmQ5MS1mODBhNzM0NDU0YWIiLCJwaG9uZSI6Iis5MTcwMDAwMDAwMDEiLCJyb2xlIjoiZmFybWVyIiwiaWF0IjoxNzg4ODA5MzQ0LCJleHAiOjE3ODg4OTU3NDR9.As7W4cWlYrHhJi76UozASYI3CuaujXq33tRjAAhAeh8"

endpoints = [
    ("POST", "/api/v1/users/register/farmer"),
    ("POST", "/api/v1/users/register/fpo"),
    ("POST", "/api/v1/users/register/buyer"),
    ("POST", "/api/v1/users/register/consumer"),
    ("GET", "/api/v1/consumer/products"),
    ("GET", "/api/v1/orders/AGR-1024"),
    ("GET", "/api/v1/matching/find?crop=Tomato&quantity_kg=500&lat=17.3688&lng=78.5398"),
    ("POST", "/api/v1/farmer/produce"),
    ("GET", "/api/v1/farmer/produce"),
    ("POST", "/api/v1/buyer/requirements"),
    ("GET", "/api/v1/buyer/requirements"),
]

for m, p in endpoints:
    url = f"https://agriconnect-api-fiz5.onrender.com{p}"
    body = {
        "user_id": "FARMER-2026-001",
        "role": "farmer",
        "full_name": "Ramesh Reddy",
        "phone_number": "+919876543210",
        "farm_location": "Chevella Village, Ranga Reddy Dist, Telangana",
        "primary_crops": ["Tomato", "Potato", "Chillies"],
        "preferred_language": "Telugu / English",
        "fpo_cluster_assigned": "Ranga Reddy Organic Producers FPO",
        "verified_id": "SIH-AP-FARMER-2026"
    }
    data = json.dumps(body).encode("utf-8") if m == "POST" else None
    req = urllib.request.Request(url, data=data, headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"}, method=m)
    try:
        res = urllib.request.urlopen(req, timeout=4)
        print(f"[{res.status}] {m} {p} -> {res.read().decode('utf-8')[:150]}")
    except urllib.error.HTTPError as e:
        print(f"[{e.code}] {m} {p} -> {e.read().decode('utf-8')[:150]}")
    except Exception as e:
        print(f"[ERR] {m} {p} -> {e}")
