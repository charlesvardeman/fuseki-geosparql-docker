#!/bin/sh

CMDOPTS=""
FNAME=""

if [ -n "${PORT}" ]; then
	CMDOPTS+=$PORT
fi

if [ -n "${FILENAME}" ]; then
    FNAME=${FILENAME}
else
    FNAME="geosparql_test.rdf>xml"
fi

echo $FNAME

java -jar jena-fuseki-geosparql-3.14.0-SNAPSHOT.jar -rf "${FNAME}" -i --loopback false
