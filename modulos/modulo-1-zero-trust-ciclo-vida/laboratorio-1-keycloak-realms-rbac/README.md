# Lab 1 — Keycloak, realms y RBAC

**Módulo:** [1 — Zero Trust y ciclo de vida](../README.md).
**Infra:** Keycloak del [`docker-compose.yml` compartido](../../../infra/) (tag fijo, `start-dev --import-realm`).
**Materiales/entregables:** [`materiales/`](materiales/).

## Montaje
Compose con Keycloak y `infra/realms` montado en `/opt/keycloak/data/import`. Realm exportado
vacío pero **con el cliente ya creado**, para que el Lab 3 no dependa de acertar aquí.

## El alumno
Levanta el stack, entra a la consola admin, crea el realm `curso`, dos usuarios, los roles
`lector` y `editor`, el grupo `redaccion` con `editor` asignado, mete un usuario en el grupo y
comprueba la herencia.

## Momento clave
El realm es una frontera de aislamiento: un usuario del realm master no existe en `curso`. Se
pilla mirando dos consolas de login distintas.

## Romperlo
Quitar el rol del grupo y ver que el usuario lo pierde sin tocar al usuario.

## Entregable
Export del realm en JSON con roles y grupos dentro → [`materiales/`](materiales/).

## Pendiente
- [ ] Guion clic-a-clic con salida esperada y comando de reset
- [ ] Realm base en [`infra/realms/`](../../../infra/realms/)

Fuente: [briefing §3, Lab 1](../../../docs/curso-identidad-briefing.md).
