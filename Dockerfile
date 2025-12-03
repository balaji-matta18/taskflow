# ================================
# 1. Build Stage (Maven + JDK)
# ================================
FROM maven:3.9.6-eclipse-temurin-25 AS build

WORKDIR /app

# Copy pom.xml first to cache dependencies
COPY pom.xml .
RUN mvn -q -e -DskipTests dependency:go-offline

# Copy source code
COPY src ./src

# Build application
RUN mvn -q -e -DskipTests package

# ================================
# 2. Runtime Stage (Slim JRE)
# ================================
FROM eclipse-temurin:25-jre-alpine

WORKDIR /app

ENV PORT=8080
EXPOSE 8080

# Copy the generated JAR from the build stage
COPY --from=build /app/target/*.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]
