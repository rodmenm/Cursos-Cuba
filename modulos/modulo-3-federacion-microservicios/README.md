# Módulo 3 — Federación y microservicios

Es el módulo donde se ahogan; recibe la hora liberada del módulo 4. Tiene **dos laboratorios**.

## Estructura del módulo

| Carpeta | Contenido |
|---|---|
| [`teoria/`](teoria/) | Guion teórico y notas de aula. |
| [`diapositivas/`](diapositivas/) | Diapositivas del módulo (se generan más adelante). |
| [`recursos/`](recursos/) | RFCs y bibliografía (OAuth 2.1, OIDC, RFC 9700, 7662, 9449, 8705). |
| [`laboratorio-3-spa-pkce/`](laboratorio-3-spa-pkce/) | Lab 3: SPA con PKCE. |
| [`laboratorio-4-gateway-borde/`](laboratorio-4-gateway-borde/) | Lab 4: gateway y autenticación en el borde. |

## Contenidos

- **OAuth 2.1**: cuatro roles. Es delegación, no login. 2.1 elimina implicit y ROPC; PKCE
  obligatorio.
- **OIDC**: ID token para el cliente (lo consume y lo tira), access token para la API (opaco
  para el cliente). Mandar el ID token a la API es el error nº1. Scope (lo que pide la app) vs
  claim (lo que afirma el token); `aud` impide reutilizar el token en otro servicio.
- **Edge authentication** y **phantom token**: fuera circula un token opaco, el gateway lo
  canjea por introspección (RFC 7662) por un JWT firmado interno.
- **BFF**: el SPA no guarda tokens en JS (XSS los roba); backend propio + cookie HttpOnly +
  Secure + SameSite.
- **JWT**: header/payload/firma. Base64URL no es cifrado. HS256 (simétrica) vs RS256/ES256
  (asimétricas). JWKS + `kid` para rotar.
- **Ataques**: `alg: none`; confusión de algoritmo (fijar el algoritmo esperado en el
  validador). El JWT no se revoca por diseño; lista de `jti` en Redis reintroduce estado.
- **Sender-constrained** (RFC 9449 DPoP en navegador, RFC 8705 mTLS backend a backend).

## Pendiente
- [ ] Diapositivas en [`diapositivas/`](diapositivas/)
- [ ] Guion teórico en [`teoria/`](teoria/)

Fuente: [briefing §2, Módulo 3](../../docs/curso-identidad-briefing.md).
