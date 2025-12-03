
FROM maven:3.9.11-eclipse-temurin-11-noble AS builder

WORKDIR /app

# Copy pom.xml first
COPY sourcecodeseniorwr/pom.xml .

# Copy source code
COPY sourcecodeseniorwr/ ./

# Build the jar
RUN mvn install

# Stage 2: Runtime with Eclipse Temurin JRE

FROM tomcat:9-jre8-alpine

LABEL Author="Mohamed Elsayed" 

WORKDIR /app

RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=builder /app/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
