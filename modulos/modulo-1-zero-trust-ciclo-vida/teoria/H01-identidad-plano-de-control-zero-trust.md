# H1 — Identidad como plano de control y Zero Trust

**Módulo:** [1 — Zero Trust y ciclo de vida](../README.md) · **Formato:** Teoría · 60 min
**Lab del módulo:** [Lab 1 — Keycloak, realms y RBAC](../laboratorio-1-keycloak-realms-rbac/) (H4)
**Actividad/entregable (cronograma):** Análisis conceptual de señales condicionales.

## Objetivo de la hora
Que el alumno entienda que, en arquitecturas modernas, **la identidad es el plano de control
primario** y sustituye a la seguridad perimetral basada en red.

## Contenidos
- **El fin del perímetro.** La red deja de ser una credencial: estar "dentro" ya no autoriza nada.
- **Zero Trust — tres principios:** verificar explícitamente, asumir la brecha, mínimo privilegio.
  Referencia: **NIST SP 800-207**.
- **Arquitectura PDP/PEP:** el PDP (Policy Decision Point) decide, el PEP (Policy Enforcement
  Point) ejecuta — normalmente el gateway. Se retoma literalmente en el Lab 4 (gateway/borde).
- **Señales de contexto continuo:** dispositivo gestionado, geolocalización, hora, comportamiento,
  telemetría de riesgo. La decisión de acceso se recalcula, no se concede "para siempre".

## Conexiones
- Las *señales condicionales* de esta hora son la base del **step-up** del Módulo 2 (`acr_values`).
- El PDP/PEP reaparece como mecanismo real en el **Lab 4** (oauth2-proxy = PEP).

## Preguntas para el aula
- [ ] (a desarrollar) ¿Qué es una "credencial" si la red ya no lo es?

## Pendiente
- [ ] Desarrollar guion de aula / notas del instructor
- [ ] Definir el ejercicio de "análisis de señales condicionales"

Fuente: briefing §2 (Módulo 1); PDF cronograma H1.
