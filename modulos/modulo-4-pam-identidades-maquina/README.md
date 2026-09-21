# Módulo 4 — PAM e identidades de máquina

Módulo abstracto para gente sin contexto organizativo: se recorta de 3h a 2h y la hora va al
módulo 3.

## Estructura del módulo

| Carpeta | Contenido |
|---|---|
| [`teoria/`](teoria/) | Guion teórico y notas de aula. |
| [`diapositivas/`](diapositivas/) | Diapositivas del módulo (se generan más adelante). |
| [`recursos/`](recursos/) | Enlaces y bibliografía (IGA, PAM, JIT/JEA, NHI). |
| [`laboratorio-5-vault-efimero/`](laboratorio-5-vault-efimero/) | Lab 5: acceso efímero con Vault. |

## Contenidos

- **IGA**: certificación periódica de accesos; compensa el fallo de la M del JML. Problema real:
  *rubber stamping*.
- **PAM**: bóveda (nadie conoce root, se rota al devolver), proxy de sesión (graba), aislamiento
  del equipo del admin.
- **JIT** (elimina la permanencia: pides, se aprueba, expira) + **JEA** (elimina el exceso de
  alcance: tres comandos, no una shell). Se aplican juntos.
- **NHI**: tokens de CI/CD, claves de API, certificados de servicio. Mayoría frente a las
  humanas, sin dueño, sin rotación, hardcodeadas. Solución: secretos dinámicos con TTL corto.

## Nota de diseño

El lab de PIM (Entra ID) del programa original se sustituye por Vault, porque PIM es nube
(tenant + licencia P2) y no hay contenedor.

## Pendiente
- [ ] Diapositivas en [`diapositivas/`](diapositivas/)
- [ ] Guion teórico en [`teoria/`](teoria/)

Fuente: [briefing §2, Módulo 4](../../docs/curso-identidad-briefing.md).
