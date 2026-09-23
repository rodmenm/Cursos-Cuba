# Lab 3.1 — SPA con PKCE

**Módulo:** [3 — Federación y microservicios](../README.md).
**Infra:** [`docker-compose.yml`](docker-compose.yml) propio (Keycloak, copia del Lab 1, + un
`nginx` sirviendo la SPA estática). Autocontenido, mismo patrón que Labs 1 y 2.
**Config del lab:** [`config/`](config/) (`index.html` con keycloak-js vía CDN, sin build; y
`capturar-code.html`, una página en blanco para el romperlo).
**Materiales/entregables:** [`materiales/`](materiales/).
**Duración:** 60 min (10 arranque · 25 guiado · 10 romperlo · 10 entregable · 5 colchón).

## Qué se construye y por qué

Una SPA que hace ella misma el baile OAuth/PKCE contra Keycloak, sin backend propio. Es el patrón
que la teoría del Módulo 3 dice que **no** deberías usar en producción (el navegador llega a tener
el token) — se enseña a propósito para ver el mecanismo en crudo antes de que el Lab 3.2 muestre la
forma correcta (un gateway que hace el baile por ti).

## Nota técnica — nada de Node, pero ojo con la sintaxis

`keycloak-js` se carga directo desde un CDN en el propio `index.html`, sin `npm install`, sin
build, sin bundler. Pero las versiones recientes (26.x) se publican como **módulo ES**, así que
no vale la etiqueta clásica `<script src="...">` — hace falta `<script type="module">` con
`import Keycloak from "..."`. Usamos `esm.sh` porque sirve el paquete ya listo para import de
navegador:

```html
<script type="module">
  import Keycloak from "https://esm.sh/keycloak-js@26.2.4";
  ...
</script>
```

> `keycloak-js` en npm no sigue el mismo versionado que el servidor Keycloak (el compose usa
> `26.7.4` para el servidor, pero la última versión del paquete cliente es `26.2.4`). Pedir a
> `esm.sh` una versión de `keycloak-js` que no existe en npm devuelve 404 — comprobar la versión
> real en [npmjs.com/package/keycloak-js](https://www.npmjs.com/package/keycloak-js) antes de
> fijarla aquí.

Sigue siendo HTML estático que `nginx` sirve tal cual — el único cambio es la sintaxis de la
etiqueta, no el enfoque.

Sources: [keycloak-js — npm](https://www.npmjs.com/package/keycloak-js), [GitHub issue #36983 — CDN ES module error](https://github.com/keycloak/keycloak/issues/36983)

## Prerrequisitos

- Haber completado el Lab 1 (realm `curso`, usuario `diego` con contraseña puesta).
- Necesita acceso a internet en el aula (para cargar `keycloak-js` desde `esm.sh`) — si el plan es
  sin red, hay que servir ese fichero JS localmente en vez de por CDN. Anotado en Pendiente.

## Arranque (10 min)

```bash
cp .env.example .env
docker compose up -d
```

> Mismo compose que Labs 1 y 2 (mismo `name:` de proyecto, mismo volumen) más el servicio `spa`
> nuevo. Si Keycloak ya estaba corriendo, no se recrea; el `spa` sí es nuevo en este lab.

1. Confirmar Keycloak: `http://localhost:8080/realms/curso/account/`.
2. Confirmar la SPA: `http://localhost:8081/` — debe verse "No autenticado." y un botón "Iniciar
   sesión". Si sale un error de consola sobre `esm.sh`, revisar la conexión a internet.

## Guiado (25 min)

1. **Crear el cliente público:** consola admin → realm `curso` → **Clients** → **Create client**.
   - General settings: Client ID = `spa-curso` → Next.
   - Capability config: **Client authentication = OFF** (público, sin secreto), **Standard flow =
     ON**, el resto OFF → Next.
   - Login settings: **Valid redirect URIs** = `http://localhost:8081/*`. **Valid post logout
     redirect URIs** = `http://localhost:8081/*` (la SPA llama a `keycloak.logout()` con un
     `redirectUri` explícito — desde Keycloak 22 ese redirect se valida contra este campo
     aparte, no contra "Valid redirect URIs"; si se deja vacío, cerrar sesión falla). **Web
     origins** = `http://localhost:8081` (necesario para que el navegador pueda hacer la
     petición a `/token` entre orígenes distintos — 8081 vs 8080) → Save.
2. **Forzar PKCE:** abrir el cliente `spa-curso` → pestaña **Advanced** → sección **Advanced
   settings** → **Proof Key for Code Exchange Code Challenge Method** → `S256` → Save.
3. **Preparar la captura:** abrir `http://localhost:8081/` → DevTools (F12) → pestaña **Network**
   → marcar **Preserve log** (importante: sin esto, la redirección borra las peticiones anteriores
   y no se ve la secuencia completa).
4. **Login:** clic en "Iniciar sesión". Seguir en el Network tab:
   - Petición GET a `.../protocol/openid-connect/auth?...&code_challenge=...&code_challenge_method=S256`
     — este es el `code_challenge`, apúntalo para el momento clave.
   - POST a `.../login-actions/authenticate?...` — el envío del formulario usuario/contraseña de la
     propia pantalla de login de Keycloak. No es parte del intercambio OAuth/PKCE, se puede ignorar.
   - Login como `diego`.
   - Redirección de vuelta a la SPA. La petición inicial lleva `response_mode=fragment`, así que el
     `code` y el `state` llegan en el **fragmento** de la URL (`http://localhost:8081/#state=...&code=...`),
     no en la query string. Un fragmento no viaja al servidor: no aparece como petición de red nueva
     en el Network tab, solo como la navegación de nivel superior — es la propia página, ya cargada,
     la que lee `location.hash` con JavaScript.
   - POST automático a `.../protocol/openid-connect/token` con `code`, `code_verifier` y
     `client_id` en el cuerpo (form-urlencoded) — esta sí es una petición de red normal, es la que
     hay que localizar para el momento clave.
5. **Comprobar el resultado:** la página debe mostrar el `access_token` en crudo y sus `claims`
   (`iss`, `aud`, `exp`, entre otros) ya parseados en pantalla.

## Momento clave

Con la petición a `/auth` (que tiene el `code_challenge`) y la petición a `/token` (que tiene el
`code_verifier`, en claro, en el cuerpo) una al lado de la otra:

```bash
printf '%s' 'EL_CODE_VERIFIER_DE_LA_PETICION' | openssl dgst -binary -sha256 | openssl base64 -A \
  | tr '+/' '-_' | tr -d '='
```

El resultado tiene que ser **exactamente** el `code_challenge` que viajó en la petición a `/auth`.
Es la única cripto a mano de todo el curso (dos minutos) y demuestra que el `code_challenge` no es
un valor arbitrario: es la prueba criptográfica de que quien pide el token es quien empezó el login.

## Romperlo (10 min)

El objetivo: demostrar que un `code` interceptado no sirve de nada sin el `code_verifier`. Para
que la prueba sea limpia hace falta un `code` **recién emitido y sin usar** — el que ya consumió la
SPA en el paso 4 ya está quemado (un `code` solo se puede canjear una vez), así que se genera uno
nuevo a mano, dirigido a una página que no lo consume sola:

1. **Reutilizar** el `code_challenge` que ya tienes calculado del momento clave.
2. **Construir a mano esta URL** (sustituyendo `CODE_CHALLENGE`) y abrirla en el navegador:
   ```
   http://localhost:8080/realms/curso/protocol/openid-connect/auth?client_id=spa-curso&redirect_uri=http://localhost:8081/capturar-code.html&response_type=code&scope=openid&code_challenge=CODE_CHALLENGE&code_challenge_method=S256
   ```
   Como Diego ya tiene sesión activa en Keycloak, probablemente no vuelva a pedir login — aterriza
   directo en `capturar-code.html` con un `code` nuevo en la URL, sin que nada lo consuma (esa
   página no tiene JavaScript).
3. **Copiar el `code`** de la barra de direcciones.
4. **Intentar canjearlo sin el verifier:**
   ```bash
   curl -s -X POST http://localhost:8080/realms/curso/protocol/openid-connect/token \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "grant_type=authorization_code" \
     -d "client_id=spa-curso" \
     -d "code=PEGA_AQUI_EL_CODE" \
     -d "redirect_uri=http://localhost:8081/capturar-code.html"
   ```
   Esperado: Keycloak lo rechaza (`invalid_grant` / fallo de verificación PKCE).
5. **(Opcional) Repetir con el `code_verifier` correcto** (añadiendo `-d "code_verifier=..."` con
   el valor real que calculaste antes) → esta vez funciona, aislando que el fallo anterior era
   específicamente por el verifier que faltaba, no por otra cosa.

## Entregable (10 min)

Captura de las dos peticiones (`/auth` y `/token` del login legítimo, paso 4) más el access token
decodificado con `iss`, `aud` y `exp` señalados → [`materiales/`](materiales/).

## Colchón (5 min)

Atasco típico: alguien olvida marcar "Preserve log" y la redirección le borra las peticiones — hay
que repetir el login. Otro: `Web origins` mal puesto y la petición a `/token` falla por CORS antes
de llegar a nada interesante.

## Preguntas para el aula

| Momento | Pregunta | Respuesta |
|---|---|---|
| Guiado, paso 1 | ¿Por qué este cliente es público (`Client authentication = OFF`) y no confidencial? | Porque el código vive en el navegador del usuario — cualquiera puede abrir DevTools y leer el código fuente. Un secreto de cliente ahí no protegería nada; por eso los clientes públicos se apoyan en PKCE en vez de en un secreto. |
| Guiado, paso 4 | El token llega directo al navegador, en una variable JS — la teoría del Módulo 3 dice que eso es peligroso. ¿Por qué exactamente? | Cualquier XSS en la página (una librería de terceros comprometida, un fallo de sanitización) puede leer ese token desde el propio JavaScript y robarlo. Es la razón de ser del patrón BFF, que el Lab 3.2 pone en práctica. |
| Romperlo | ¿Por qué hizo falta una página nueva (`capturar-code.html`) en vez de usar el `code` del login normal? | Los `code` son de un solo uso. El del login normal ya se había canjeado (paso 4); reutilizarlo habría fallado por "ya usado", no por el motivo que se quería demostrar (falta de verifier). Aislar la causa exacta del fallo es lo que hace la prueba honesta. |
| Entregable | En el token, ¿qué pasaría si lo intentaras usar contra otra aplicación distinta a `spa-curso`? | La rechazaría por el claim `aud` (audience) — el token solo es válido para el/los cliente(s) a los que se emitió. Es el mecanismo que impide que un token robado a una app sirva para colarse en otra. |

## Pendiente
- [ ] Decidir plan si el aula no tiene red: servir `keycloak-js` localmente (copiar el fichero al
      `config/` en vez de cargarlo desde `esm.sh`) en vez de depender del CDN.
- [ ] Probar en frío el paso de romperlo completo (construcción manual de la URL) antes de clase —
      es el paso más propenso a errores tipográficos de todo el lab.

Fuente: [briefing §3, Lab 3.1](../../../docs/curso-identidad-briefing.md).
