# ============
# 1. Build stage
# ============
FROM maven:3.9.6-eclipse-temurin-21 AS build

WORKDIR /app

# Copy pom.xml first (cache dependencies)
COPY pom.xml .
RUN mvn -q -e -DskipTests dependency:go-offline

# Copy source code
COPY src ./src

# Build application
RUN mvn -q -e -DskipTests package


# ============
# 2. Runtime stage
# ============
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Railway uses PORT env variable
ENV PORT=8080
EXPOSE 8080

# Copy built JAR
COPY --from=build /app/target/*.jar app.jar

# Run app
ENTRYPOINT ["java", "-jar", "app.jar"]
