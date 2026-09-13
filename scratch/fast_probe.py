import urllib.request
import urllib.error
from concurrent.futures import ThreadPoolExecutor

token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2YTJjMmJhYi1iNjYxLTRmOTUtYmQ5MS1mODBhNzM0NDU0YWIiLCJwaG9uZSI6Iis5MTcwMDAwMDAwMDEiLCJyb2xlIjoiZmFybWVyIiwiaWF0IjoxNzg4ODA5MzQ0LCJleHAiOjE3ODg4OTU3NDR9.As7W4cWlYrHhJi76UozASYI3CuaujXq33tRjAAhAeh8"
uid = "6a2c2bab-b661-4f95-bd91-f80a734454ab"

tests = []
for p in ["", "/api", "/api/v1"]:
    for r in ["auth", "user", "users", "farmer", "farmers", "profile", "onboarding"]:
        for a in ["", "/me", "/profile", "/register", f"/{uid}", "/farmer", "/complete", "/update"]:
            for m in ["GET", "POST", "PATCH", "PUT"]:
                tests.append((m, f"{p}/{r}{a}"))

def check(item):
    m, path = item
    url = f"https://agriconnect-api-fiz5.onrender.com{path}"
    req = urllib.request.Request(
        url,
        data=b'{"full_name":"Test"}' if m in ["POST", "PATCH", "PUT"] else None,
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
        method=m
    )
    try:
        res = urllib.request.urlopen(req, timeout=3)
        return (m, path, res.status)
    except urllib.error.HTTPError as e:
        if e.code != 404:
            return (m, path, e.code)
    except Exception:
        pass
    return None

with ThreadPoolExecutor(max_workers=20) as ex:
    results = [r for r in ex.map(check, tests) if r is not None]

print("FOUND VALID ENDPOINTS:", results)
