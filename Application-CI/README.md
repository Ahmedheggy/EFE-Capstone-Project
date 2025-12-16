# Application-CI

This directory contains the source code and Docker build configuration for the VProfile application.

## Contents

- `Dockerfile`: Multi-stage Dockerfile for building the Java application and creating the runtime image.
- `source-code-senior/`: Directory containing the Java source code and `pom.xml`.

## Build Instructions

To build the Docker image, run the following command from this directory:

```bash
docker build -t vprofile-app .
```

## Tech Stack

- **Java**: 11 (Eclipse Temurin)
- **Build Tool**: Maven
- **Runtime**: Tomcat 9 on Alpine Linux
