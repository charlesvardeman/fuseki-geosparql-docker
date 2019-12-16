# Experimental Docker Container for Apache Jena Fuseki2 with GeoSparql Support

This repository contains the Dockerfile to build [Jena](https://jena.apache.org) [GeoSPARQL Fuseki](https://jena.apache.org/documentation/geosparql/geosparql-fuseki) HTTP server. GeoSPARQL Fuseki uses the [embedded server Fuseki]() and provides additional command line parameters for spatial dataset loading. The original implimentation can be found in the [galbiston/geosparql-fuseki](https://github.com/galbiston/geosparql-fuseki) repository and was merged into the main Jena tree as of [Jena release 3.12.0](https://github.com/apache/jena/tree/jena-3.12.0). This build of Jena Fuseki with GeoSPARQL support is somewhat "Experimental" and is NOT suitable for production release without modification.

Some of the container options are based off of the [blankdots](docker-SemanticWebApps)[https://github.com/blankdots/docker-SemanticWebApps] [build configuration](https://github.com/blankdots/docker-SemanticWebApps/tree/master/apache-fuseki) for apache-fuseki. This includes the use of [gosu](https://github.com/tianon/gosu) to manage container permissions. By default, GeoSPARQL-Fuseki starts on port 3030.

## Building Docker container
The Dockerfile is constructed as a [mult-stage build](https://github.com/docker/docker.github.io/blob/master/develop/develop-images/multistage-build.md) to keep the final container size smaller than if it had the entire Jena source tree contained within its file system. To build the container:

```bash
docker build --rm -f "Dockerfile" -t charlesvardeman/geosparql-fuseki:latest "."
```

To construct the "build image", you can specify the target build stage in the Docker build command line.

```bash
docker build --target builder -t charlesvardeman/geosparql-fuseki:latest "."
```

To remove the intermediate build images:
```bash
docker image prune --filter label=stage=builder
```

Prebuilt containers for the Jena github master snapshot (cvardman/fuseki-geosparql:latest) and Jena releases (for example cvardman/fuseki-geosparql:jena-3.13.1) are available in [dockerhub](https://hub.docker.com/r/cvardman/fuseki-geosparql).

## Running GeoSPARQL Fuseki
The docker image is provisioned by default with the test [GeoSPARQL dataset](https://github.com/galbiston/geosparql-fuseki/blob/master/geosparql_test.rdf) which is loaded by default when the container starts.

## Command Line Arguments
Command line arguments are set via environment variables in the "docker-entrypoint.sh" script. See this script for the latest options.

Boolean options that have false defaults only require "--option" to make true in release v1.0.7 or later.
Release v1.0.6 and earlier use the form "--option true".

### 1) Port
```
--port, -p
env PORT=(port number)
```

The port number of the server. Default: 3030

### 2) Dataset name
```
--dataset, -d
```

The name of the dataset used in the URL. Default: ds

### 3) Loopback only
```
--loopback, -l
```

The server only accepts local host loopback requests. Default: true

### 4) SPARQL update allowed
```
--update, -u
```

The server accepts updates to modify the dataset. Inferencing and spatial indexing will not be applied until the server is restarted. Default: false

### 5) TDB folder
```
--tdb, -t
```

An existing or new TDB folder used for the dataset. Default set to memory dataset.
If accessing a dataset for the first time with GeoSPARQL then consider the `--inference`, `--default_geometry` and `--validate` options. These operations may add additional statements to the dataset.

### 6) Load RDF file into dataset
```
--rdf_file, -rf
```

Comma separated list of [RDF file path#graph name&RDF format] to load into dataset. Graph name is optional and will use default graph. RDF format is optional (default: ttl) or select from one of the following: json-ld, json-rdf, nt, nq, thrift, trig, trix, ttl, ttl-pretty, xml, xml-plain, xml-pretty.
e.g. `test.rdf#test&xml,test2.rdf` will load _test.rdf_ file into _test_ graph as _RDF/XML_ and _test2.rdf_ into _default_ graph as _TTL_.

Consider the `--inference`, `--default_geometry` and `--validate` options. These operations may add additional statements to the dataset.

### 7) Load Tabular file into dataset
```
--tabular_file, -tf
```

Comma separated list of [Tabular file path#graph name|delimiter] to load into dataset. See RDF Tables for table formatting. Graph name is optional and will use default graph. Column delimiter is optional and will default to COMMA. Any character except ':', '^' and '|'. Keywords TAB, SPACE and COMMA are also supported.
e.g. `test.rdf#test|TAB,test2.rdf` will load _test.rdf_ file into _test_ graph as _TAB_ delimited and _test2.rdf_ into _default_ graph as _COMMA_ delimited.

See RDF Tables project (https://github.com/galbiston/rdf-tables) for more details on tabular format.

Consider the `--inference`, `--default_geometry` and `--validate` options. These operations may add additional statements to the dataset.

### 8) GeoSPARQL RDFS inference
```
--inference, -i
```

Enable GeoSPARQL RDFS schema and inferencing (class and property hierarchy). Inferences will be applied to the dataset. Updates to dataset may require server restart. Default: false

### 9) Apply hasDefaultGeometry
```
--default_geometry, -dg
```

Apply hasDefaultGeometry to single Feature hasGeometry Geometry statements. Additional properties will be added to the dataset. Default: false

### 10) Validate Geometry Literals
```
--validate, -v
```

Validate that the Geometry Literals in the dataset are valid. Default: false

### 11) Convert Geo predicates
```
--convert_geo, -c
```

Convert Geo predicates in the data to Geometry with WKT WGS84 Point GeometryLiteral. Default: false

### 12)  Remove Geo predicates
```
--remove_geo, -rg
```

Remove Geo predicates in the data after combining to Geometry.

### 13) Query Rewrite enabled
```
--rewrite, -r
```

Enable query rewrite extension of GeoSPARQL standard to simplify queries, which relies upon the 'hasDefaultGeometry' property. The 'default_geometry' may be useful for adding the 'hasDefaultGeometry' to a dataset. Default: true

### 14) Indexing enabled
```
--index, -x
```

Enable caching of re-usable data to improve query performance. Default: true
See GeoSPARQL Jena project (https://github.com/galbiston/geosparql-jena) for more details.

### 15) Index sizes
```
--index_sizes, -xs
```

List of Index item sizes: [Geometry Literal, Geometry Transform, Query Rewrite]. Unlimited: -1, Off: 0 Unlimited: -1, Off: 0, Default: -1,-1,-1

### 16) Index expiries
```
--index_expiry, -xe
```

List of Index item expiry in milliseconds: [Geometry Literal, Geometry Transform, Query Rewrite]. Off: 0, Minimum: 1001, Default: 5000,5000,5000

### 17) Spatial Index file
```
--spatial_index, -si
```

File to load or store the spatial index. Default to "spatial.index" in TDB folder if using TDB and not set. Otherwise spatial index is not stored.