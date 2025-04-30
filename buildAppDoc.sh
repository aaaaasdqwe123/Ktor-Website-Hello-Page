#!/bin/bash

while true; do
    read -p "Insert port (defualt port 3000): " PORT

    if [ -z "$PORT" ]; then
        PORT=3000
        break
    fi

    if [[ "$PORT" =~ ^[0-9]+$ ]]; then
        if ((PORT > 0 && PORT < 65536)); then
            break
        else
            echo "The port must be between 1 and 65535"
        fi
    else
        echo "Error: you can only enter numbers."
    fi
done


PROJECT_DIR="$PWD/app"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: The project directory $PROJECT_DIR does not exist"
    exit 1
fi

cd "$PROJECT_DIR" || exit

./gradlew clean

./gradlew shadowJar

JAR_PATH=$(find build/libs -name "*-all.jar" | head -n 1)

if [ -z "$JAR_PATH" ]; then
    echo "Error: The compiled JAR file could not be found."
    exit 1
fi

ABS_JAR_PATH="$PROJECT_DIR/$JAR_PATH"

echo "FROM eclipse-temurin:17-jre-alpine" > Dockerfile
echo "WORKDIR /app" >> Dockerfile
echo "COPY $JAR_PATH /app/app.jar" >> Dockerfile
echo 'ENTRYPOINT ["java", "-jar", "/app/app.jar"]' >> Dockerfile

if docker ps -a --format '{{.Names}}' | grep -q "^my-app-container$"; then
    echo "Removing existing container..."
    docker rm -f my-app-container >/dev/null
fi

echo "Starting application on port $PORT..."
docker build -t my-app . && \
docker run -d --rm -p $PORT:3000 --name my-app-container my-app && \
echo "Application running on port $PORT"
