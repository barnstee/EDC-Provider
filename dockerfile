# Stage 1: Build the application
FROM gradle:8.11.1-jdk17 AS build
WORKDIR /app

# Copy the Gradle wrapper and project files
COPY gradlew .
COPY gradle.properties .
COPY gradle ./gradle
COPY build.gradle.kts .
COPY settings.gradle.kts .

# Download dependencies
RUN ./gradlew build --no-daemon -x test

# Copy the source code and build the application
COPY transfer ./transfer
COPY resources ./resources
RUN ./gradlew build --no-daemon -x test

# Stage 2: Create the final image
FROM openjdk:17-slim
WORKDIR /app

# Copy the jar file from the build stage
COPY --from=build /app/transfer/transfer-00-prerequisites/connector/build/libs/connector.jar app.jar
COPY --from=build /app/transfer/transfer-00-prerequisites/resources/certs/cert.pfx .
COPY --from=build /app/transfer/transfer-00-prerequisites/resources/configuration/provider-configuration.properties .

# Expose the ports
EXPOSE 19191
EXPOSE 19192
EXPOSE 19193
EXPOSE 19194
EXPOSE 19195
EXPOSE 19291

# Run the application
ENTRYPOINT ["java", "-Dedc.keystore=cert.pfx", "-Dedc.keystore.password=123456", "-Dedc.fs.config=provider-configuration.properties", "-jar", "app.jar"]
