import urllib.request
import urllib.error
import json

token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2YTJjMmJhYi1iNjYxLTRmOTUtYmQ5MS1mODBhNzM0NDU0YWIiLCJwaG9uZSI6Iis5MTcwMDAwMDAwMDEiLCJyb2xlIjoiZmFybWVyIiwiaWF0IjoxNzg4ODA5MzQ0LCJleHAiOjE3ODg4OTU3NDR9.As7W4cWlYrHhJi76UozASYI3CuaujXq33tRjAAhAeh8"
uid = "6a2c2bab-b661-4f95-bd91-f80a734454ab"

verbs = ["GET", "POST", "PUT", "PATCH"]
paths = [
    "/api/v1/auth/register",
    "/api/v1/auth/profile",
    "/api/v1/auth/user",
    "/api/v1/auth/users",
    "/api/v1/auth/edit",
    "/api/v1/auth/update",
    "/api/v1/auth/farmer",
    "/api/v1/user",
    f"/api/v1/user/{uid}",
    "/api/v1/users",
    f"/api/v1/users/{uid}",
    "/api/v1/profile",
    "/api/v1/farmer",
    f"/api/v1/farmer/{uid}",
    "/api/v1/farmers",
    "/api/v1/farmer/profile",
    "/api/v1/farmer/onboarding",
    "/api/v1/farmer/details",
    "/api/v1/farmer/register",
]

found = []
for p in paths:
    for m in verbs:
        url = f"https://agriconnect-api-fiz5.onrender.com{p}"
        req = urllib.request.Request(
            url,
            data=b'{"full_name":"Test Farmer"}' if m in ["POST", "PUT", "PATCH"] else None,
            headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
            method=m
        )
        try:
            res = urllib.request.urlopen(req, timeout=3)
            print(f"MATCH: {m} {p} -> {res.status}")
            found.append((m, p, res.status))
        except urllib.error.HTTPError as e:
            if e.code != 404:
                print(f"INTERESTING: {m} {p} -> {e.code} ({e.read().decode('utf-8')[:80]})")
                found.append((m, p, e.code))
        except:
            pass

print("SCAN COMPLETE. Found:", found)
