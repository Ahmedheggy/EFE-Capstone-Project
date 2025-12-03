FROM maven:3.9.11-eclipse-temurin-11-noble AS builder

WORKDIR /app

# Copy pom.xml first
COPY source-code-senior/pom.xml .

# Copy source code
COPY source-code-senior/ ./

# Build the jar
RUN mvn install

# Stage 2: Runtime with Eclipse Temurin JRE

FROM tomcat:9-jre8-alpine


WORKDIR /app

RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=builder /app/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

RUN adduser -D -H -u 1040 app
RUN chown -R app:app /usr/local/tomcat

EXPOSE 8080

USER app

CMD ["catalina.sh", "run"]


