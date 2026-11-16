# ---- Stage 1: build (Maven + JDK, thrown away afterwards) ----
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY pom.xml .
RUN mvn -B -q dependency:go-offline
COPY src ./src
RUN mvn -B -q clean package -DskipTests

# ---- Stage 2: slim runtime (JRE only, non-root) ----
FROM eclipse-temurin:17-jre-jammy
RUN useradd --system --uid 1001 --no-create-home appuser
WORKDIR /app
COPY --from=build /workspace/target/todo-api.jar app.jar
USER 1001
EXPOSE 8080
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75"
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar app.jar"]
