import urllib.request
import urllib.error

prefixes = ["", "/api", "/api/v1"]
resources = [
    "user", "users", "profile", "profiles", "farmer", "farmers",
    "farmer-profile", "farmer_profile", "auth", "account", "onboarding"
]
actions = ["", "/me", "/profile", "/register", "/update", "/farmer", "/all"]

token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2YTJjMmJhYi1iNjYxLTRmOTUtYmQ5MS1mODBhNzM0NDU0YWIiLCJwaG9uZSI6Iis5MTcwMDAwMDAwMDEiLCJyb2xlIjoiZmFybWVyIiwiaWF0IjoxNzg4ODA5MzQ0LCJleHAiOjE3ODg4OTU3NDR9.As7W4cWlYrHhJi76UozASYI3CuaujXq33tRjAAhAeh8"

hits = []
for p in prefixes:
    for r in resources:
        for a in actions:
            path = f"{p}/{r}{a}"
            url = f"https://agriconnect-api-fiz5.onrender.com{path}"
            for m in ["GET", "POST", "PATCH", "PUT"]:
                req = urllib.request.Request(
                    url,
                    data=b'{"test":1}' if m in ["POST", "PATCH", "PUT"] else None,
                    headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
                    method=m
                )
                try:
                    res = urllib.request.urlopen(req, timeout=2)
                    print(f"FOUND: {m} {path} -> {res.status}")
                    hits.append((m, path, res.status))
                except urllib.error.HTTPError as e:
                    if e.code != 404:
                        print(f"FOUND: {m} {path} -> {e.code}")
                        hits.append((m, path, e.code))
                except Exception:
                    pass

print("ALL HITS:", hits)
