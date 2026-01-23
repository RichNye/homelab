import requests

url = "https://meals.rnye.tech"

while True:
    response = requests.get(url)
    print(response.status_code, response.reason)