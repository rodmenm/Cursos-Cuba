# Lab 5 — Acceso efímero con Vault

**Módulo:** [4 — PAM e identidades de máquina](../README.md).
**Infra:** Vault (modo dev) + Postgres en el compose.
**Config del lab:** [`config/`](config/) (init de Vault: motor `database`, rol y TTL).
**Materiales/entregables:** [`materiales/`](materiales/).

Sustituye al lab de PIM del programa original (PIM es Entra ID: nube, tenant, licencia P2, sin contenedor).

## Montaje
Vault en modo dev con token root fijo, más Postgres en el compose. Habilitar el motor `database`,
configurar la conexión y crear un rol con TTL por defecto de 60 segundos.

## El alumno
Pide credenciales al rol, recibe usuario y contraseña generados al momento, conecta a Postgres y
funciona. Espera el TTL, reintenta y falla. Pide otras y ve que el usuario es distinto.

## Momento clave
El usuario de base de datos no existía antes de pedirlo y no existe un minuto después. Eso es JIT
y es la respuesta a NHI: no hay secreto que rotar porque no hay secreto persistente.

## Romperlo
Revocar el lease a mano antes de que expire y ver que la sesión abierta se corta. Introduce
revocación frente a expiración (mismo debate que el JWT del módulo 3).

## Entregable
Las dos credenciales distintas, la conexión correcta y el fallo tras el TTL, con la hora visible
→ [`materiales/`](materiales/).

## Pendiente
- [ ] Guion clic-a-clic con salida esperada y comando de reset
- [ ] Scripts de init de Vault en [`config/`](config/)

Fuente: [briefing §3, Lab 5](../../../docs/curso-identidad-briefing.md).
