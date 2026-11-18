# H9 — Federación de identidad con OIDC y SSO

**Módulo:** [3 — Federación y microservicios](../README.md) · **Formato:** Teoría · 60 min
**Lab asociado:** [Lab 3.1 — SPA con PKCE](../laboratorio-3.1-spa-pkce/) (H10)
**Actividad/entregable (cronograma):** Mapeo de claims en tokens OIDC.

## Objetivo de la hora
Entender cómo OIDC añade **login** sobre OAuth y distinguir con claridad los dos tipos de token.

## Contenidos
- **ID token vs access token (el error nº1):**
  - **ID token** → es para el **cliente**: lo consume y lo tira.
  - **Access token** → es para la **API**; el cliente lo trata como **opaco**.
  - Mandar el ID token a la API es el error más común del curso.
- **Scope vs claim:** *scope* = lo que la app pide; *claim* = lo que el token **afirma**.
- **`aud` (audience):** impide que un token válido en un servicio valga en otro.
- **UserInfo endpoint:** fuente de atributos del usuario.
- **SSO:** una sesión en el servidor de autorización, varias apps.

## Conexiones
- Los claims (`iss`, `aud`, `exp`) se decodifican en el entregable del **Lab 3.1**.
- `aud` reaparece como defensa en el **Lab 3.2** (validación en el gateway).

## Preguntas para el aula
- [ ] (a desarrollar) ¿Qué pasa si una API acepta un token cuyo `aud` es otro servicio?

## Pendiente
- [ ] Desarrollar guion de aula / notas del instructor
- [ ] Ejercicio: mapear claims de un ID token y un access token reales

Fuente: briefing §2 (Módulo 3); PDF cronograma H9.
