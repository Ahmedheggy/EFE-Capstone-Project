# Application CI

This directory contains the Docker configuration for the VProfile application.

## Overview

The application is a Java web application built with Maven and deployed on a Tomcat server. The Dockerfile uses a multi-stage build process:
1. **Builder Stage**: Uses `maven:3.9.11-eclipse-temurin-11-noble` to compile the code and package it into a WAR file.
2. **Runtime Stage**: Uses `tomcat:9-jre8-alpine` to run the application.

## Prerequisites

- Docker installed on your machine.

## Building the Image

To build the Docker image, run the following command from this directory:

```bash
docker build -t mohamedelsayed/vprofile-app:v1.0 .
```

## Running the Container

To run the container, use the following command:

```bash
docker run -d -p 8080:8080 --name vprofile-app mohamedelsayed/vprofile-app:v1.0
```

The application will be accessible at `http://localhost:8080`.

## Directory Structure

- `Dockerfile`: The Docker configuration file.
- `source-code-senior/`: The source code of the application.
