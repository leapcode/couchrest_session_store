# CouchRest::Session::Store #

A simple session store based on CouchRest Model.


## Setup ##

CouchRest::Session::Store will automatically pick up the config/couch.yml file for CouchRest Model.
Cleaning up sessions requires a design document in the sessions database that enables querying by expiry. See the design directory for an example and test/setup_couch.sh for a script that puts the document on the couch for our tests.



## Options ##

* marhal_data: (_defaults true_) - if set to false session data will be stored directly in the couch document. Otherwise it's marshalled and base64 encoded to enable restoring ruby data structures.
* database: database to use combined with config prefix and suffix
* exprire_after: livetime of a session in seconds
