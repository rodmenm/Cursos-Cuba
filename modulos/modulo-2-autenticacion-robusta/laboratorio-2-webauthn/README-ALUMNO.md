# Laboratorio 2 — WebAuthn / passkeys

> **Enunciado de práctica.** Trabaja siguiendo los pasos en orden; al final tienes que entregar lo
> que se indica en el último apartado. Tiempo estimado: unos 60 minutos.

## ¿Qué vas a hacer?

Vas a configurar **login sin contraseña** (passkeys) en Keycloak y lo vas a probar tú mismo usando
un **autenticador virtual** que trae el navegador por dentro. La idea de fondo: una passkey **no es
un secreto que puedas entregar por error** a una web falsa, y vas a ver *por qué* mirando dónde vive
la clave.

No vas a escribir ni una línea de backend: Keycloak trae el soporte de passkeys de fábrica.

## Antes de empezar necesitas

- Haber hecho el **Laboratorio 1** (tienen que existir el realm `curso` y el usuario `diego`).
- Un navegador **Chromium** (Chrome o Edge). El autenticador virtual es una herramienta de DevTools
  de Chromium — **no existe en Firefox ni Safari**.

## Apartados

1. **Preparación** y autenticador virtual (el paso que hace que esto funcione en cualquier portátil).
2. **Activar passkeys** en el realm.
3. **Registrar tu passkey** como Diego.
4. **Entrar sin contraseña.**
5. **Pruébalo** y **qué entregar.**

---

## 1. Preparación y autenticador virtual

```bash
cp .env.example .env
docker compose up -d
```

> Este Keycloak es el mismo del Laboratorio 1 (mismo proyecto y volumen). Si ya lo tenías arriba, no
> se crea nada nuevo. Si arrancas de cero solo con este laboratorio, tendrás un Keycloak vacío y
> tendrás que rehacer el realm/usuario del Laboratorio 1 antes de seguir.

**El orden de estos pasos importa, hazlos tal cual:**

1. Abre **primero** una ventana **privada** (Ctrl+Shift+N) y confirma que Keycloak responde:
   `http://localhost:8080/realms/curso/account/`.
2. **Dentro de esa misma ventana privada**, abre DevTools (F12) → menú **⋮** → **More tools** →
   **WebAuthn**.
3. Marca **Enable virtual authenticator environment**.
4. Crea un autenticador virtual: Protocol `ctap2`, Transport `usb`, y marca **Supports resident
   keys** y **Supports user verification**.

> ⚠️ **Esto es obligatorio.** Sin autenticador virtual, en un portátil sin Touch ID ni llave física
> no podrías hacer la práctica. Y el entorno virtual se activa **por ventana**: si abres el DevTools
> en una ventana y haces el login en otra, esa otra no lo tiene y el navegador intentará usar tu móvil
> por QR. Por eso abrimos la ventana privada primero y el DevTools dentro de ella.

---

## 2. Activar las passkeys en el realm

Consola admin → realm `curso` → **Authentication** → pestaña **Policies** → **WebAuthn Passwordless
Policy** → activa **Enabled Passkeys** → pon **Require Discoverable Credentials** en **Yes** → Save.

> No vas a ver un cambio visible al guardar: nuestro autenticador virtual ya soporta "resident keys",
> así que esto es redundante aquí. Se activa igual porque es la configuración correcta para producción.

> 🧠 **Pregunta.** ¿En qué se diferencia esto del doble factor (2FA) de toda la vida?
>
> <details><summary>Ver respuesta</summary>
> Son dos usos de la misma tecnología. La política "WebAuthn Policy" a secas usa WebAuthn como
> *segundo* factor (sumado a la contraseña). La "WebAuthn **Passwordless** Policy" — la que has
> activado — usa WebAuthn **sustituyendo** la contraseña como único factor.
> </details>

> 🧠 **Pregunta.** ¿Y cuál es más segura, una passkey sola o contraseña + SMS/OTP (dos factores)?
>
> <details><summary>Ver respuesta</summary>
> Contraintuitivamente, **la passkey sola** suele ser más segura. No importa el número de factores,
> importa si resisten phishing: un proxy en tiempo real (tipo Evilginx) puede robarte contraseña *y*
> OTP a la vez, pero no una passkey, porque su firma lleva el origen incrustado y no se puede reusar
> en otro sitio. Contar factores es la métrica equivocada.
> </details>

---

## 3. Registra tu passkey (como Diego)

1. En la ventana privada → `http://localhost:8080/realms/curso/account/` → entra con usuario y
   contraseña de Diego (login normal, de momento).
2. **Account security** → **Signing in** → busca la opción de passkey / clave de seguridad → **Set up
   passkey**.
3. El navegador lanza el diálogo WebAuthn y **el autenticador virtual lo resuelve solo**.
4. Vuelve a la pestaña **WebAuthn** de DevTools: ahora aparece **una credencial**, con su
   **Credential ID** y un contador de firmas.

### La idea clave

Esa credencial en el panel es la **prueba visual** de que la clave **privada vive en el autenticador**
(no en Keycloak), y de que es específica para este dominio: no serviría en ningún otro sitio.

> 🧠 **Pregunta.** ¿Qué clave se ha guardado en el dispositivo, la pública o la privada?
>
> <details><summary>Ver respuesta</summary>
> La **privada** se genera y se queda siempre dentro del autenticador — nunca se transmite. La
> **pública** es la que viaja a Keycloak. Quien tiene la pública puede *verificar* firmas, pero no
> *generarlas*: es criptografía asimétrica estándar.
> </details>

---

## 4. Entra sin contraseña

1. Cierra la sesión de Diego.
2. Ve otra vez a `http://localhost:8080/realms/curso/account/`.
3. La pantalla de login debe ofrecerte entrar **con passkey** (sin pedirte usuario primero, gracias a
   "Require Discoverable Credentials"). Acéptalo → **entras sin teclear nada**.

---

## 5. Pruébalo: borra la credencial

1. DevTools → WebAuthn → **borra** la credencial del panel.
2. Cierra sesión y vuelve a intentar entrar **con la opción de passkey** → **falla**.
3. Ahora entra como Diego **con usuario y contraseña normales** → funciona sin problema.

Lo que has roto es *una forma* de demostrar quién es Diego, no su cuenta ni sus permisos. Este modelo
es híbrido: quitar la passkey no deja a nadie fuera mientras la contraseña siga viva.

> 🧠 **Pregunta.** ¿Y si pierdes la llave (el dispositivo con la passkey)?
>
> <details><summary>Ver respuesta</summary>
> No hay respuesta bonita: si era tu única credencial, pierdes el acceso por esa vía (lo acabas de
> ver). Por eso existen las passkeys **sincronizadas** (iCloud/Google, recuperables en otro
> dispositivo con tu cuenta) frente a las **vinculadas al dispositivo** (no se copian: los entornos
> regulados que las exigen necesitan un plan de recuperación aparte, como una segunda llave de respaldo).
> </details>

---

## 6. Qué entregar

Una **captura del panel de DevTools** con la credencial (ID + contador) y **una frase** explicando por
qué una passkey no es *phishable* (pista: la firma incluye el **origen**; no es la biometría lo que
protege).

## Si algo falla

- El login sin usuario no funciona → seguramente no marcaste **Supports resident keys** al crear el
  autenticador. Revísalo.
- El navegador te ofrece usar el móvil por QR → el entorno virtual no está activo en esa ventana.
  Vuelve al apartado 1 y hazlo en la misma ventana del DevTools.
