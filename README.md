# Reto Técnico DevSecOps - Mibanco 2026

Repositorio oficial para la prueba técnica de liderazgo DevSecOps, implementando una arquitectura automatizada de punta a punta con infraestructura como código, seguridad integrada y despliegue en AKS.

## Arquitectura y Decisiones de Diseño (Trade-offs)

1. **Infraestructura Automatizada (Terraform):** Aprovisionamiento declarativo del cluster `aks-mbco-reto` y el Azure Container Registry (ACR), asegurando idempotencia y control de estado remoto.
2. **Autenticacion Moderna (OIDC):** Se suprimieron credenciales estáticas de larga duración (Service Principals con password) en favor de OpenID Connect (`id-token: write`) entre GitHub Actions y Azure, eliminando el riesgo de rotación y filtración de secretos.
3. **Seguridad en Contenedores:** Uso de Dockerfile multi-stage con Java 21 (Temurin) para separar el entorno de compilación (Maven) del runtime, ejecutando la aplicación bajo un usuario sin privilegios (`runAsNonRoot: true`).
4. **Resiliencia Operativa:** Integración de Liveness/Readiness Probes corporativos y un Autoscaler horizontal (HPA configurado de 1 a 3 réplicas basado en uso de CPU).
5. **Security Gates (GitHub Advanced Security):** Integración formal de análisis estático (CodeQL), escaneo de secretos (Gitleaks), análisis de IaC y YAMLs de Kubernetes (Checkov), SCA de dependencias (Maven) y escaneo de vulnerabilidades en contenedores con bloqueo por severidad (Trivy + SARIF).

## Estructura del Repositorio

- `infra/`: Código Terraform para la creación del Resource Group, AKS y ACR (`main.tf`, `variables.tf`, `outputs.tf`).
- `deploy/`: Manifiestos de Kubernetes para la aplicación (`deployment.yaml`, `service.yaml`, `ingress.yaml`, `hpa.yaml`, `namespace.yaml`).
- `.github/workflows/`: Pipelines de GitHub Actions divididos en tres workflows (`infra.yml`, `build-scan-push.yml`, `deploy-validate.yml`).
- `src/`: Código fuente del microservicio en Java 21 / Maven bajo la estructura de paquetes requerida (`com/mibanco/challenge`).
- `Dockerfile`: Definición de compilación multi-stage optimizada.
- `.gitignore` / `.dockerignore`: Exclusión de archivos locales y optimización del contexto de Docker.

## Como Ejecutar los Workflows

1. Configurar los permisos OIDC y secretos necesarios en el repositorio de GitHub.
2. Ejecutar el workflow de infraestructura (`infra.yml`), el cual incluye validación, plan y una **aprobación manual obligatoria (`environment: production`)** antes de aplicar los cambios en Azure para levantar el AKS, el ACR e instalar el Ingress NGINX.
3. Disparar el pipeline de seguridad y construcción (`build-scan-push.yml`) para ejecutar los Quality Gates en paralelo, compilar el código, subir reportes SARIF a GHAS y publicar la imagen con tag inmutable en el ACR.
4. Validar el despliegue automático mediante el workflow `deploy-validate.yml`, verificando el estado de los pods en `mbco-reto-ns` y ejecutando la prueba funcional automatizada con `curl` para confirmar la respuesta exacta del servicio.