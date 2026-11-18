# H3 — Ciclo de vida del usuario (JML) y modelos de autorización

**Módulo:** [1 — Zero Trust y ciclo de vida](../README.md) · **Formato:** Teoría · 60 min
**Lab del módulo:** [Lab 1 — Keycloak, realms y RBAC](../laboratorio-1-keycloak-realms-rbac/) (H4)
**Actividad/entregable (cronograma):** Ejercicios de modelado de matrices de acceso.

## Objetivo de la hora
Entender el ciclo de vida de una identidad (JML) y saber elegir/combinar los modelos de
autorización (RBAC, ABAC, PBAC).

## Contenidos
- **JML — Joiner / Mover / Leaver:**
  - *Joiner*: alta desde RRHH (fuente de verdad del aprovisionamiento).
  - *Mover*: el punto débil — permisos que se **suman y no se restan** (*privilege creep*).
  - *Leaver*: desaprovisionamiento; caso peligroso = el contratista externo que no aparece en la
    baja de RRHH (cuentas huérfanas / *dormant*). Métrica: tiempo entre baja efectiva y cierre.
- **Modelos de autorización:**
  - **RBAC** — permisos por rol; audita bien; *role explosion* cuando hay muchas excepciones.
  - **ABAC** — decisión calculada con atributos de sujeto, recurso, acción y entorno; flexible
    pero difícil de auditar.
  - **PBAC** — políticas declarativas externalizadas.
  - En la práctica **se combinan**.

## Conexiones
- JML/Mover → la **certificación de accesos (IGA)** del Módulo 4 existe para compensar su fallo.
- RBAC jerárquico se implementa tal cual en el **Lab 1** (roles compuestos, herencia por grupo).
- RBAC aditivo (no hay "deny") vs ABAC/PBAC con precedencia → matiz que cierra el Lab 1.

## Preguntas para el aula
- [ ] (a desarrollar) ¿Por qué el *Mover* es más peligroso que el *Leaver*?

## Pendiente
- [ ] Desarrollar guion de aula / notas del instructor
- [ ] Preparar el ejercicio de modelado de matrices de acceso (RBAC → ABAC)

Fuente: briefing §2 (Módulo 1); PDF cronograma H3.
