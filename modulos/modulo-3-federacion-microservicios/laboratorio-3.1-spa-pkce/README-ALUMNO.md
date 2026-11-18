# Laboratorio 3.1 — SPA con PKCE

> **Enunciado de práctica.** Trabaja siguiendo los pasos en orden; al final tienes que entregar lo
> que se indica en el último apartado. Tiempo estimado: unos 60 minutos.

## ¿Qué vas a hacer?

Vas a ver, **en crudo y en la pestaña de red del navegador**, el baile completo de OAuth con PKCE:
una aplicación web (una SPA) pide permiso, recibe un `code`, y lo canjea por un token demostrando que
es ella quien empezó. Vas a calcular tú mismo (una vez, dos minutos) la prueba criptográfica que
hace que un `code` robado no sirva de nada.

> **Ojo con la intención:** esta SPA guarda ella misma el token en el navegador, algo que **no** se
> hace en producción. Lo montamos a propósito para ver el mecanismo desnudo; en el Laboratorio 3.2
> verás la forma correcta (un gateway que lo hace por ti).

## Antes de empezar necesitas

- Haber hecho el **Laboratorio 1** (realm `curso`, usuario `diego` con contraseña).
- **Conexión a internet** (la SPA carga la librería `keycloak-js` desde un CDN).

## Apartados

1. **Preparación.**
2. **Crear el cliente** público y forzar PKCE.
3. **Login mirando la red** (ver `code_challenge`, `code`, `/token`).
4. **La cripto a mano.**
5. **Pruébalo** (un `code` robado) y **qué entregar.**

---

## 1. Preparación

```bash
cp .env.example .env
docker compose up -d
```

- Confirma Keycloak: `http://localhost:8080/realms/curso/account/`.
- Confirma la SPA: `http://localhost:8081/` → debe verse "No autenticado." y un botón "Iniciar
  sesión". Si ves un error de consola sobre `esm.sh`, revisa tu conexión a internet.

---

## 2. Crear el cliente público y forzar PKCE

**Qué vamos a hacer:** registrar la SPA en Keycloak como un cliente **público** (sin secreto, porque
vive en el navegador) y obligarle a usar PKCE.

1. Consola admin → realm `curso` → **Clients** → **Create client**.
   - Client ID = `spa-curso` → Next.
   - **Client authentication = OFF** (público), **Standard flow = ON**, el resto OFF → Next.
   - **Valid redirect URIs** = `http://localhost:8081/*`
   - **Valid post logout redirect URIs** = `http://localhost:8081/*`
   - **Web origins** = `http://localhost:8081` → Save.
2. Abre el cliente `spa-curso` → pestaña **Advanced** → **Proof Key for Code Exchange Code Challenge
   Method** → `S256` → Save.

> 🧠 **Pregunta.** ¿Por qué este cliente es **público** y no lleva un secreto como otros?
>
> <details><summary>Ver respuesta</summary>
> Porque su código vive en el navegador del usuario: cualquiera puede abrir DevTools y leerlo. Un
> secreto ahí no protegería nada. Por eso los clientes públicos se apoyan en **PKCE** en lugar de en
> un secreto.
> </details>

---

## 3. Haz login mirando la red

1. Abre `http://localhost:8081/` → DevTools (F12) → pestaña **Network** → **marca Preserve log**
   (importante: sin esto, la redirección borra las peticiones y no verás la secuencia completa).
2. Clic en **"Iniciar sesión"** y sigue la secuencia en el Network tab:
   - **GET a `.../openid-connect/auth?...&code_challenge=...&code_challenge_method=S256`** → aquí va el
     `code_challenge`. **Apúntalo**, lo necesitas en el apartado 4.
   - (Verás un POST a `.../authenticate?...`: es solo el envío del formulario de login de Keycloak,
     ignóralo.)
   - Entra como `diego`.
   - Vuelves a la SPA. El `code` llega en el **fragmento** de la URL (`#...code=...`), que no viaja al
     servidor; por eso no aparece como una petición de red nueva, lo lee la propia página con JS.
   - **POST a `.../openid-connect/token`** con `code`, `code_verifier` y `client_id` en el cuerpo →
     **esta es la petición clave**, localízala.
3. La página te mostrará el `access_token` en crudo y sus claims (`iss`, `aud`, `exp`…) ya parseados.

> 🧠 **Pregunta.** El token acaba en una variable JavaScript del navegador, algo que se considera
> peligroso: ¿por qué exactamente?
>
> <details><summary>Ver respuesta</summary>
> Cualquier XSS en la página (una librería de terceros comprometida, un fallo de sanitización) puede
> leer ese token desde el propio JavaScript y robarlo. Esa es la razón de ser del patrón **BFF**, que
> pondrás en práctica en el Laboratorio 3.2.
> </details>

---

## 4. La cripto a mano

Pon al lado la petición a `/auth` (que llevaba el `code_challenge`) y la petición a `/token` (que
lleva el `code_verifier` en claro, en el cuerpo). Ahora calcula el SHA-256 del verifier:

```bash
printf '%s' 'EL_CODE_VERIFIER_DE_LA_PETICION' | openssl dgst -binary -sha256 | openssl base64 -A \
  | tr '+/' '-_' | tr -d '='
```

El resultado tiene que ser **exactamente** el `code_challenge` que viajó en `/auth`. Esto demuestra
que el `code_challenge` no es un valor cualquiera: es la **prueba de que quien pide el token es quien
empezó el login**.

---

## 5. Pruébalo: un `code` robado

Vamos a demostrar que un `code` interceptado **no sirve sin el `code_verifier`**. Como el `code` del
login normal ya se gastó (solo se puede canjear una vez), generamos uno nuevo dirigido a una página
que no lo consume:

1. Reutiliza el `code_challenge` que ya calculaste.
2. Construye esta URL (sustituyendo `CODE_CHALLENGE`) y ábrela en el navegador:
   ```
   http://localhost:8080/realms/curso/protocol/openid-connect/auth?client_id=spa-curso&redirect_uri=http://localhost:8081/capturar-code.html&response_type=code&scope=openid&code_challenge=CODE_CHALLENGE&code_challenge_method=S256
   ```
   Como Diego ya tiene sesión, aterrizas directo en `capturar-code.html` con un `code` nuevo en la URL.
3. Copia el `code` de la barra de direcciones.
4. Intenta canjearlo **sin** el verifier:
   ```bash
   curl -s -X POST http://localhost:8080/realms/curso/protocol/openid-connect/token \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "grant_type=authorization_code" \
     -d "client_id=spa-curso" \
     -d "code=PEGA_AQUI_EL_CODE" \
     -d "redirect_uri=http://localhost:8081/capturar-code.html"
   ```
   **Esperado:** Keycloak lo rechaza (`invalid_grant` / fallo PKCE).
5. (Opcional) Repite añadiendo `-d "code_verifier=..."` con el valor real → ahora **sí** funciona, lo
   que aísla que el fallo anterior era exactamente por el verifier que faltaba.

> 🧠 **Pregunta.** ¿Por qué hizo falta una página nueva (`capturar-code.html`) en vez del `code` del
> login normal?
>
> <details><summary>Ver respuesta</summary>
> Los `code` son de un solo uso. El del login ya se había canjeado, así que reutilizarlo fallaría por
> "ya usado", no por el motivo que queremos demostrar (falta de verifier). Aislar la causa exacta es
> lo que hace la prueba honesta.
> </details>

---

## 6. Qué entregar

Captura de las **dos peticiones** del login legítimo (`/auth` y `/token`, del apartado 3) más el
**access token decodificado** con `iss`, `aud` y `exp` señalados.

> 🧠 **Pregunta.** En ese token, ¿qué pasaría si intentaras usarlo contra otra app distinta de `spa-curso`?
>
> <details><summary>Ver respuesta</summary>
> La rechazaría por el claim `aud` (audience): el token solo vale para el cliente al que se emitió. Es
> lo que impide que un token robado a una app sirva para colarse en otra.
> </details>

## Si algo falla

- Se te borraron las peticiones al redirigir → no marcaste **Preserve log**. Repite el login.
- La petición a `/token` falla por CORS → revisa **Web origins** en el cliente (`http://localhost:8081`).
