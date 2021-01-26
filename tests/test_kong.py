import requests
import json
import pytest

def pytest_namespace():
    return {"json_response": ""}

@pytest.fixture
def status_code():
    pytest.json_response = requests.get("http://localhost:8081")

@pytest.fixture
def oauth_plugin():
    pytest.json_response = requests.get("http://localhost:8081/services/auth-service/plugins/")

@pytest.fixture
def auth_service():
    pytest.json_response = response = requests.get("http://localhost:8081/services/auth-service")

@pytest.fixture
def idemia_service():
    pytest.json_response = response = requests.get("http://localhost:8081/services/idemia-microservice")

def test_get_kong_check_status_code(status_code):
    assert pytest.json_response.status_code == 200

def test_get_kong_plugins_verify_global_oauth(oauth_plugin):
    body_dictionary = json.loads(pytest.json_response.text)

    data = body_dictionary["data"]

    for x in range(len(data)):
        plugin = data[x]
        if plugin["name"] == "oauth2":
            config = plugin["config"]
            if config["enable_client_credentials"] and config["enable_authorization_code"] and config["global_credentials"]:
                assert True
                return
            assert False
    assert False

def test_get_kong_service_verify_auth_service(auth_service):
    assert pytest.json_response.status_code == 200

def test_get_kong_service_verify_idemia_service(idemia_service):
    assert pytest.json_response.status_code == 200
