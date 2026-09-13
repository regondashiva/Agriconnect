import urllib.request
import urllib.error
import json

token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2YTJjMmJhYi1iNjYxLTRmOTUtYmQ5MS1mODBhNzM0NDU0YWIiLCJwaG9uZSI6Iis5MTcwMDAwMDAwMDEiLCJyb2xlIjoiZmFybWVyIiwiaWF0IjoxNzg4ODA5MzQ0LCJleHAiOjE3ODg4OTU3NDR9.As7W4cWlYrHhJi76UozASYI3CuaujXq33tRjAAhAeh8"
user_id = "6a2c2bab-b661-4f95-bd91-f80a734454ab"

candidates = [
    # Users
    ("GET", "/api/v1/users/me"),
    ("GET", f"/api/v1/users/{user_id}"),
    ("GET", "/api/v1/users/profile"),
    ("GET", "/api/v1/user/profile"),
    ("GET", "/api/v1/auth/me"),
    ("GET", "/api/v1/auth/profile"),
    ("GET", "/api/v1/users"),
    ("PATCH", f"/api/v1/users/{user_id}"),
    ("PUT", f"/api/v1/users/{user_id}"),
    ("PATCH", "/api/v1/users/me"),
    ("PUT", "/api/v1/users/me"),
    ("PATCH", "/api/v1/users/profile"),
    ("PUT", "/api/v1/users/profile"),
    ("POST", "/api/v1/users/profile"),
    ("PATCH", "/api/v1/user/profile"),
    ("PUT", "/api/v1/user/profile"),
    ("PATCH", "/api/v1/auth/profile"),
    ("PUT", "/api/v1/auth/profile"),
    ("POST", "/api/v1/users/register/farmer"),
    ("POST", "/api/v1/farmer/register"),
    ("POST", "/api/v1/farmer/profile"),
    ("PATCH", "/api/v1/farmer/profile"),
    ("PUT", "/api/v1/farmer/profile"),
    ("GET", "/api/v1/farmer/profile"),
    ("POST", "/api/v1/farmers"),
    ("GET", "/api/v1/farmers"),
    ("GET", f"/api/v1/farmers/{user_id}"),
    ("PATCH", f"/api/v1/farmers/{user_id}"),
    ("PUT", f"/api/v1/farmers/{user_id}"),
    ("POST", "/api/v1/farmers/profile"),
    # Producer
    ("GET", "/api/v1/farmer/produce"),
]

sample_body = {
    "full_name": "Test Farmer Ramesh",
    "name": "Test Farmer Ramesh",
    "location": "Warangal, Telangana",
    "farm_location": "Warangal, Telangana",
    "primary_crops": ["Paddy", "Chilli"],
    "land_size_acres": 5.5,
    "phone_number": "+917000000001",
    "role": "farmer"
}

for method, path in candidates:
    url = f"https://agriconnect-api-fiz5.onrender.com{path}"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    data = json.dumps(sample_body).encode("utf-8") if method in ["POST", "PUT", "PATCH"] else None
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        res = urllib.request.urlopen(req, timeout=5)
        print(f"[{res.status}] {method} {path} -> {res.read().decode('utf-8')[:200]}")
    except urllib.error.HTTPError as e:
        body = e.read().decode('utf-8')[:200]
        print(f"[{e.code}] {method} {path} -> {body}")
    except Exception as e:
        print(f"[ERR] {method} {path} -> {e}")
