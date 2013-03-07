# CouchRest Session Store #

A simple session store based on CouchRest Model.

## Options ##

* marhal_data: (_defaults true_) - if set to false session data will be stored directly in the couch document. Otherwise it's marshalled and base64 encoded to enable restoring ruby data structures.
