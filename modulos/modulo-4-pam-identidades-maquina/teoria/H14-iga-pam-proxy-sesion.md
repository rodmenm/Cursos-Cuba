# H14 — Cuentas críticas de administración, PAM y proxy de sesión

**Módulo:** [4 — PAM e identidades de máquina](../README.md) · **Formato:** Teoría · 60 min
**Lab del módulo:** [Lab 4 — Acceso efímero con Vault](../laboratorio-4-vault-efimero/) (H16)
**Actividad/entregable (cronograma):** Diseño de perfiles de cuentas administrativas.

## Objetivo de la hora
Entender por qué las cuentas de administración son el objetivo más valioso y qué disciplinas
(IGA, PAM) las protegen.

## Contenidos
- **IGA (Gobierno de Identidad):** certificación **periódica** de accesos; compensa el fallo de la
  **M** (Mover) del JML (Módulo 1). Problema real: *rubber stamping* (aprobar sin mirar).
- **PAM (Gestión de Accesos Privilegiados):**
  - **Bóveda:** nadie conoce la contraseña de root; se **rota al devolverla**.
  - **Proxy de sesión:** el admin conecta al proxy, que abre la sesión y la **graba**.
  - **Aislamiento:** el equipo del admin no toca directamente el sistema crítico.

## Conexiones
- IGA cierra el bucle del *privilege creep* del Módulo 1.
- La bóveda y la rotación son justo lo que automatiza el **Lab 4 (Vault)**.

## Preguntas para el aula
- [ ] (a desarrollar) ¿Qué gana una organización grabando la sesión además de rotando la clave?

## Pendiente
- [ ] Desarrollar guion de aula / notas del instructor
- [ ] Ejercicio: diseño de perfiles de cuentas administrativas

Fuente: briefing §2 (Módulo 4); PDF cronograma H14.
