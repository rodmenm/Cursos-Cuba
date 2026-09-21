# Lab 3.2 — Gateway, autenticación en el borde y cabeceras inyectadas

**Módulo:** [3 — Federación y microservicios](../README.md).
**Infra:** Keycloak compartido + oauth2-proxy + `traefik/whoami`.
**Config del lab:** [`config/`](config/) (oauth2-proxy + whoami).
**Materiales/entregables:** [`materiales/`](materiales/).

## Decisión
Se descarta APISIX (modelo mental de rutas/upstreams/plugins/admin API demasiado costoso). Se usa
**oauth2-proxy**: un binario con un solo propósito y configuración plana. Detrás, `traefik/whoami`,
que solo imprime las cabeceras que recibe.

## El alumno
Pide al backend sin sesión y recibe 401. Se autentica y recibe 200 más el volcado de cabeceras.

## Momento clave
El alumno no ha puesto ninguna cabecera y aparecen `X-Auth-Request-User` y `X-Auth-Request-Email`
en la respuesta del whoami. Las ha inyectado el gateway.

## Romperlo
Editar el payload del JWT en el decodificador y ver que la firma no cuadra. Dejar expirar el token
y ver el 401 por `exp`. Si da tiempo, apagar Keycloak (argumento a favor de validar localmente).

## Entregable
Las tres respuestas (sin sesión, válida, token manipulado) y la cabecera inyectada
→ [`materiales/`](materiales/).

> **Fallo que causa el 90% de los problemas:** `--oidc-issuer-url` tiene que resolver igual desde
> el contenedor y desde el navegador (issuer mismatch: token para `localhost:8080` vs gateway que
> resuelve `keycloak:8080`). Arrancar con `KC_HOSTNAME=keycloak` y añadir `keycloak` al `/etc/hosts`,
> o usar la misma URL en ambos lados. Probar en frío, borrando volúmenes, antes de clase.

## Pendiente
- [ ] Guion clic-a-clic con salida esperada y comando de reset
- [ ] Config oauth2-proxy + whoami en [`config/`](config/)

Fuente: [briefing §3, Lab 3.2](../../../docs/curso-identidad-briefing.md).
