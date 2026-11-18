# Laboratorio 1 — Keycloak, realms y RBAC

> **Enunciado de práctica.** Trabaja siguiendo los pasos en orden; al final tienes que entregar lo
> que se indica en el último apartado. Tiempo estimado: unos 60 minutos.

## ¿Qué vas a hacer?

Vas a levantar **Keycloak** (un servidor de identidad profesional) en tu ordenador con Docker, y
dentro vas a construir una pequeña organización: dos usuarios, dos roles (`lector` y `editor`) y
dos grupos. El objetivo no es "clicar botones": es **ver con tus propios ojos** cómo se reparten los
permisos por rol y por grupo (lo que se llama **RBAC**), y por qué eso evita el caos de dar permisos
usuario por usuario.

Al final abrirás un **token** y comprobarás que lo que afirma coincide exactamente con los permisos
que has configurado.

## Antes de empezar necesitas

- **Docker** y **Docker Compose** instalados y funcionando.
- Los puertos **8080** y **9000** libres.

## Apartados

1. **Preparación:** levantar Keycloak y entrar a la consola.
2. **Roles:** crear `lector` y `editor` y hacer que `editor` "herede" de `lector`.
3. **Usuarios y grupos:** crear a Marta y Diego, meterlos en grupos y ver la herencia.
4. **Abrir el token:** comprobar que el permiso está realmente dentro del token.
5. **Pruébalo:** quitar un permiso y ver el efecto en cascada.
6. **Qué entregar.**

---

## 1. Preparación

Copia el fichero de configuración y levanta el contenedor:

```bash
cp .env.example .env
docker compose up -d
```

Espera a que Keycloak esté listo (la columna de estado debe decir `healthy`):

```bash
docker compose ps
```

Ahora abre `http://localhost:8080/` → **Administration Console** y entra con el usuario y contraseña
de tu `.env` (`admin` / `admin` si no lo cambiaste).

**Comprobación:** arriba a la izquierda verás `master`. Ese es el realm de administración de
Keycloak. **Recuérdalo**, porque al final volveremos a él.

> 🧠 **Pregunta.** Al entrar, Keycloak dice "you are logged in as a temporary admin user". ¿Por qué
> *temporary*?
>
> <details><summary>Ver respuesta</summary>
> Porque las credenciales de arranque (las de tu `.env`) viven en texto plano. Keycloak las marca
> como temporales para empujarte a no dejarlas como admin permanente. Es Zero Trust aplicado a sus
> propias credenciales.
> </details>

---

## 2. Crear los roles

**Qué vamos a hacer:** `lector` solo podrá *ver* su perfil; `editor` podrá *editarlo*. Y haremos
que `editor` **sea también** un `lector` (que herede sus permisos), en vez de repetir permisos a mano.

1. **Crear el realm:** despliega `master` (arriba izq.) → **Create realm** → nombre `curso` → Create.
2. **Crear los roles:** menú lateral **Realm roles** → Create role → `lector` → Save. Repite con `editor`.
3. **Vaciar el "suelo" por defecto:** **Realm settings** → pestaña **User registration** →
   **Default roles** (marca "Hide inherited roles") → selecciona `account / manage-account` **y**
   `account / view-profile` → **Unassign**. Con esto, un usuario sin rol no puede ni ver su perfil:
   cada permiso tendrá que venir explícitamente de un rol.
4. **`lector` = puede ver:** abre el rol `lector` → pestaña **Associated roles** → Assign role →
   filtra por roles de cliente → `account` → marca `view-profile` → Assign.
5. **`editor` = es un lector que además edita:** abre `editor` → **Associated roles** → Assign role
   → busca el rol de **realm** `lector` → Assign. Luego otra vez Assign role, ahora filtrando por
   cliente `account` → marca `manage-account` → Assign.

> 🧠 **Pregunta.** En el paso 5, ¿por qué asociamos `editor` con el rol `lector` en lugar de volver a
> añadirle `view-profile` directamente?
>
> <details><summary>Ver respuesta</summary>
> Así queda declarado "editor ⊇ lector" de forma explícita. Si mañana cambia qué significa `lector`,
> `editor` lo hereda solo. Si hubieras duplicado `view-profile` en los dos, coincidirían por
> casualidad, no por relación: un cambio futuro en uno no se propagaría al otro.
> </details>

---

## 3. Usuarios, grupos y herencia

**Qué vamos a hacer:** en vez de dar roles a cada usuario, se los damos a **grupos**, y metemos a los
usuarios en el grupo. Es el patrón que evita que los permisos se acumulen sin control.

1. **Crear usuarios:** menú **Users** → Add user → `marta` → Create. Repite con `diego`.
2. **Ponerles contraseña:** en cada usuario, pestaña **Credentials** → Set password → **desactiva el
   toggle Temporary** → Save.
3. **Crear grupos:** menú **Groups** → Create group → `lectura` → Create. Repite con `redaccion`.
4. **Dar el rol a cada grupo (no al usuario):**
   - `lectura` → pestaña **Role mapping** → Assign role → `lector` → Assign.
   - `redaccion` → **Role mapping** → Assign role → `editor` → Assign.
5. **Meter a cada usuario en su grupo:** Users → `marta` → **Groups** → Join group → `lectura`.
   Users → `diego` → **Groups** → Join group → `redaccion`.
6. **Comprobar la herencia:** Users → `diego` → **Role mapping** → **desactiva** "Hide inherited
   roles" → debe aparecer `editor` **heredado** de `redaccion`. Repite con `marta`: verás `lector`
   heredado de `lectura`. Ninguno tiene el rol asignado a mano: todo llega por el grupo.
7. **Verlo de verdad:** abre una **ventana privada** → `http://localhost:8080/realms/curso/account/`
   → entra como `diego` → cambia un campo del perfil (por ejemplo el nombre) y guarda → **funciona**.

   > ⚠️ **No lo intentes con Marta.** Con solo `view-profile`, la Account Console de esta versión no
   > se pone en "solo lectura": directamente **no carga** y muestra una pantalla de error. **No has
   > roto nada**, es una limitación conocida de esta versión. Lo de Marta lo comprobaremos de otra
   > forma en el apartado 4.

> 🧠 **Pregunta.** ¿Qué pasaría si `redaccion` tuviera 200 personas en vez de una?
>
> <details><summary>Ver respuesta</summary>
> Esa es justo la ventaja de RBAC por grupo: revocar a 200 personas es **un clic** (quitar el rol del
> grupo), en vez de 200 acciones una a una. Dar permisos usuario por usuario es como se pierde el
> rastro de quién tiene qué.
> </details>

---

## 4. Abre el token

**Qué vamos a hacer:** en vez de fiarnos de una pantalla que "funciona o revienta", vamos a mirar el
contenido real del token que Keycloak emitiría para cada usuario.

1. Menú **Clients** → `account` → pestaña **Client scopes** → sub-pestaña **Evaluate**.
2. Selecciona el usuario `diego` → genera → en el JSON, busca `resource_access.account.roles`:
   aparece **`manage-account`**.
3. Repite con `marta`: en su token, `resource_access.account.roles` solo trae **`view-profile`** —
   `manage-account` no está. Misma prueba, mismo sitio, y esta vez el resultado es el **contenido del
   token**, no una pantalla.

**Aislamiento entre realms:** vuelve a la consola admin, cambia el desplegable de `curso` a `master`
y abre **Users**. Ni Marta ni Diego existen ahí.

> 🧠 **Pregunta.** ¿Por qué un usuario de `curso` no aparece en `master`?
>
> <details><summary>Ver respuesta</summary>
> Porque un realm es una **frontera dura de aislamiento**, no una carpeta. Los usuarios, roles y
> clientes de un realm no existen en los demás. Por eso un login en `master` y uno en `curso` son dos
> mundos separados.
> </details>

---

## 5. Pruébalo: quita un permiso y mira el efecto

1. Vuelve a `curso` → **Groups** → `redaccion` → **Role mapping** → quita (Unassign) el rol `editor`.
   **No toques a Diego en ningún momento.**
2. Ve a la pestaña donde Diego tiene su Account Console abierta y **refresca** (no hace falta volver a
   iniciar sesión). Los campos del perfil pasan a **solo lectura**.
3. Repite el **Evaluate** del apartado 4 para `diego`: `manage-account` ya no aparece.

> 🧠 **Pregunta.** Diego pierde el permiso solo con refrescar, sin volver a loguearse. ¿Cómo?
>
> <details><summary>Ver respuesta</summary>
> Cada carga de página pide un token nuevo a partir de la sesión activa, y los roles se recalculan en
> cada emisión. No hay un token "para siempre" desde el login. Importante: los tokens no se actualizan
> solos, hay que emitir uno nuevo.
> </details>

---

## 6. Qué entregar

1. Realm `curso` → **Realm settings** → menú **Action** (arriba der.) → **Partial export**.
2. Marca **Export groups and roles** → Export.
3. Entrega el fichero JSON exportado.

---

## Reto extra (si te sobra tiempo)

Crea un rol `baja`, dale el permiso de cliente `account` → `delete-account`, asígnalo a un grupo, mete
un usuario y comprueba la herencia como antes. Entra a su Account Console: ¿ves el botón de borrar
cuenta? Si no… ¿por qué, si el rol está bien puesto? (Pista: en Keycloak, un rol y una *required
action* son dos mecanismos distintos.)

## Si algo falla

- No ves los usuarios/roles que creaste → seguramente tienes `master` en el desplegable en vez de
  `curso`. Cámbialo.
- El contenedor tarda en estar `healthy` → espera 30-40 s la primera vez.
- Empezar de cero (borra realm, usuarios y roles): `docker compose down -v && docker compose up -d`.
