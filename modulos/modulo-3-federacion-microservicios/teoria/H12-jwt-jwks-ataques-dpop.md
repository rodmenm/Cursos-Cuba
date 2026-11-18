# H12 — Deep dive en JWT: JWKS, ataques y DPoP

**Módulo:** [3 — Federación y microservicios](../README.md) · **Formato:** Teoría · 60 min
**Lab asociado:** [Lab 3.2 — Gateway en el borde](../laboratorio-3.2-gateway-borde/) (H13)
**Actividad/entregable (cronograma):** Diseño de políticas defensivas contra robo de tokens.

## Objetivo de la hora
Abrir el JWT por dentro, ver sus ataques clásicos y las defensas (incluida la constricción por
posesión de clave).

## Contenidos
- **Anatomía:** header (`alg`, `kid`), payload, firma. **Base64URL no es cifrado** (se lee a ojo).
- **Firmas:** HS256 simétrica (quien valida puede emitir → no escala entre servicios) vs
  RS256/ES256 asimétricas. **JWKS** publica las claves públicas; **`kid`** permite **rotar** sin corte.
- **Ataques:**
  - `alg: none`.
  - **Confusión de algoritmo** (cambiar RS256 por HS256 y firmar con la clave pública como secreto)
    → se evita **fijando el algoritmo esperado** en el validador.
- **Revocación:** el JWT **no se revoca por diseño**; una lista de `jti` en Redis reintroduce estado.
- **Sender-constrained (posesión de clave):** el bearer es "efectivo" (quien lo tiene lo gasta);
  **DPoP (RFC 9449)** y **mTLS (RFC 8705)** lo atan a una clave. DPoP en navegador, mTLS
  backend-a-backend.

## Conexiones
- El ataque de manipular el payload y romper la firma se hace en el **Romperlo del Lab 3.2**.
- Revocación vs expiración reaparece en el **Lab de Vault** (Módulo 4).

## Preguntas para el aula
- [ ] (a desarrollar) Si un token robado es un "bearer", ¿qué añade DPoP exactamente?

## Pendiente
- [ ] Desarrollar guion de aula / notas del instructor
- [ ] Ejercicio: política defensiva contra robo de tokens (JWKS + alg fijo + sender-constrained)

Fuente: briefing §2 (Módulo 3); PDF cronograma H12.
