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
    
    user_data = {
        "username": args.username,
        "custom_id": args.id
    }
    oauth_data = {
        "name": "oauth2"
    }

    # create consumer
    r = requests.post(url, data = user_data)
    if (r.status_code != 201):
        raise SystemError("Error creating consumer.")
    print("Kong consumer successfully created.")

    # generate credentials
    r = requests.post(url + args.username + "/oauth2", data = oauth_data)
    if (r.status_code != 201):
        print("Error creating credentials. Deleting consumer...")
        # try to delete consumer
        r = requests.delete(url + args.username)
        if (r.status_code != 204):
            raise SystemError("Error deleting consumer. Admin invervention required.")
        raise SystemError("Error creating credentials. Consumer deleted.")
    
    # consumer creation successful
    # credential distribution
    json_response = r.json()
    print("GIVE credentials generatated, please store in safe location:")
    print("client_id: ", json_response["client_id"])
    print("client_secret: ", json_response["client_secret"])
