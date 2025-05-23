FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY app/build/libs/app-all.jar /app/app.jar
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
