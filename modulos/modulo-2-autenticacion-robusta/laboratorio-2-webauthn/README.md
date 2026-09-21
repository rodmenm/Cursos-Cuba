# Lab 2 — WebAuthn sin escribir backend

**Módulo:** [2 — Autenticación robusta](../README.md).
**Infra:** el mismo Keycloak del Lab 1 ([`docker-compose.yml` compartido](../../../infra/)).
**Materiales/entregables:** [`materiales/`](materiales/).

## Montaje
Reutiliza Keycloak. Probar antes en un portátil igual al del aula.

## El alumno
Copia el flow `browser`, lo pone como passwordless, activa la política WebAuthn del realm y añade
la required action de registro. Antes de probar abre DevTools → More tools → WebAuthn y activa el
**autenticador virtual** (CTAP2, resident keys y user verification activadas). Registra la passkey
y vuelve a entrar sin contraseña.

> Sin el autenticador virtual el lab se muere en máquinas sin Touch ID ni llave física. Es obligatorio.

## Momento clave
El panel del autenticador virtual lista las credenciales con su ID y su contador: prueba visual
de que la privada vive en el autenticador y de que hay una credencial por dominio.

## Romperlo
Borrar la credencial del panel y ver que el login es imposible aunque el usuario exista. Da pie a
hablar de recuperación de cuenta (el problema de verdad de passwordless).

## Entregable
Captura del panel con la credencial + una frase explicando por qué no es phishable → [`materiales/`](materiales/).

## Pendiente
- [ ] Guion clic-a-clic con salida esperada y comando de reset

Fuente: [briefing §3, Lab 2](../../../docs/curso-identidad-briefing.md).
