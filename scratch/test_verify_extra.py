import urllib.request
import urllib.error
import json

# Test sending full_name and extra fields in verify-otp
body = {
    "session_id": "mock-session-id",
    "phone_number": "+917000000002",
    "otp": "123456",
    "full_name": "Sita Devi",
    "name": "Sita Devi",
    "location": "Warangal"
}
req = urllib.request.Request(
    "https://agriconnect-api-fiz5.onrender.com/api/v1/auth/verify-otp",
    data=json.dumps(body).encode("utf-8"),
    headers={"Content-Type": "application/json"}
)
try:
    res = urllib.request.urlopen(req)
    data = json.loads(res.read().decode("utf-8"))
    print("USER RETURNED:", data.get("user"))
except urllib.error.HTTPError as e:
    print("ERR:", e.code, e.read().decode("utf-8"))
