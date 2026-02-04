import requests

SERVER_IP = "13.60.38.68"   # replace with your EC2 IP
URL = f"http://{SERVER_IP}:5000/query"

query = "SELECT Name FROM Artist LIMIT 5"

response = requests.post(
    URL,
    json={"sql": query}
)

print("Status:", response.status_code)
print("Result:")

for row in response.json():
    print(row)
