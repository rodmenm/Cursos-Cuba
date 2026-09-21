# Módulo 1 — Zero Trust y ciclo de vida de la identidad

## Estructura del módulo

| Carpeta | Contenido |
|---|---|
| [`teoria/`](teoria/) | Guion teórico y notas de aula. |
| [`diapositivas/`](diapositivas/) | Diapositivas del módulo (se generan más adelante). |
| [`recursos/`](recursos/) | RFCs, enlaces y bibliografía (NIST SP 800-207). |
| [`laboratorio-1-keycloak-realms-rbac/`](laboratorio-1-keycloak-realms-rbac/) | Lab 1: guion, materiales y entregable. |

## Contenidos

- **Zero Trust**: verificar explícitamente, asumir la brecha, mínimo privilegio. La red deja
  de ser una credencial. NIST SP 800-207. Vocabulario PDP (decide) / PEP (ejecuta, el gateway).
  Señales: dispositivo gestionado, geolocalización, hora, comportamiento.
- **IAAA**: identificación, autenticación, autorización, accounting. Analogía del hotel (DNI
  autentica, tarjeta de habitación autoriza; caducan distinto).
- **Atributos**: inherentes, acumulados, asignados. Quién los cambia y cuánto duran.
- **JML**: Joiner (alta desde RRHH), Mover (*privilege creep*), Leaver (desaprovisionamiento;
  el contratista externo que no aparece en la baja). Métrica: tiempo baja → cierre.
- **Modelos de autorización**: RBAC (role explosion), ABAC (flexible, difícil de auditar),
  PBAC (políticas externalizadas). En la práctica se combinan.

## Pendiente
- [ ] Diapositivas en [`diapositivas/`](diapositivas/)
- [ ] Guion teórico en [`teoria/`](teoria/)

Fuente: [briefing §2, Módulo 1](../../docs/curso-identidad-briefing.md).
