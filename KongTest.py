import requests
import json

def test_get_kong_check_status_code():
    response = requests.get("http://localhost:8081")
    assert response.status_code == 200

def test_get_kong_plugins_verify_hmac():
    response = requests.get("http://localhost:8081/plugins")
    body_dictionary = json.loads(response.text)

    data = body_dictionary["data"]

    for x in range(len(data)):
        if data[x]["name"] == "hmac-auth":
            assert True
            return
    assert False
