import urllib.request
import urllib.error
import json

token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2YTJjMmJhYi1iNjYxLTRmOTUtYmQ5MS1mODBhNzM0NDU0YWIiLCJwaG9uZSI6Iis5MTcwMDAwMDAwMDEiLCJyb2xlIjoiZmFybWVyIiwiaWF0IjoxNzg4ODA5MzQ0LCJleHAiOjE3ODg4OTU3NDR9.As7W4cWlYrHhJi76UozASYI3CuaujXq33tRjAAhAeh8"

# Test matching find
url = "https://agriconnect-api-fiz5.onrender.com/api/v1/matching/find?crop=Tomato&quantity_kg=100&lat=17.3&lng=78.1"
req = urllib.request.Request(url, headers={"Authorization": f"Bearer {token}"})
try:
    res = urllib.request.urlopen(req)
    print("MATCHING FIND:", res.status, res.read().decode("utf-8"))
except urllib.error.HTTPError as e:
    print("MATCHING FIND ERR:", e.code, e.read().decode("utf-8"))

# Test GET produce
url = "https://agriconnect-api-fiz5.onrender.com/api/v1/farmer/produce"
req = urllib.request.Request(url, headers={"Authorization": f"Bearer {token}"})
try:
    res = urllib.request.urlopen(req)
    print("GET PRODUCE:", res.status, res.read().decode("utf-8"))
except urllib.error.HTTPError as e:
    print("GET PRODUCE ERR:", e.code, e.read().decode("utf-8"))

# Test POST produce with ProduceItem fields
produce_body = {
    "crop_name": "Tomato",
    "quantity_kg": 100.0,
    "price_per_kg": 25.0,
    "quality_grade": "gradeA",
    "harvest_date": "2026-09-08T00:00:00.000Z",
    "location": "Chevella",
    "latitude": 17.3075,
    "longitude": 78.1362,
    "variety": "Hybrid"
}
url = "https://agriconnect-api-fiz5.onrender.com/api/v1/farmer/produce"
req = urllib.request.Request(url, data=json.dumps(produce_body).encode("utf-8"), headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"})
try:
    res = urllib.request.urlopen(req)
    print("POST PRODUCE:", res.status, res.read().decode("utf-8"))
except urllib.error.HTTPError as e:
    print("POST PRODUCE ERR:", e.code, e.read().decode("utf-8"))
