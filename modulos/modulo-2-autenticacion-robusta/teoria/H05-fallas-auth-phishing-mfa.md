# H5 — Fallas de la autenticación tradicional, phishing interactivo y MFA

**Módulo:** [2 — Autenticación robusta](../README.md) · **Formato:** Teoría · 60 min
**Lab del módulo:** [Lab 2 — WebAuthn sin backend](../laboratorio-2-webauthn/) (H7)
**Actividad/entregable (cronograma):** Análisis de vectores de ataque por ingeniería social.

## Objetivo de la hora
Diagnóstico crítico: por qué los factores clásicos y el MFA tradicional fallan frente a ataques
dirigidos. Es la base que justifica FIDO2 (H6).

## Contenidos
- **Por qué fallan los factores clásicos:**
  - **SMS** — *SIM swapping*.
  - **TOTP** — *phishable* en tiempo real vía proxy inverso (tipo **Evilginx**).
  - **Push** — *fatiga* (el usuario acepta por cansancio).
- **Patrón común:** todos son **un secreto que el usuario puede entregar a un tercero sin darse
  cuenta**. Ese es el fallo de raíz, no el factor concreto.
- **Bypass de MFA interactivo:** el atacante actúa de intermediario en tiempo real; el segundo
  factor no protege si se puede reenviar.

## Conexiones
- Esta hora es el "problema"; **H6 + Lab 2** son la "solución" (origin binding = no hay secreto que
  entregar).

## Preguntas para el aula
- [ ] (a desarrollar) Si el usuario teclea su TOTP en una web falsa, ¿qué factor ha fallado?

## Pendiente
- [ ] Desarrollar guion de aula / notas del instructor
- [ ] Preparar el análisis de vectores (SIM swap, proxy inverso, push fatigue)

Fuente: briefing §2 (Módulo 2); PDF cronograma H5.
