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

if [ -n "${INF}" ]; then
    CMDOPTS+=" -i "
fi

if [ -n "${UPDATE}" ]; then
    CMDOPTS+=" --update "
fi

if [ -n "${LOOPBACK}" ]; then
    CMDOPTS+=" --loopback false "
fi

if [ -n "${DEFGEO}" ]; then
    CMDOPTS+=" --default_geometry "
fi

if [ -n "${VALGEO}" ]; then
    CMDOPTS+=" --validate "
fi

if [ -n "${REWRITE}" ]; then
    CMDOPTS+=" --rewrite "
fi

if [ -n "${REMGEO}" ]; then
    CMDOPTS+=" --remove_geo "
fi

if [ -n "${INDEX}" ]; then
    CMDOPTS+=" --index "
fi


cat /jena-version
java -jar jena-fuseki-geosparql.jar -rf "${FNAME}" ${CMDOPTS}
