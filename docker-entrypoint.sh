#!/bin/sh

CMDOPTS=""
FNAME=""

if [ -n "${PORT}" ]; then
	CMDOPTS=$PORT
fi

if [ -n "${FILENAME}" ]; then
    FNAME=${FILENAME}
else
    FNAME="geosparql_test.rdf>xml"
fi

if [ -n "${INF}" ]; then
    CMDOPTS="${CMDOPTS} -i "
fi

if [ -n "${UPDATE}" ]; then
    CMDOPTS="${CMDOPTS} --update "
fi

if [ -n "${LOOPBACK}" ]; then
    CMDOPTS="${CMDOPTS} --loopback false "
fi

if [ -n "${DEFGEO}" ]; then
    CMDOPTS="${CMDOPTS} --default_geometry "
fi

if [ -n "${VALGEO}" ]; then
    CMDOPTS="${CMDOPTS} --validate "
fi

if [ -n "${REWRITE}" ]; then
    CMDOPTS="${CMDOPTS} --rewrite "
fi

if [ -n "${REMGEO}" ]; then
    CMDOPTS="${CMDOPTS} --remove_geo "
fi

if [ -n "${INDEX}" ]; then
    CMDOPTS="${CMDOPTS} --index "
fi


cat /jena-version
java -jar jena-fuseki-geosparql.jar -rf "${FNAME}" ${CMDOPTS}
