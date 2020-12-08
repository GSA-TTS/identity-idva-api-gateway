""" Tests for app.py """
from chalice.test import Client
from pytest import fixture
from app import app


@fixture
def test_client():
    """ Test fixture for creating a chalice Client """
    with Client(app) as client:
        yield client


def test_index_function(test_client):
    response = test_client.http.get("/")
    assert response.json_body == {"hello": "world"}


def test_hello_name_function(test_client):
    name = "myname"
    response = test_client.http.get(f"/hello/{name}")
    assert response.json_body == {"hello": f"{name}"}

    name = "different_name"
    response = test_client.http.get(f"/hello/{name}")
    assert response.json_body == {"hello": f"{name}"}
