import argparse, requests

url = "http://localhost:8081/consumers/"

def check_alphanumeric(value):
    if not value.isalnum():
        raise argparse.ArgumentTypeError("%s is not a valid alphanumeric string." % value)
    return value

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Create Kong Consumer')
    parser = argparse.ArgumentParser()
    parser.add_argument('--username', required=True)
    parser.add_argument('--id', type=check_alphanumeric, required=True)
    args = parser.parse_args()

    # create consumer
    response = requests.post(url, data = {"username": args.username, "custom_id": args.id})
    response.raise_for_status()
    print("Kong consumer successfully created.")

    # generate credentials
    response = requests.post(url + args.username + "/oauth2", data = {"name": "oauth2"})
    response.raise_for_status()
    
    # consumer creation successful
    # credential distribution
    json_response = response.json()
    print("GIVE credentials generatated, please store in safe location:")
    print("client_id: ", json_response["client_id"])
    print("client_secret: ", json_response["client_secret"])
