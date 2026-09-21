# Lab 3.1 — SPA con PKCE

**Módulo:** [3 — Federación y microservicios](../README.md).
**Infra:** Keycloak compartido + SPA estática servida por nginx.
**Config del lab:** [`config/`](config/) (`index.html` con keycloak-js + nginx).
**Materiales/entregables:** [`materiales/`](materiales/).

## Montaje
`index.html` estático con keycloak-js servido por nginx en el compose. Nada de Node.
`pkceMethod: 'S256'`, arranque con `check-sso`. Registrar `http://localhost:8081/*` como redirect
URI válida en el cliente público.

## El alumno
Login con la pestaña de red abierta y *preserve log* activado. Sigue la secuencia: petición a
`/auth` con `code_challenge` y `code_challenge_method=S256`, retorno con `code`, POST a `/token`
con el `code_verifier` en claro.

## Momento clave
Poner los dos valores uno al lado del otro y calcular el SHA-256 del verifier en base64url para
comprobar que da el challenge. Única vez en el curso que tocan cripto a mano (dos minutos).

## Romperlo
Interceptar el `code` y reintentar el canje desde curl sin el verifier correcto. El servidor lo
rechaza: el código robado no vale sin la prueba de que eres quien lo pidió.

## Entregable
Las dos peticiones capturadas y el access token decodificado con `iss`, `aud` y `exp` señalados
→ [`materiales/`](materiales/).

## Pendiente
- [ ] Guion clic-a-clic con salida esperada y comando de reset
- [ ] `index.html` + config nginx en [`config/`](config/)

Fuente: [briefing §3, Lab 3.1](../../../docs/curso-identidad-briefing.md).
