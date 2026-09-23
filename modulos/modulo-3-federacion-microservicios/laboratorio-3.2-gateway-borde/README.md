# Lab 3.2 — Gateway, autenticación en el borde y cabeceras inyectadas

**Módulo:** [3 — Federación y microservicios](../README.md).
**Infra:** [`docker-compose.yml`](docker-compose.yml) propio e independiente (no comparte
Keycloak con los Labs 1, 2 y 3.1 — este lab crea su propio realm desde cero en el Guiado).
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

## Por qué solo hay un puerto público (8082) — ni Keycloak se publica

Fíjate en el `docker-compose.yml`: el servicio `keycloak` **no tiene `ports:`**. Solo es
alcanzable desde dentro de la red de Docker — no desde tu navegador directamente, no desde
`localhost:8080`. El único puerto publicado al host es el `8082` de `oauth2-proxy`.

Esto es deliberado y refleja cómo se monta en producción: `oauth2-proxy` **ya es un reverse
proxy** (su trabajo es reenviar peticiones a un "upstream" después de comprobar la sesión), así
que en vez de meter una pieza nueva delante de todo, se le añade Keycloak como uno más de sus
upstreams:

```
--upstream=http://whoami:80/            # el servicio protegido
--upstream=http://keycloak:8080/realms/     # login, token, etc. — Keycloak habla con el navegador
--upstream=http://keycloak:8080/resources/  # CSS/JS del tema de login
--upstream=http://keycloak:8080/admin/      # consola de administración
```

Las tres rutas de Keycloak necesitan además `--skip-auth-route`: no pueden exigir una sesión de
`oauth2-proxy` que todavía no existe — son justo las rutas que sirven para crear esa sesión (o
para administrar Keycloak con su propio login, que es independiente del de este gateway).

**El matiz que hace falta para que esto funcione:** `oauth2-proxy` necesita hablar con Keycloak de
dos formas distintas a la vez:
1. Mandar al **navegador** a la pantalla de login → tiene que ser una URL que el navegador pueda
   alcanzar: `http://localhost:8082/realms/curso/...` (el mismo puerto público de siempre).
2. Canjear el `code` por un token, y descargar las claves para verificar la firma → esto lo hace
   **el propio contenedor de `oauth2-proxy`**, así que puede (y debe) ir por la red interna de
   Docker: `http://keycloak:8080/realms/curso/...`.

Por eso el `docker-compose.yml` desactiva el descubrimiento automático de OIDC
(`--skip-oidc-discovery=true`) y da cada endpoint a mano: `--login-url` con la URL pública (1),
`--redeem-url`/`--oidc-jwks-url`/`--profile-url` con la URL interna (2). Sin este reparto,
`oauth2-proxy` intentaría hacer las llamadas de tipo (2) contra `http://localhost:8082`, que desde
dentro de su propio contenedor no es ningún sitio (`localhost` ahí es él mismo).

`KC_HOSTNAME=http://localhost:8082` en Keycloak asegura que el `iss` que graba en cada token, y las
URLs que genera para su propia pantalla de login, sean la dirección pública — coherente con lo que
`oauth2-proxy` espera validar.

> No hace falta tocar el fichero `hosts` del sistema en ningún paso de este lab. El navegador nunca
> habla con Keycloak directamente — solo con `oauth2-proxy`, en el único puerto que existe.

## Prerrequisitos

- `openssl` disponible en terminal (para generar el cookie secret).
- Puerto `8082` libre.

No hace falta haber hecho ningún lab anterior — este realm (`curso`) se crea desde cero, dentro de
este mismo lab, en el Guiado.

## Arranque (10 min)

```bash
cp .env.example .env
```

Generar el cookie secret y pegarlo en `.env` (variable `OAUTH2_PROXY_COOKIE_SECRET`) — tiene que
ser base64 **URL-safe**, no el que da `openssl` por defecto:

```bash
openssl rand -base64 32 | tr '+/' '-_'
```

Levantar todo el stack de una vez (Keycloak no tiene puerto propio, así que `oauth2-proxy` tiene
que estar arriba desde el principio para poder llegar a la consola de administración):

```bash
docker compose up -d
```

Confirmar que arrancó: `http://localhost:8082/admin/master/console/` debe mostrar la pantalla de
login de la consola de Keycloak. Si da timeout, espera al healthcheck (`docker compose ps`, columna
`STATUS`, hasta que Keycloak diga `healthy` — puede tardar 30-40 segundos la primera vez).

## Guiado (25 min)

1. **Entrar a la consola de administración:** `http://localhost:8082/admin/master/console/` →
   usuario/contraseña de `.env` (`admin` / `admin` por defecto).

   > Fíjate que esto funciona **sin haber configurado nada todavía del gateway** — la ruta
   > `/admin/*` está eximida de pedir sesión de `oauth2-proxy` (`--skip-auth-route`). La consola de
   > Keycloak tiene su propio login, completamente aparte del que vamos a montar para `whoami`.

2. **Crear el realm:** desplegable arriba a la izquierda (`master`) → **Create realm** → nombre
   `curso` → **Create**.

3. **Crear el cliente confidencial:** dentro del realm `curso` → **Clients** → **Create client**.
   - General settings: Client ID = `gateway` → Next.
   - Capability config: **Client authentication = ON** (confidencial, con secreto), **Standard
     flow = ON**, resto OFF → Next.
   - Login settings: **Valid redirect URIs** = `http://localhost:8082/oauth2/callback` → Save.

   > El navegador llega al gateway por `localhost:8082` — el único sitio al que llega directamente
   > en todo este lab.

4. **Copiar el secreto:** pestaña **Credentials** del cliente `gateway` → copiar **Client secret**
   → pegarlo en `.env`, variable `OAUTH2_PROXY_CLIENT_SECRET` (sustituyendo el valor
   `placeholder-temporal`).

5. **Crear el usuario:** **Users** → **Create user** → username `diego` → Create. Pestaña
   **Credentials** → **Set password** → algo simple, `Temporary = Off`. Pestaña **Details** →
   activar **Email verified** → Save (si no, Keycloak pedirá completar el perfil en el primer
   login y añade un paso extra que no aporta nada al lab).

6. **Reiniciar el gateway** para que recoja el secreto real:
   ```bash
   docker compose up -d oauth2-proxy
   ```

7. **Probar sin sesión:** abrir `http://localhost:8082/` en una ventana privada → debe devolver
   **401** o redirigir a login de Keycloak (dependiendo del navegador, puede auto-redirigir).

8. **Autenticarse:** completar el login como `diego`. Tras volver, `whoami` debe responder **200**
   con un volcado de todas las cabeceras HTTP que recibió.

9. **Localizar las cabeceras inyectadas** en ese volcado: `X-Forwarded-User`,
   `X-Forwarded-Email`, `X-Forwarded-Preferred-Username`, y (por `--pass-authorization-header`) una
   cabecera `Authorization: Bearer ...` con el JWT completo.

## Momento clave

El alumno no ha puesto ninguna cabecera — las ha inyectado el gateway. `whoami` no sabe qué es
OAuth, un realm o un token; solo ve cabeceras HTTP normales, como cualquier backend. Toda la
complejidad de autenticación se quedó en el borde, no se propagó al servicio. Y de paso: todo esto
ha pasado sin que Keycloak tuviera nunca un puerto propio abierto al exterior.

## Romperlo (10 min)

Con `oauth2-proxy`, el navegador nunca tiene el JWT suelto para manipularlo directamente — lo que
tiene es una **cookie de sesión** cifrada/firmada por el propio `oauth2-proxy`. El romperlo ataca
eso, que es lo que el alumno realmente controla en esta arquitectura:

1. **Manipular la cookie:** DevTools → **Application** → **Cookies** → localizar la cookie de
   `oauth2-proxy` (nombre por defecto `_oauth2_proxy`) → cambiar un carácter cualquiera de su valor
   → recargar `http://localhost:8082/` → vuelve a tratarte como si no tuvieras sesión (401 o
   redirección a login, igual que en el paso 7 del Guiado — depende de las cabeceras que mande el
   navegador). La cookie está protegida criptográficamente, no es un simple identificador que se
   pueda falsificar a mano.
2. **Apagar el proveedor de identidad:**
   ```bash
   docker compose stop keycloak
   ```
   Abrir una **ventana privada nueva** (sin sesión previa) y volver a `http://localhost:8082/` →
   redirige hacia el login como siempre, pero al llegar ahí (`/realms/...`) da **502**: esa ruta la
   sirve `oauth2-proxy` reenviando a Keycloak, y Keycloak ya no está. El gateway depende por
   completo de que Keycloak esté vivo para cualquiera que todavía no tenga sesión — es el argumento
   a favor de que Keycloak sea un servicio de alta disponibilidad en producción, no un contenedor
   suelto.
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

Atascos típicos:
- Olvidar el paso 6 (reiniciar `oauth2-proxy` tras copiar el secreto real) — el login falla con un
  error de credenciales de cliente porque sigue usando `placeholder-temporal`.
- Pegar el cookie secret tal cual sale de `openssl rand -base64 32` sin el `tr '+/' '-_'` — si le
  toca un `+` o una `/`, `oauth2-proxy` no arranca (`cookie_secret must be 16, 24, or 32 bytes`,
  aunque el valor "parezca" de 32 bytes).
- No esperar al healthcheck de Keycloak antes de darlo por caído — la primera vez tarda 30-40s.

## Preguntas para el aula

| Momento | Pregunta | Respuesta |
|---|---|---|
| Aviso inicial | Si Keycloak no tiene ningún puerto publicado, ¿cómo llega el navegador a su pantalla de login? | No llega directo: `oauth2-proxy` lo tiene registrado como un `upstream` más, en las rutas `/realms`, `/resources` y `/admin`. El navegador siempre habla con `oauth2-proxy` (el único puerto que existe); es `oauth2-proxy` quien reenvía por dentro, por la red de Docker, a Keycloak. |
| Guiado, paso 3 | ¿Por qué este cliente es confidencial y el del Lab 3.1 era público? | Este cliente vive server-side, dentro del contenedor de `oauth2-proxy` — nadie externo puede leer su código ni su configuración. Un secreto ahí sí protege algo de verdad, al contrario que en una SPA. |
| Momento clave | `whoami` recibe la identidad del usuario sin saber nada de OAuth — ¿qué pasaría si `whoami` fuera 50 microservicios distintos? | Ninguno de los 50 tendría que implementar login. Es la razón de ser de este patrón: centralizar la autenticación en un solo punto (el borde) en vez de repetirla en cada servicio. |
| Romperlo | ¿Por qué apagar Keycloak no afecta a alguien que ya tenía sesión iniciada, pero sí a alguien nuevo? | La cookie ya validada se verifica localmente (firma/cifrado), sin llamar a Keycloak en cada petición. Solo hace falta contactar a Keycloak para un login nuevo o para renovar un token caducado — por eso el efecto de apagarlo tarda en notarse en sesiones ya abiertas. |

## Pendiente
- [ ] Decidir si merece la pena, en algún momento del curso, mostrar en pizarra la versión anterior
      de este lab (Keycloak con puerto propio + hosts hack) como contraste explícito de "cómo NO
      hace falta hacerlo" — puede ser una diapositiva de más, no imprescindible.

Fuente: [briefing §3, Lab 3.2](../../../docs/curso-identidad-briefing.md).
