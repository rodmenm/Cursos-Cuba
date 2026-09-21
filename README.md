# Curso de Identidad Digital, Autenticación y Autorización

Curso de 20 horas (14h teoría + 6h laboratorios). Público que llega de cero.
Enfoque práctico: **todo en Docker, el alumno trabaja con interfaces, no escribe backend**.
Cada laboratorio termina abriendo el token y mirándolo.

Documento de contexto y decisiones: [docs/curso-identidad-briefing.md](docs/curso-identidad-briefing.md).

## Organización

El curso está **organizado por módulos**. Cada módulo contiene todo lo suyo: teoría,
diapositivas, recursos y su(s) laboratorio(s) con guion, configuración y materiales.

```
modulos/
  modulo-N-.../
    README.md          índice y contenidos del módulo
    teoria/            guion teórico y notas de aula
    diapositivas/      diapositivas del módulo
    recursos/          RFCs, specs y enlaces
    laboratorio-N-.../
      README.md        guion del lab (montaje · alumno · momento clave · romperlo · entregable)
      config/          configuración propia del lab (solo si tiene servicio propio)
      materiales/      entregables de ejemplo, capturas
```

Lo único **transversal** es [`infra/`](infra/): el `docker-compose.yml` único de todo el curso y
el realm compartido de Keycloak (el briefing exige un solo compose).

## Módulos y laboratorios

| Módulo | Laboratorio(s) |
|---|---|
| [1. Zero Trust y ciclo de vida](modulos/modulo-1-zero-trust-ciclo-vida/) | Lab 1 — Keycloak, realms y RBAC |
| [2. Autenticación robusta](modulos/modulo-2-autenticacion-robusta/) | Lab 2 — WebAuthn sin backend |
| [3. Federación y microservicios](modulos/modulo-3-federacion-microservicios/) | Lab 3.1 — SPA con PKCE · Lab 3.2 — Gateway en el borde |
| [4. PAM e identidades de máquina](modulos/modulo-4-pam-identidades-maquina/) | Lab 4 — Acceso efímero con Vault |
| [5. Identidad descentralizada](modulos/modulo-5-identidad-descentralizada/) | Lab 5 — SD-JWT y presentación selectiva |

## Otras carpetas

| Carpeta | Contenido |
|---|---|
| [`docs/`](docs/) | Briefing y decisiones de diseño. |
| [`infra/`](infra/) | `docker-compose.yml` único + realm compartido de Keycloak. |
| [`capstone/`](capstone/) | Proyecto final (40% de la nota). |
| [`evaluacion/`](evaluacion/) | Rúbricas y entregables del portafolio (60%). |

## Evaluación

- Portafolio de laboratorios: **60%**
- Capstone final: **40%**
