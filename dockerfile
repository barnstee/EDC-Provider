# Stage 1: Build the application
FROM gradle:8.11.1-jdk23 AS build
WORKDIR /app

# Copy the Gradle wrapper and project files
COPY gradlew .
COPY gradle ./gradle
COPY build.gradle.kts .
COPY settings.gradle.kts .

# Download dependencies
RUN ./gradlew build --no-daemon -x test

# Copy the source code and build the application
COPY transfer ./transfer
RUN ./gradlew build --no-daemon -x test

# Stage 2: Create the final image
FROM openjdk:23-slim
WORKDIR /app

# Copy the jar file from the build stage
COPY --from=build /transfer/transfer-00-prerequisites/libs/connector.jar app.jar

# Expose the application port
EXPOSE 80

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
