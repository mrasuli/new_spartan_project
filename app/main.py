from flask import Flask, request
from pymongo import MongoClient
import time
import management

#http://127.0.0.1:8080/
flask_app = Flask(__name__) #this is telling py that i want to create a new server
@flask_app.route('/')
def home_page():
    return "This is the home page for flask and MongoDB. Please use the following API's to naviage through the app"

#http://127.0.0.1:8080/add
@flask_app.route('/add', methods=['POST']) #allows the user to add the spartan data by passing a json file
def add_spartan ():
    spartan = request.get_json() #using json, we are passing data through the body
    management.create(spartan)
    return f"the spartan that's been added is {spartan}"

#http://127.0.0.1:8080/5
@flask_app.route('/<spartan_id>', methods=["GET"])
def get_spartan(spartan_id):
    found_spartan = management.get_spartan(spartan_id)
    return f"{found_spartan}"


#http://127.0.0.1:8080/5
@flask_app.route('/<spartan_id>', methods=['DELETE'])
def delete_spartan(spartan_id):
    response = management.remove_spartan(spartan_id)
    return response

#http://127.0.0.1:8080/list
@flask_app.route('/list', methods=['GET'])
def spartan_list():
    all_spartans = management.get_all_spartans()
    return all_spartans

if __name__ =="__main__":
    flask_app.run(debug=True, port = 8080, host= '0.0.0.0')
