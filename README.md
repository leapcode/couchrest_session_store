# CouchRest::Session::Store #

A simple session store based on CouchRest Model.

It will automatically pick up the config/couch.yml file for CouchRest Model

## Options ##

* marhal_data: (_defaults true_) - if set to false session data will be stored directly in the couch document. Otherwise it's marshalled and base64 encoded to enable restoring ruby data structures.
* database: database to use combined with config prefix and suffix
* exprire_after: livetime of a session in seconds
