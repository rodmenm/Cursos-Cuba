# Lab 2 — WebAuthn sin escribir backend

**Módulo:** [2 — Autenticación robusta](../README.md).
**Infra:** [`docker-compose.yml`](docker-compose.yml) propio de este lab — copia exacta del del
[Lab 1](../../modulo-1-zero-trust-ciclo-vida/laboratorio-1-keycloak-realms-rbac/) (mismo `name:` de
proyecto, mismo volumen). Carpeta autocontenida a propósito: de momento cada lab lleva su propia
copia en vez de depender de la de otro lab; cuando centralicemos en `infra/` esto se sustituye por
una referencia única.
**Materiales/entregables:** [`materiales/`](materiales/).
**Duración:** 60 min (10 arranque · 25 guiado · 10 romperlo · 10 entregable · 5 colchón).

## Nota de versión — esto cambia el plan original

El briefing original decía "copia el flow `browser`, ponlo como passwordless, vincúlalo al realm".
Esa es la forma **antigua** (Keycloak ≤26.3). Desde **Keycloak 26.4**, hay soporte nativo de
passkeys que no requiere tocar ningún flow: activas una política y un required action, y el propio
flow `browser` por defecto ya sabe ofrecer login con passkey o con contraseña, sin duplicar nada.

Esto además **resuelve solo** el choque que teníamos pendiente con el Lab 3.1: como no tocamos el
flow `browser` del realm, el login de la SPA del Lab 3.1 no se ve afectado en absoluto por lo que
hagamos aquí.

> Si alguna vez ves una guía o un repo que dice "duplica el flow browser" para esto, es de una
> versión vieja de Keycloak — no lo sigas con la 26.7.4 que usamos.

Sources: [Passkeys support in upcoming Keycloak release (26.4) — keycloak.org](https://www.keycloak.org/2025/09/passkeys-support-26-4)

## Prerrequisitos

- Haber completado el Lab 1 (el realm `curso` y el usuario `diego` tienen que existir).
- Un navegador Chromium (Chrome/Edge) — el autenticador virtual de DevTools es específico de
  Chromium, no existe en Firefox/Safari.

## Arranque (10 min)

```bash
cp .env.example .env
docker compose up -d
```

> Este compose es idéntico al del Lab 1 (mismo nombre de proyecto, mismo volumen `keycloak_data`).
> Si Keycloak ya está corriendo desde el Lab 1, este comando no crea nada nuevo, se limpia a
> reconocer el contenedor existente. Si arrancas de cero solo con este lab, tendrás un Keycloak
> vacío y necesitarás rehacer el realm/usuario del Lab 1 antes de seguir.

1. **Abrir primero la ventana privada** que se va a usar para todo el lab (Ctrl+Shift+N) y confirmar
   que Keycloak responde: `http://localhost:8080/realms/curso/account/`.
2. **Dentro de esa misma ventana privada**, abrir DevTools (F12) → menú **⋮** → **More tools** →
   **WebAuthn**.
3. Marcar **Enable virtual authenticator environment**.
4. Crear un autenticador virtual: Protocol `ctap2`, Transport `usb` (simula una llave física
   roaming, no el sensor de "este dispositivo" — encaja con el concepto de "passkey vinculada al
   dispositivo" del Módulo 2, y en la práctica da una experiencia más cómoda que `internal`), marcar
   **Supports resident keys** y **Supports user verification**.

   > **Esto es obligatorio, no opcional.** Sin autenticador virtual, el lab se muere en cualquier
   > portátil del aula sin Touch ID ni llave física — que van a ser la mayoría.

   > **El orden importa.** El entorno virtual se activa por pestaña/ventana, no para todo el
   > navegador. Si DevTools se abre en una ventana y el login se hace en otra (p. ej. una ventana
   > privada nueva abierta después), esa ventana no tiene el virtual activado y el navegador cae al
   > comportamiento normal — incluida la opción de guardar la passkey en un móvil por Bluetooth/QR.
   > Verificado al montar el lab: pasa de verdad, no es un caso raro. Por eso aquí se abre la
   > ventana privada primero y el DevTools dentro de ella, no al revés.

## Guiado (25 min)

1. **Activar la política de passkeys:** consola admin → realm `curso` → **Authentication** →
   pestaña **Policies** → sub-pestaña **WebAuthn Passwordless Policy** → activar **Enabled
   Passkeys** → poner **Require Discoverable Credentials** en **Yes** → Save.

   > En teoría este toggle es lo que exige que la credencial sea "discoverable" (que el propio
   > dispositivo diga quién eres, sin teclear usuario). En la práctica, **no vas a ver ningún
   > cambio visible** con nuestro autenticador virtual, porque ya lo creamos con "Supports resident
   > keys" marcado en el Arranque — eso ya fuerza credenciales discoverable por su cuenta. El
   > toggle del realm importa con hardware real que no las soporte por defecto; aquí es redundante,
   > pero lo activamos igual porque es la configuración correcta de cara a producción.

2. **(Opcional) Forzar el registro a todo el mundo:** **Authentication** → pestaña **Required
   Actions** → fila **Webauthn Register Passwordless** → activar, y si se quiere forzar en el
   próximo login, activar también **Set as default action**. Para este lab no hace falta — Diego
   se la registra él mismo desde su propia cuenta, que es más realista.

   > Si activas esto y no ves ningún cambio, es normal: el required action solo se dispara en un
   > login real de un usuario que **todavía no tiene** la credencial. Diego ya la tiene, así que no
   > hay login que lo active. No es que el toggle no sirva, es que no hay ningún escenario que lo
   > dispare con nuestros usuarios actuales.
3. **Registrar la passkey como Diego:** ventana privada → `http://localhost:8080/realms/curso/account/`
   → login normal con usuario/contraseña → **Account security** → **Signing in** → buscar la opción
   de passkey/clave de seguridad → **Set up passkey** → el navegador lanza el diálogo WebAuthn → el
   autenticador virtual lo resuelve solo.
4. **Comprobar en DevTools:** volver a la pestaña WebAuthn de DevTools → el autenticador virtual
   debe listar ahora una credencial, con su **Credential ID** y su contador de firmas.
5. **Volver a entrar sin contraseña:** cerrar sesión de Diego → ir de nuevo a
   `http://localhost:8080/realms/curso/account/` → la pantalla de login debe ofrecer entrar con
   passkey (sin pedir usuario primero, gracias a "Require Discoverable Credentials") → aceptar →
   entra sin teclear nada.

## Momento clave

El panel del autenticador virtual (DevTools) lista la credencial con su **ID** y su **contador de
firmas** — es la prueba visual de que la clave privada vive ahí dentro, no en Keycloak, y de que es
una credencial específica para este dominio (no serviría en ningún otro sitio).

## Romperlo (10 min)

1. DevTools → WebAuthn → borrar la credencial del panel.
2. Cerrar sesión de Diego y volver a intentar entrar **con la opción de passkey** → falla.
3. **Comprobar que la cuenta sigue intacta:** entrar como Diego otra vez, pero esta vez con
   **usuario y contraseña normales** → funciona sin problema. Lo que se ha roto es un *medio* de
   demostrar quién es Diego, no la cuenta ni sus permisos — y confirma que este modelo es híbrido:
   quitar la passkey no deja a nadie fuera si la contraseña sigue viva.

## Entregable (10 min)

Captura del panel de DevTools con la credencial (ID + contador) + una frase explicando por qué no
es phishable (la firma incluye el origen, no es la biometría lo que protege) → [`materiales/`](materiales/).

## Colchón (5 min)

Atasco típico: alguien no marca "Supports resident keys" al crear el autenticador virtual, y luego
el login sin usuario no funciona. Revisar la configuración del autenticador antes de re-explicar
nada.

## Preguntas para el aula

| Momento | Pregunta | Respuesta |
|---|---|---|
| Guiado, paso 1 (política de passkeys) | ¿En qué se diferencia esto del doble factor de autenticación (2FA)? | Son dos usos distintos de la misma tecnología, y Keycloak los trata como configuraciones separadas: **"WebAuthn Policy"** (a secas) es WebAuthn como *segundo* factor, sumado a la contraseña. **"WebAuthn Passwordless Policy"** — la que hemos configurado — es WebAuthn *sustituyendo* la contraseña como único factor. El curso no tiene un lab de 2FA aparte; esta es la única vez que se toca WebAuthn, así que la distinción se explica aquí, no se deja para después. |
| Mismo momento | De las dos, ¿cuál es más segura? | Contraintuitivamente, **una passkey sola suele ser más segura que contraseña + SMS/OTP (dos factores)**. No es el número de factores lo que importa, es si son resistentes a phishing: un proxy en tiempo real (tipo Evilginx) puede robar contraseña *y* OTP a la vez, pero no puede robar una passkey, porque la firma lleva el origen incrustado y no es reutilizable en otro sitio. Contar factores es la métrica equivocada. |
| Momento clave (panel de DevTools) | ¿Qué clave se guarda en el dispositivo, la pública o la privada? | La **privada** se genera y se queda siempre en el autenticador (o en nuestro caso, en el autenticador virtual) — nunca se transmite. La **pública** es la que viaja a Keycloak y se guarda en el servidor. Es criptografía asimétrica estándar: quien tiene la pública puede verificar firmas, pero no puede generarlas. |
| Arranque, paso 4 (crear el autenticador virtual) | En el creador de DevTools hay varios `Protocol` (`ctap2`, `ctap2_1`, `u2f`) y `Transport` (`usb`, `nfc`, `ble`, `internal`, `hybrid`) — ¿qué simula cada uno? | **Protocol:** `ctap2`/`ctap2_1` = FIDO2 moderno, soporta passkeys (lo que usamos). `u2f` = el protocolo antiguo, solo sirve como segundo factor clásico, no soporta credenciales discoverable — no vale para passwordless. **Transport** (cómo "llegaría" el autenticador de verdad): `internal` = autenticador integrado en el dispositivo (Windows Hello, Touch ID); `usb` = llave física por cable (lo que usamos); `nfc`/`ble` = acercar una llave o el móvil por NFC o Bluetooth; `hybrid` = el flujo "usa tu móvil" con código QR — **esto es justo lo que te pasó con el iPhone** antes de corregir lo de la ventana: al no tener el entorno virtual activo ahí, el navegador ofreció el `hybrid` real hacia tu teléfono. |
| Romperlo | ¿Qué pasa si se pierde la llave (el dispositivo con la passkey)? | No hay una respuesta bonita: si era la única credencial, se pierde el acceso por esa vía (lo acabamos de comprobar borrándola). Por eso existen las passkeys **sincronizadas** (iCloud/Google, recuperables en otro dispositivo con la misma cuenta) frente a las **vinculadas al dispositivo** (no se copian — los entornos regulados que las exigen necesitan un plan de recuperación aparte: una segunda llave de respaldo, un proceso con soporte humano). |

## Pendiente
- [ ] Verificar en frío, con Chrome actualizado, la ruta exacta dentro de "Account security → Signing in" (el nombre del botón puede variar entre versiones del tema de la Account Console).
- [ ] Decidir si el registro de la passkey se hace voluntario (como aquí) o se fuerza con la required action como "Default action", según cómo de guiado se quiera que sea este lab.

Fuente: [briefing §3, Lab 2](../../../docs/curso-identidad-briefing.md).
