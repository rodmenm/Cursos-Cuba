# H6 — Criptografía asimétrica, FIDO2, WebAuthn y passkeys

**Módulo:** [2 — Autenticación robusta](../README.md) · **Formato:** Teoría · 60 min
**Lab del módulo:** [Lab 2 — WebAuthn sin backend](../laboratorio-2-webauthn/) (H7)
**Actividad/entregable (cronograma):** Modelado de flujos de aserción criptográfica.

## Objetivo de la hora
Entender cómo FIDO2/WebAuthn elimina el secreto reutilizable y por qué eso, y no la biometría,
es lo que da resistencia al phishing.

## Contenidos
- **Criptografía asimétrica aplicada:** par de claves; la privada nunca sale del autenticador.
- **FIDO2 = WebAuthn + CTAP:**
  - **WebAuthn** — API del navegador (W3C).
  - **CTAP** (CTAP1/CTAP2) — protocolo navegador ↔ autenticador físico o local.
- **Flujo de aserción:**
  - *Registro*: se genera un par de claves nuevo; la privada se queda dentro.
  - *Login*: el servidor manda un **reto aleatorio** (*challenge*); el autenticador lo **firma**;
    se verifica con la pública. **Nunca viaja un secreto reutilizable.**
- **Origin binding:** el autenticador incluye el **origen** en lo que firma. En `banc0.com` no
  existe credencial que ofrecer → de ahí la resistencia al phishing. La biometría solo **desbloquea
  localmente**.
- **Passkeys:** sincronizada (iCloud/Google, recuperable) vs vinculada al dispositivo (llave
  física, no se copia, obligatoria en entornos regulados).
- **Step-up:** ver saldo pide menos que transferir → se solicita con `acr_values` y se comprueba en
  los claims `acr` y `amr`.

## Conexiones
- El *challenge* de esta hora se calcula a mano (SHA-256) en el **Lab 3** (PKCE), única vez que
  tocan cripto a mano.
- `acr`/`amr` y claims enlazan con OIDC (Módulo 3).

## Preguntas para el aula
- [ ] (a desarrollar) ¿Por qué un phishing no puede reusar una firma WebAuthn?

## Pendiente
- [ ] Desarrollar guion de aula / notas del instructor
- [ ] Preparar el diagrama de flujo de aserción (registro vs login)

Fuente: briefing §2 (Módulo 2); PDF cronograma H6.
