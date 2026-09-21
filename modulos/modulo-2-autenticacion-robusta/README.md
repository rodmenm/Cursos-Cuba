# Módulo 2 — Autenticación robusta

## Estructura del módulo

| Carpeta | Contenido |
|---|---|
| [`teoria/`](teoria/) | Guion teórico y notas de aula. |
| [`diapositivas/`](diapositivas/) | Diapositivas del módulo (se generan más adelante). |
| [`recursos/`](recursos/) | RFCs, enlaces y bibliografía (WebAuthn L3, FIDO2/CTAP). |
| [`laboratorio-2-webauthn/`](laboratorio-2-webauthn/) | Lab 2: guion, materiales y entregable. |

## Contenidos

- **Por qué fallan los factores clásicos**: SMS (SIM swapping), TOTP (phishable vía proxy
  inverso tipo Evilginx), push (fatiga). Patrón: un secreto que el usuario puede entregar sin
  darse cuenta.
- **FIDO2** = WebAuthn (API del navegador) + CTAP (navegador ↔ autenticador). Registro: par de
  claves, la privada se queda dentro. Login: reto aleatorio firmado. Nunca viaja un secreto
  reutilizable.
- **Origin binding**: la resistencia al phishing viene de que el autenticador firma el origen,
  no de la biometría. En `banc0.com` no hay credencial que ofrecer.
- **Passkey sincronizada** (iCloud/Google, recuperable) vs **vinculada al dispositivo** (llave
  física, obligatoria en entornos regulados).
- **Step-up**: `acr_values` en la petición; se comprueba en los claims `acr` y `amr`.

## Pendiente
- [ ] Diapositivas en [`diapositivas/`](diapositivas/)
- [ ] Guion teórico en [`teoria/`](teoria/)

Fuente: [briefing §2, Módulo 2](../../docs/curso-identidad-briefing.md).
