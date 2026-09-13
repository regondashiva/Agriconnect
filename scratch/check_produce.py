import urllib.request
import urllib.error
import json

token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2YTJjMmJhYi1iNjYxLTRmOTUtYmQ5MS1mODBhNzM0NDU0YWIiLCJwaG9uZSI6Iis5MTcwMDAwMDAwMDEiLCJyb2xlIjoiZmFybWVyIiwiaWF0IjoxNzg4ODA5MzQ0LCJleHAiOjE3ODg4OTU3NDR9.As7W4cWlYrHhJi76UozASYI3CuaujXq33tRjAAhAeh8"

# Test empty body
req = urllib.request.Request("https://agriconnect-api-fiz5.onrender.com/api/v1/farmer/produce", data=b'{}', headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"}, method="POST")
try:
    res = urllib.request.urlopen(req)
    print("RES:", res.read().decode("utf-8"))
except urllib.error.HTTPError as e:
    print("ERR:", e.code, e.read().decode("utf-8"))
