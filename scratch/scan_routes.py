import urllib.request
import urllib.error
import json

token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2YTJjMmJhYi1iNjYxLTRmOTUtYmQ5MS1mODBhNzM0NDU0YWIiLCJwaG9uZSI6Iis5MTcwMDAwMDAwMDEiLCJyb2xlIjoiZmFybWVyIiwiaWF0IjoxNzg4ODA5MzQ0LCJleHAiOjE3ODg4OTU3NDR9.As7W4cWlYrHhJi76UozASYI3CuaujXq33tRjAAhAeh8"
user_id = "6a2c2bab-b661-4f95-bd91-f80a734454ab"

paths = [
    # Auth
    ("POST", "/api/v1/auth/send-otp"),
    ("POST", "/api/v1/auth/verify-otp"),
    ("POST", "/api/v1/auth/register"),
    ("POST", "/api/v1/auth/signup"),
    ("POST", "/api/v1/auth/onboarding"),
    ("POST", "/api/v1/auth/complete-profile"),
    ("POST", "/api/v1/auth/update-profile"),
    ("POST", "/api/v1/auth/farmer"),
    ("PUT", "/api/v1/auth/farmer"),
    ("PATCH", "/api/v1/auth/farmer"),
    ("POST", "/api/v1/auth/update"),
    ("PUT", "/api/v1/auth/update"),
    ("PATCH", "/api/v1/auth/update"),

    # Produce
    ("GET", "/api/v1/produce"),
    ("POST", "/api/v1/produce"),
    ("GET", "/api/v1/produce/farmer"),
    ("GET", "/api/v1/produce/my"),
    ("GET", "/api/v1/farmer/produce"),
    ("POST", "/api/v1/farmer/produce"),
    ("GET", "/api/v1/listings"),
    ("POST", "/api/v1/listings"),

    # Buyers / Requirements
    ("GET", "/api/v1/buyer/requirements"),
    ("POST", "/api/v1/buyer/requirements"),
    ("GET", "/api/v1/requirements"),
    ("POST", "/api/v1/requirements"),

    # Matching
    ("GET", "/api/v1/matching/find"),
    ("GET", "/api/v1/matching"),
    ("POST", "/api/v1/matching"),

    # Voice / AI
    ("POST", "/api/v1/voice/chat"),
    ("POST", "/api/v1/ai/voice-parse"),
    ("POST", "/api/v1/ai/voice-registration"),

    # Non /api/v1 paths
    ("POST", "/auth/send-otp"),
    ("POST", "/auth/verify-otp"),
    ("GET", "/users"),
    ("POST", "/users"),
    ("GET", "/farmers"),
    ("POST", "/farmers"),
    ("GET", "/produce"),
    ("POST", "/produce"),
    ("GET", "/health"),
]

for method, path in paths:
    url = f"https://agriconnect-api-fiz5.onrender.com{path}"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    sample_body = {
        "user_id": user_id,
        "full_name": "Ramesh Kumar",
        "name": "Ramesh Kumar",
        "phone_number": "+917000000001",
        "role": "farmer",
        "location": "Chevella",
        "crop": "Tomato"
    }
    data = json.dumps(sample_body).encode("utf-8") if method in ["POST", "PUT", "PATCH"] else None
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        res = urllib.request.urlopen(req, timeout=4)
        print(f"FOUND: [{res.status}] {method} {path} -> {res.read().decode('utf-8')[:120]}")
    except urllib.error.HTTPError as e:
        if e.code != 404:
            print(f"INTERESTING: [{e.code}] {method} {path} -> {e.read().decode('utf-8')[:120]}")
    except Exception as e:
        pass
print("Done scan.")
