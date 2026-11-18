# H11 — Seguridad en microservicios: BFF, validación perimetral y traducción de tokens

**Módulo:** [3 — Federación y microservicios](../README.md) · **Formato:** Teoría · 60 min
**Lab asociado:** [Lab 3.2 — Gateway en el borde](../laboratorio-3.2-gateway-borde/) (H13)
**Actividad/entregable (cronograma):** Análisis de tráfico de microservicios (Este-Oeste).

## Objetivo de la hora
Entender los patrones que hacen manejable la autorización en una arquitectura de microservicios.

## Contenidos
- **Edge authentication:** el gateway valida **una vez en el borde** (Norte-Sur); dentro circula
  tráfico ya autenticado (Este-Oeste).
- **Phantom token:** fuera circula un token **opaco**; el gateway lo canjea por **introspección**
  (**RFC 7662**) por un **JWT firmado interno**. Protege la privacidad del token hacia fuera.
- **BFF (Backend for Frontend):** el SPA **no** guarda tokens en JS (cualquier XSS los roba); un
  backend propio guarda el token y al navegador solo le da **cookie HttpOnly + Secure + SameSite**.

## Conexiones
- El gateway como PEP (Módulo 1) se materializa en el **Lab 3.2** (oauth2-proxy inyecta cabeceras).
- El Lab 3.2 usa oauth2-proxy, que es más "proxy de autenticación" que gateway completo: la
  introspección de token opaco se explica aquí en pizarra (se pierde en ese lab).

## Preguntas para el aula
- [ ] (a desarrollar) ¿Por qué un SPA no debe guardar el access token en `localStorage`?

## Pendiente
- [ ] Desarrollar guion de aula / notas del instructor
- [ ] Diagrama Norte-Sur vs Este-Oeste

Fuente: briefing §2 (Módulo 3); PDF cronograma H11.
