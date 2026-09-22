# Lab 3.2 — Gateway, autenticación en el borde y cabeceras inyectadas

**Módulo:** [3 — Federación y microservicios](../README.md).
**Infra:** [`docker-compose.yml`](docker-compose.yml) propio (Keycloak, copia de los labs
anteriores + `oauth2-proxy` + `traefik/whoami`). Autocontenido, mismo patrón que el resto.
**Materiales/entregables:** [`materiales/`](materiales/).
**Duración:** 60 min (10 arranque · 25 guiado · 10 romperlo · 10 entregable · 5 colchón).

## Qué se construye y por qué

En el Lab 3.1 la propia SPA hacía el baile OAuth y el navegador llegaba a ver el token — la teoría
del Módulo 3 dice que eso no se hace así en producción. Aquí se monta la forma correcta: un
**gateway** (`oauth2-proxy`) hace el baile OAuth por detrás, y el servicio protegido (`whoami`) no
tiene ni una línea de código de autenticación — solo confía en las cabeceras que le llegan.

**Decisión de diseño:** se descarta un API Gateway completo tipo APISIX (demasiado que aprender
para lo que aporta aquí: rutas, upstreams, plugins, admin API). `oauth2-proxy` es un binario con un
solo propósito y configuración plana — mejor ajuste para el tiempo disponible.

## Aviso importante — esto cambia cómo se accede a Keycloak desde ahora

Hasta ahora Keycloak se usaba en `http://localhost:8080`. A partir de este lab hay un **segundo
contenedor** (`oauth2-proxy`) que también necesita hablar con Keycloak, y tiene que ver **el mismo
issuer** que ve el navegador — si no, los tokens se rechazan por "issuer mismatch" (el fallo más
común al montar este tipo de infraestructura). La solución: fijar `KC_HOSTNAME=keycloak` en
Keycloak, y hacer que **tanto el navegador como los contenedores** lo resuelvan igual.

**Esto exige un paso nuevo, antes de arrancar nada:** añadir una entrada al fichero *hosts* del
sistema para que `keycloak` resuelva a `127.0.0.1` desde el propio navegador (Docker ya resuelve
`keycloak` automáticamente entre contenedores, pero el navegador vive fuera de esa red).

- **Windows:** editar `C:\Windows\System32\drivers\etc\hosts` (como administrador) y añadir:
  ```
  127.0.0.1 keycloak
  ```
- **macOS/Linux:** editar `/etc/hosts` (con `sudo`) y añadir la misma línea.

A partir de aquí, **todo se accede como `http://keycloak:8080`**, no `http://localhost:8080` —
incluida la propia consola de administración.

> **Efecto colateral a tener en cuenta:** esto cambia el Keycloak compartido por todos los labs
> anteriores. Si después de hacer este lab quieres volver a hacer una demo del Lab 1, 2 o 3.1,
> tendrás que seguir usando `keycloak:8080` en vez de `localhost:8080` a partir de ahora — no hay
> vuelta atrás sin quitar `KC_HOSTNAME` y reiniciar el contenedor. Anotado en Pendiente.

## Prerrequisitos

- Haber completado el Lab 1 (realm `curso`, usuario `diego`).
- Entrada en el fichero hosts añadida (ver arriba).
- `openssl` disponible en terminal (para generar el cookie secret).

## Arranque (10 min)

```bash
cp .env.example .env
```

Generar el cookie secret y pegarlo en `.env` (variable `OAUTH2_PROXY_COOKIE_SECRET`):

```bash
openssl rand -base64 32
```

Arrancar primero solo Keycloak y whoami — `oauth2-proxy` necesita un client-secret que todavía no
existe, se añade en el Guiado:

```bash
docker compose up -d keycloak whoami
```

> Al añadir `KC_HOSTNAME=keycloak`, Docker puede recrear el contenedor de Keycloak si ya existía de
> un lab anterior (detecta que la configuración cambió). Es normal — el realm y los usuarios siguen
> intactos porque viven en el volumen `keycloak_data`, no en el contenedor.

Confirmar acceso: `http://keycloak:8080/realms/curso/account/` (con la entrada de hosts ya puesta).

## Guiado (25 min)

1. **Crear el cliente confidencial:** consola admin (`http://keycloak:8080/admin/master/console/`)
   → realm `curso` → **Clients** → **Create client**.
   - General settings: Client ID = `gateway` → Next.
   - Capability config: **Client authentication = ON** (confidencial, con secreto), **Standard
     flow = ON**, resto OFF → Next.
   - Login settings: **Valid redirect URIs** = `http://localhost:8082/oauth2/callback` → Save.

   > El navegador llega al gateway por `localhost:8082` (no por `keycloak:...`) — esa parte no
   > cambia, solo cambió cómo se llega a **Keycloak**, no cómo se llega al propio gateway.

2. **Copiar el secreto:** pestaña **Credentials** del cliente `gateway` → copiar **Client secret**
   → pegarlo en `.env`, variable `OAUTH2_PROXY_CLIENT_SECRET`.
3. **Arrancar el gateway:**
   ```bash
   docker compose up -d
   ```
4. **Probar sin sesión:** abrir `http://localhost:8082/` en una ventana privada → debe devolver
   **401** o redirigir a login de Keycloak (dependiendo del navegador, puede auto-redirigir).
5. **Autenticarse:** completar el login como `diego`. Tras volver, `whoami` debe responder **200**
   con un volcado de todas las cabeceras HTTP que recibió.
6. **Localizar las cabeceras inyectadas** en ese volcado: `X-Forwarded-User`,
   `X-Forwarded-Email`, `X-Forwarded-Preferred-Username`, y (por `--pass-authorization-header`) una
   cabecera `Authorization: Bearer ...` con el JWT completo.

## Momento clave

El alumno no ha puesto ninguna cabecera — las ha inyectado el gateway. `whoami` no sabe qué es
OAuth, un realm o un token; solo ve cabeceras HTTP normales, como cualquier backend. Toda la
complejidad de autenticación se quedó en el borde, no se propagó al servicio.

## Romperlo (10 min)

Con `oauth2-proxy`, el navegador nunca tiene el JWT suelto para manipularlo directamente — lo que
tiene es una **cookie de sesión** cifrada/firmada por el propio `oauth2-proxy`. El romperlo ataca
eso, que es lo que el alumno realmente controla en esta arquitectura:

1. **Manipular la cookie:** DevTools → **Application** → **Cookies** → localizar la cookie de
   `oauth2-proxy` (nombre por defecto `_oauth2_proxy`) → cambiar un carácter cualquiera de su valor
   → recargar `http://localhost:8082/` → debe volver a dar 401. La cookie está protegida
   criptográficamente, no es un simple identificador que se pueda falsificar a mano.
2. **Apagar el proveedor de identidad:**
   ```bash
   docker compose stop keycloak
   ```
   Abrir una **ventana privada nueva** (sin sesión previa) y volver a `http://localhost:8082/` →
   falla, no se puede ni empezar el login. El gateway depende por completo de que Keycloak esté
   vivo para cualquiera que todavía no tenga sesión — es el argumento a favor de que Keycloak sea
   un servicio de alta disponibilidad en producción, no un contenedor suelto.
   ```bash
   docker compose start keycloak
   ```

> **Diferencia con el guion original del briefing:** la idea de "editar el JWT en un decodificador"
> encaja con el Lab 3.1 (donde el navegador sí tiene el token suelto), pero no aquí — aquí lo que
> el alumno controla de verdad es la cookie, no el JWT. Se ha ajustado el romperlo para que ataque
> lo que realmente es manipulable en esta arquitectura concreta.

## Entregable (10 min)

Las tres respuestas (sin sesión / con sesión válida / cookie manipulada) + la cabecera inyectada
señalada → [`materiales/`](materiales/).

## Colchón (5 min)

Atasco típico: alguien olvida la entrada en el fichero hosts y sigue probando con `localhost:8080`
— Keycloak responde, pero con un issuer distinto al que espera `oauth2-proxy`, y el login falla de
forma confusa. Revisar el fichero hosts antes de re-explicar nada.

## Preguntas para el aula

| Momento | Pregunta | Respuesta |
|---|---|---|
| Aviso inicial | ¿Por qué hace falta que Keycloak y el navegador vean el mismo `issuer`? | El token lleva el `iss` incrustado. `oauth2-proxy` compara ese valor con la URL de emisor que tiene configurada; si no coinciden byte a byte, lo rechaza aunque el token sea legítimo. Es una protección, no un capricho: evita que un token emitido para un dominio sirva en otro. |
| Guiado, paso 1 | ¿Por qué este cliente es confidencial y el del Lab 3.1 era público? | Este cliente vive server-side, dentro del contenedor de `oauth2-proxy` — nadie externo puede leer su código ni su configuración. Un secreto ahí sí protege algo de verdad, al contrario que en una SPA. |
| Momento clave | `whoami` recibe la identidad del usuario sin saber nada de OAuth — ¿qué pasaría si `whoami` fuera 50 microservicios distintos? | Ninguno de los 50 tendría que implementar login. Es la razón de ser de este patrón: centralizar la autenticación en un solo punto (el borde) en vez de repetirla en cada servicio. |
| Romperlo | ¿Por qué apagar Keycloak no afecta a alguien que ya tenía sesión iniciada, pero sí a alguien nuevo? | La cookie ya validada se verifica localmente (firma/cifrado), sin llamar a Keycloak en cada petición. Solo hace falta contactar a Keycloak para un login nuevo o para renovar un token caducado — por eso el efecto de apagarlo tarda en notarse en sesiones ya abiertas. |

## Pendiente
- [ ] Verificar en frío (con Docker real) el comportamiento exacto de "sin sesión" en el paso 4 —
      si oauth2-proxy devuelve 401 en JSON o redirige directo a Keycloak depende de cabeceras del
      navegador; ajustar el guion según lo que se vea.
- [ ] Decidir qué hacer con Labs 1/2/3.1 si se quieren re-demostrar después de este lab, dado que
      `KC_HOSTNAME=keycloak` ya no permite volver a `localhost:8080` sin reiniciar el contenedor sin
      esa variable.
- [ ] Probar el timing real del romperlo de la cookie manipulada — depende de qué tan estricta sea
      la validación de `oauth2-proxy` ante un valor corrupto vs. simplemente no reconocido.

Fuente: [briefing §3, Lab 3.2](../../../docs/curso-identidad-briefing.md).
