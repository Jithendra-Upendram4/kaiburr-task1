FROM eclipse-temurin:21-jre AS runtime

# Use Maven build artifact produced by CI or local build
WORKDIR /app
COPY target/kaiburr-task1-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","/app/app.jar"]
