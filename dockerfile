# Stage 1: Build the application
FROM gradle:7.6.0-jdk23 AS build
WORKDIR /app

# Copy the Gradle wrapper and project files
COPY gradlew .
COPY gradle ./gradle
COPY build.gradle .
COPY settings.gradle .

# Download dependencies
RUN ./gradlew build --no-daemon -x test

# Copy the source code and build the application
COPY src ./src
RUN ./gradlew build --no-daemon -x test

# Stage 2: Create the final image
FROM openjdk:23-jre-slim
WORKDIR /app

# Copy the jar file from the build stage
COPY --from=build /app/build/libs/connector-*.jar app.jar

# Expose the application port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
