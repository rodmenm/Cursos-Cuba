# Infraestructura (transversal)

**Un único `docker-compose.yml` para todo el curso.** Keycloak se levanta en el Lab 1 y se
reutiliza en el 2, 3 y 4. Cada setup nuevo son 30 minutos perdidos y tres alumnos descolgados.

Esta carpeta contiene **solo lo compartido entre labs**. La configuración específica de cada lab
vive dentro de su módulo, en `modulos/modulo-N-.../laboratorio-N-.../config/`. El compose de aquí
la referencia por ruta relativa.

## Contenido

| Ruta | Uso |
|---|---|
| `docker-compose.yml` | Único, con todos los servicios y tags fijos. |
| [`realms/`](realms/) | Realm(s) de Keycloak exportados, montados en `/opt/keycloak/data/import`. Compartido por los labs 1–4. |
| `.env.example` | Secretos de ejemplo (cookie-secret, client-secret, token root de Vault). |

## Dónde está la config de cada lab

| Lab | Config |
|---|---|
| 3 (SPA/PKCE) | `modulos/modulo-3-federacion-microservicios/laboratorio-3-spa-pkce/config/` |
| 4 (gateway) | `modulos/modulo-3-federacion-microservicios/laboratorio-4-gateway-borde/config/` |
| 5 (Vault) | `modulos/modulo-4-pam-identidades-maquina/laboratorio-5-vault-efimero/config/` |
| 6 (SD-JWT) | `modulos/modulo-5-identidad-descentralizada/laboratorio-6-sdjwt-presentacion-selectiva/config/` |

## Reglas (checklist §4 del briefing)

1. Un repo, un compose, un realm exportado. Todo sobre la misma instancia de Keycloak.
2. **Tags de imagen fijos.** Nada de `:latest`: la consola de Keycloak cambia entre versiones y
   las capturas y el guion dejan de coincidir.
3. Resolver el issuer antes de clase (ver aviso del Lab 4: `KC_HOSTNAME` / `/etc/hosts`).
4. Plan sin red: imágenes precargadas o registry local.

## Pendiente
- [ ] `docker-compose.yml` con todos los servicios y tags fijos
- [ ] `.env.example`
