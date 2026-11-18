# H18 — eIDAS 2.0, EUDI Wallet y atestaciones (QEAA)

**Módulo:** [5 — Identidad descentralizada](../README.md) · **Formato:** Teoría · 60 min
**Lab del módulo:** [Lab 5 — SD-JWT y presentación selectiva](../laboratorio-5-sdjwt-presentacion-selectiva/) (H20)
**Actividad/entregable (cronograma):** Casos de uso del EUDI Wallet en sectores regulados.

## Objetivo de la hora
Presentar el marco europeo y, sobre todo, dejar claro que **es un linaje distinto** del de W3C/SSI
(H17): convergen en el protocolo, no en el modelo de confianza.

## Contenidos
- **eIDAS 2.0** (Reglamento UE 2024/1183) y la obligación de desplegar la **EUDI Wallet** (Cartera
  de Identidad Digital de la UE).
- **Modelo de confianza europeo:** cadena **X.509 sobre trust lists** — **no usa DIDs**.
- **Formatos:** **SD-JWT VC** e **ISO mdoc** (no VCDM 2.0 con Data Integrity Proofs).
- **QEAA:** atestaciones electrónicas cualificadas de atributos.
- **Los dos linajes, en una frase (corrección clave al programa original):**
  - W3C/SSI → DIDs + VCDM 2.0.
  - Europeo/EUDI → X.509 + trust lists + SD-JWT VC / mdoc.
  - **Convergen solo en el protocolo (OpenID4VP)** (H19), no en el modelo de confianza.

## Conexiones
- SD-JWT VC es el formato que se emite y presenta en el **Lab 5**.
- Enlaza con los entornos regulados (passkey vinculada al dispositivo, Módulo 2).

## Preguntas para el aula
- [ ] (a desarrollar) ¿En qué se parecen y en qué NO el modelo W3C y el europeo?

## Pendiente
- [ ] Desarrollar guion de aula / notas del instructor
- [ ] Ejercicio: casos de uso del EUDI Wallet en sectores regulados

Fuente: briefing §1 y §2 (Módulo 5); PDF cronograma H18.
