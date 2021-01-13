import requests
import json

def test_get_kong_check_status_code():
    response = requests.get("http://localhost:8081")
    assert response.status_code == 200

def test_get_kong_plugins_verify_oauth():
    response = requests.get("http://localhost:8081/plugins/")
    body_dictionary = json.loads(response.text)

    data = body_dictionary["data"]

    for x in range(len(data)):
        plugin = data[x]
        if plugin["name"] == "oauth2":
            config = plugin["config"]
            if config["enable_client_credentials"] == True and config["enable_authorization_code"] == True and config["global_credentials"] == True:
                assert True
                return
            assert False
    assert False

def test_get_kong_service_verify_auth_service():
    response = requests.get("http://localhost:8081/services/")
    body_dictionary = json.loads(response.text)

    data = body_dictionary["data"]

    for x in range(len(data)):
        service = data[x]
        if service["name"] == "auth-service":
            assert True
            return

    assert False
