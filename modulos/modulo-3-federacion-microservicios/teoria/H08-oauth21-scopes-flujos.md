# H8 — Delegación de autorización con OAuth 2.1

**Módulo:** [3 — Federación y microservicios](../README.md) · **Formato:** Teoría · 60 min
**Lab asociado:** [Lab 3.1 — SPA con PKCE](../laboratorio-3.1-spa-pkce/) (H10)
**Actividad/entregable (cronograma):** Definición de roles OAuth y scopes de API.

## Objetivo de la hora
Entender OAuth 2.1 como **delegación de autorización** (no login) y por qué 2.1 elimina los flujos
inseguros.

## Contenidos
- **Cuatro roles:** propietario del recurso, cliente, servidor de autorización, servidor de recursos.
- **Es delegación, no login.** (El login lo añade OIDC en H9.)
- **Qué elimina 2.1 respecto a 2.0:**
  - *Implicit flow* (token en la URL → queda en historial y logs).
  - *ROPC* (Resource Owner Password Credentials → la app maneja la contraseña).
- **PKCE obligatorio** (Proof Key for Code Exchange) en el flujo Authorization Code.
- **Scopes:** lo que la app **pide** (se distinguirá de *claim* en H9).

## Conexiones
- PKCE se ve en vivo en el **Lab 3.1** (`code_challenge`/`code_verifier`, S256).
- Los roles OAuth se materializan en Keycloak (cliente público vs confidencial).

## Preguntas para el aula
- [ ] (a desarrollar) ¿Por qué un token en la URL es un problema aunque vaya por HTTPS?

## Pendiente
- [ ] Desarrollar guion de aula / notas del instructor
- [ ] Ejercicio: definir roles OAuth y scopes de API para un caso

Fuente: briefing §2 (Módulo 3); PDF cronograma H8.
