# --- Stage 1: Build de la aplicación con Maven y Java 21 ---
FROM maven:3.9.6-eclipse-temurin-21 AS builder
WORKDIR /build
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# --- Stage 2: Runtime seguro y minimalista ---
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Crear un usuario no privilegiado por seguridad ( hardening de contenedores )
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Copiar el jar compilado desde la fase anterior
COPY --from=builder /build/target/*.jar app.jar

EXPOSE 8080

# Comando de ejecución con soporte optimizado para contenedores Java
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-jar", "app.jar"]