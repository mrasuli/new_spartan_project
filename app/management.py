from spartan import Spartans
import json
from pymongo import MongoClient
import time

while True: #this stops the servers from overloading
    try: #connect to the mongo server
        #client = MongoClient("mongodb://db.mrasuli.devops106:27017")
        client = MongoClient("mongodb://127.0.0.1:27017/?compressors=disabled&gssapiServiceName=mongodb")
        break #if not available break
    except Exception as e:
        print("trying to create a connection to the database")
        time.sleep(2)

db = client.spartan_m

def get_all_spartans():
    records = db.clients_data.find()
    all_records = list(records)
    result = ""
    for each_entry in all_records:
        result += f"{each_entry}\n\n"
    return result

def create(create_spartan):
    create_spartan = Spartans(create_spartan["spartan_id"], create_spartan["first_name"], create_spartan["last_name"],
                              create_spartan["birth_year"], create_spartan["birth_month"], create_spartan["birth_day"],
                              create_spartan["sp_course"], create_spartan["sp_stream"])

    if len(create_spartan.get_first_name()) < 2:
        return "Error: first name needs to have at least 2 characters"
    if len(create_spartan.get_last_name()) < 2:
        return "Error: last name needs to have at least 2 characters"
    if len(create_spartan.get_sp_course()) < 2:
        return "Error: spartan course needs to have at least 2 characters"
    if len(create_spartan.get_sp_stream()) < 2:
        return "Error: spartan stream needs to have at least 2 characters"

    if int(create_spartan.get_birth_day()) not in range (1, 32):
        return "ERROR: Day of birth should be a number between 1 and 31."

    if int(create_spartan.get_birth_month()) not in range(1, 12):
        return "ERROR: Month of birth should be a number between 1 and 12."
    if int(create_spartan.get_birth_year()) not in range(1900, 2005):
        return "ERROR: Year of birth should be a number between 1900 and 2005."

    record = db.clients_data.insert_one(vars(create_spartan))
    return f"Spartan has been saved {record}"


def get_spartan(spartan_id):
    found_spartan = {}
    for item in db.clients_data.find({ "spartan_id": int(spartan_id) }):
        found_spartan = item
    return found_spartan
 # try and add try and aceept to catch errors


def remove_spartan(spartan_id):
    try:
        db_response = db.clients_data.delete_one({ "spartan_id": int(spartan_id) })
        if db_response.deleted_count == 1:
            return f"User deleted, sparta ID: {spartan_id}"

        return f"User not found"
    except Exception as exception:
        print(exception)
        print("-----")
        return f"An error has occurred while attempting to delete a spartan"
