import requests

url = 'https://frc-api.firstinspires.org/v3.0/:2024'
headers = {
    'Authorization': 'Basic <khrathore:89e3c17a-4eec-4ee8-8186-63c2f6e89b21>'
}

# Send the HTTP GET request
response = requests.get(url, headers=headers)

# Print the HTTP status code
print("HTTP Status Code:", response.status_code)

# Print the response body
print("Response Body:")
print(response.text)
