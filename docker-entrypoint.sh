#!/bin/sh

/jena-fuseki/bin/geosparql-fuseki -rf "geosparql_test.rdf>xml" -i --loopback false
