# Laboratorio 3.2 — Gateway y autenticación en el borde

> **Enunciado de práctica.** Trabaja siguiendo los pasos en orden; al final tienes que entregar lo
> que se indica en el último apartado. Tiempo estimado: unos 60 minutos.

## ¿Qué vas a hacer?

En el Laboratorio 3.1 la propia aplicación hacía el baile OAuth y el navegador llegaba a ver el token.
Aquí montas la **forma correcta**: un **gateway** (`oauth2-proxy`) hace todo el OAuth por detrás, y el
servicio protegido (`whoami`) **no tiene ni una línea de código de autenticación** — solo lee las
cabeceras que el gateway le inyecta. Vas a comprobar que esas cabeceras aparecen sin que tú las pongas.

## Antes de empezar necesitas

- `openssl` disponible en la terminal.
- Puerto **8082** libre.
- **No** necesitas los laboratorios anteriores: este crea su propio realm desde cero.

## Una cosa rara (y a propósito) de esta práctica

Mira el `docker-compose.yml`: el servicio `keycloak` **no tiene `ports:`**. Es decir, tu navegador
**no puede** hablar con Keycloak directamente — no existe `localhost:8080` aquí. El único puerto
público es el **8082**, el del gateway. Todo pasa por el gateway, igual que en producción.

## Apartados

1. **Preparación** (generar el cookie secret y levantar el stack).
2. **Configurar Keycloak** a través del gateway (realm, cliente confidencial, usuario).
3. **Probar sin sesión y con sesión** (401 → 200).
4. **Encontrar las cabeceras inyectadas.**
5. **Pruébalo** y **qué entregar.**

---

## 1. Preparación

```bash
cp .env.example .env
```

Genera el **cookie secret** y pégalo en `.env` (variable `OAUTH2_PROXY_COOKIE_SECRET`). Tiene que ser
base64 **URL-safe**, por eso el `tr`:

```bash
openssl rand -base64 32 | tr '+/' '-_'
```

Levanta todo el stack:

```bash
docker compose up -d
```

Confirma que arrancó: `http://localhost:8082/admin/master/console/` debe mostrar la pantalla de login
de la consola de Keycloak. Si da timeout, espera (`docker compose ps`, hasta que Keycloak diga
`healthy`; la primera vez tarda 30-40 s).

> 🧠 **Pregunta.** Si Keycloak no tiene ningún puerto publicado, ¿cómo llega tu navegador a su
> pantalla de login?
>
> <details><summary>Ver respuesta</summary>
> No llega directo. `oauth2-proxy` tiene a Keycloak registrado como un `upstream` suyo en las rutas
> `/realms`, `/resources` y `/admin`. Tu navegador siempre habla con el gateway (el único puerto que
> existe), y es el gateway quien reenvía por dentro, por la red de Docker, a Keycloak.
> </details>

---

## 2. Configurar Keycloak (a través del gateway)

1. **Entra a la consola:** `http://localhost:8082/admin/master/console/` → `admin` / `admin` (de tu `.env`).

   > Fíjate que esto funciona **sin haber configurado aún nada del gateway**: la ruta `/admin/*` está
   > exenta de pedir sesión. La consola de Keycloak tiene su propio login, aparte del que vas a montar.

2. **Crear el realm:** desplegable `master` → **Create realm** → nombre `curso` → Create.
3. **Crear el cliente confidencial:** realm `curso` → **Clients** → **Create client**.
   - Client ID = `gateway` → Next.
   - **Client authentication = ON** (confidencial, con secreto), **Standard flow = ON**, resto OFF → Next.
   - **Valid redirect URIs** = `http://localhost:8082/oauth2/callback` → Save.
4. **Copiar el secreto:** pestaña **Credentials** del cliente `gateway` → copia el **Client secret** →
   pégalo en `.env`, variable `OAUTH2_PROXY_CLIENT_SECRET` (sustituye `placeholder-temporal`).
5. **Crear el usuario:** **Users** → Create user → `diego` → Create. Pestaña **Credentials** → Set
   password (`Temporary = Off`). Pestaña **Details** → activa **Email verified** → Save.
6. **Reiniciar el gateway** para que recoja el secreto real:
   ```bash
   docker compose up -d oauth2-proxy
   ```

> 🧠 **Pregunta.** ¿Por qué este cliente es **confidencial** y el del Laboratorio 3.1 era público?
>
> <details><summary>Ver respuesta</summary>
> Este cliente vive dentro del contenedor de `oauth2-proxy` (server-side): nadie externo puede leer su
> configuración. Un secreto ahí **sí** protege algo de verdad, al contrario que en una SPA.
> </details>

---

## 3. Prueba sin sesión y con sesión

1. **Sin sesión:** abre `http://localhost:8082/` en una **ventana privada** → **401** o redirección al
   login de Keycloak.
2. **Con sesión:** completa el login como `diego`. Al volver, `whoami` responde **200** con un volcado
   de todas las cabeceras HTTP que recibió.

---

## 4. Encuentra las cabeceras inyectadas

En ese volcado de `whoami`, localiza estas cabeceras que **tú no has puesto**:

- `X-Forwarded-User`
- `X-Forwarded-Email`
- `X-Forwarded-Preferred-Username`
- `Authorization: Bearer ...` (el JWT completo)

**Esto es lo importante:** `whoami` no sabe qué es OAuth, ni un realm, ni un token. Solo ve cabeceras
HTTP normales, como cualquier backend. Toda la complejidad de autenticación se quedó en el **borde**
(el gateway) y no se propagó al servicio.

> 🧠 **Pregunta.** `whoami` recibe la identidad del usuario sin saber nada de OAuth. ¿Y si `whoami`
> fueran 50 microservicios distintos?
>
> <details><summary>Ver respuesta</summary>
> Ninguno de los 50 tendría que implementar login. Esa es la razón de ser del patrón: centralizar la
> autenticación en un punto (el borde) en vez de repetirla en cada servicio.
> </details>

---

## 5. Pruébalo: rompe lo que sí controlas

Aquí el navegador nunca tiene el JWT suelto: lo que tiene es una **cookie de sesión** firmada por el
propio `oauth2-proxy`. Ataquemos eso:

1. **Manipular la cookie:** DevTools → **Application** → **Cookies** → busca la cookie `_oauth2_proxy`
   → cambia un carácter cualquiera de su valor → recarga `http://localhost:8082/` → vuelve a tratarte
   como sin sesión. La cookie está protegida criptográficamente: no se puede falsificar a mano.
2. **Apagar el proveedor de identidad:**
   ```bash
   docker compose stop keycloak
   ```
   Abre una **ventana privada nueva** y ve a `http://localhost:8082/` → redirige al login, pero al
   llegar a `/realms/...` da **502**: esa ruta la sirve el gateway reenviando a Keycloak, y Keycloak
   ya no está. Vuelve a arrancarlo:
   ```bash
   docker compose start keycloak
   ```

> 🧠 **Pregunta.** Apagar Keycloak no afecta a quien **ya** tenía sesión, pero sí a quien entra nuevo.
> ¿Por qué?
>
> <details><summary>Ver respuesta</summary>
> La cookie ya validada se verifica **localmente** (firma/cifrado), sin llamar a Keycloak en cada
> petición. Solo se necesita a Keycloak para un login nuevo o para renovar un token caducado. Por eso
> el efecto de apagarlo tarda en notarse en las sesiones ya abiertas.
> </details>

---

## 6. Qué entregar

Las **tres respuestas** (sin sesión / con sesión válida / cookie manipulada) y la **cabecera
inyectada** señalada.

## Si algo falla

- El login falla con error de credenciales de cliente → te saltaste el **paso 6** (reiniciar
  `oauth2-proxy` tras copiar el secreto real). Sigue usando `placeholder-temporal`.
- `oauth2-proxy` no arranca (`cookie_secret must be 16, 24, or 32 bytes`) → pegaste el cookie secret
  sin el `tr '+/' '-_'` y le tocó un `+` o `/`. Regenéralo.
- Crees que Keycloak está caído → la primera vez tarda 30-40 s en estar `healthy`. Espera.
