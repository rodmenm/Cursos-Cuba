# H15 — Acceso dinámico (JIT/JEA) e identidades no humanas (NHI)

**Módulo:** [4 — PAM e identidades de máquina](../README.md) · **Formato:** Teoría · 60 min
**Lab del módulo:** [Lab 4 — Acceso efímero con Vault](../laboratorio-4-vault-efimero/) (H16)
**Actividad/entregable (cronograma):** Evaluación de riesgos en secretos hardcodeados.

## Objetivo de la hora
Entender cómo se eliminan los privilegios permanentes (standing privileges) y cómo se gobiernan
las identidades de máquina.

## Contenidos
- **JIT (Just-in-Time):** elimina la **permanencia** — pides acceso, se aprueba, **expira**.
- **JEA (Just-Enough-Access):** elimina el **exceso de alcance** — tres comandos, no una shell.
- Se aplican **juntos**: acceso mínimo y efímero.
- **NHI (identidades no humanas):** tokens de CI/CD, claves de API, certificados de servicio. Son
  **mayoría** frente a las humanas, y suelen estar **sin dueño, sin rotación y hardcodeadas**.
  - **Solución operativa:** secretos **dinámicos** con **TTL corto** (no hay secreto persistente
    que robar o rotar).

## Conexiones
- Es la teoría exacta del **Lab 4 (Vault)**: credenciales de BD generadas al vuelo con TTL de 60 s.
- Revocación vs expiración = mismo debate que el JWT del Módulo 3 (H12).

## Preguntas para el aula
- [ ] (a desarrollar) ¿Por qué hay más identidades de máquina que humanas, y por qué importa?

## Pendiente
- [ ] Desarrollar guion de aula / notas del instructor
- [ ] Ejercicio: evaluación de riesgos de secretos hardcodeados en un repo/CI

Fuente: briefing §2 (Módulo 4); PDF cronograma H15.
