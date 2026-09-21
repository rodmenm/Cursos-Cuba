# Lab 1 — Keycloak, realms y RBAC

**Módulo:** [1 — Zero Trust y ciclo de vida](../README.md).
**Infra:** Keycloak propio de este lab ([`docker-compose.yml`](docker-compose.yml)). Cuando construyamos
el resto de labs de Módulo 3, este servicio se centraliza en `infra/` para que 2, 3.1 y 3.2 lo reutilicen
sin volver a levantarlo.
**Materiales/entregables:** [`materiales/`](materiales/).
**Duración:** 60 min (10 arranque · 25 guiado · 10 romperlo · 10 entregable · 5 colchón).

## Versión

`quay.io/keycloak/keycloak:26.7.4` — última estable a fecha de escritura (verificada). Nota
importante si comparas con guías o repos antiguos: desde Keycloak 26, `KEYCLOAK_ADMIN` /
`KEYCLOAK_ADMIN_PASSWORD` **ya no existen** — se sustituyen por `KC_BOOTSTRAP_ADMIN_USERNAME` /
`KC_BOOTSTRAP_ADMIN_PASSWORD`. Si alguna vez tocas un compose viejo (Keycloak ≤19) no copies esas
variables literalmente, están obsoletas.

## Prerrequisitos

- Docker y Docker Compose.
- Puerto 8080 y 9000 libres.

## Arranque (10 min)

```bash
cp .env.example .env
docker compose up -d
```

1. Esperar a que el healthcheck marque `healthy`:
   ```bash
   docker compose ps
   ```
2. Abrir `http://localhost:8080/` → **Administration Console**.
3. Entrar con las credenciales de `.env` (`admin` / `admin` si no las cambiaste).
4. **Checkpoint visual:** arriba a la izquierda pone `master`. Ese es el realm de
   administración de Keycloak — de aquí sale el momento clave del final del bloque guiado.

## Guiado (25 min)

Los roles no van a ser una etiqueta decorativa: `editor` va a dar permiso **real** de editar el
propio perfil en la Account Console, `lector` se queda en "solo ver". El suelo común
(`default-roles-curso`) se deja a cero para `account` — nada llega gratis, cada rol lleva
explícitamente lo que necesita.

1. **Crear el realm:** desplegable `master` (arriba izq.) → **Create realm** → nombre `curso` → Create.
2. **Crear los roles:** menú lateral **Realm roles** → Create role → `lector` → Save. Repetir con
   `editor`.
3. **Vaciar el suelo por defecto:** **Realm settings** → pestaña **User registration** →
   sub-pestaña **Default roles** (con "Hide inherited roles" marcado) → marcar las filas `account` /
   `manage-account` **y** `account` / `view-profile` → **Unassign**. A partir de aquí, un usuario sin
   rol no puede ni ver ni editar su perfil — el suelo es cero, no "solo ver".
4. **Hacer `lector` compuesto:** abrir el rol `lector` → pestaña **Associated roles** → Assign role
   → filtrar por roles de cliente → `account` → marcar `view-profile` → Assign.
5. **Hacer `editor` compuesto (y jerárquico):** abrir el rol `editor` → **Associated roles** →
   Assign role → esta vez sin filtrar por cliente, buscar el rol de **realm** `lector` → Assign
   (editor "es un" lector, hereda `view-profile` de él) → repetir Assign role, ahora sí filtrando por
   cliente `account` → marcar `manage-account` → Assign.
6. **Crear usuarios:** menú **Users** → Add user → username `marta` → Create. Repetir con `diego`.
7. **Poner contraseña a cada usuario:** pestaña **Credentials** del usuario → Set password →
   desactivar el toggle **Temporary** → Save.
8. **Crear los dos grupos:** menú **Groups** → Create group → `lectura` → Create. Repetir con
   `redaccion`.
9. **Asignar cada rol a su grupo (no a los usuarios):**
   - Abrir `lectura` → pestaña **Role mapping** → Assign role → `lector` → Assign.
   - Abrir `redaccion` → pestaña **Role mapping** → Assign role → `editor` → Assign.
10. **Meter a cada usuario en su grupo:** Users → `marta` → pestaña **Groups** → Join group →
    `lectura`. Users → `diego` → pestaña **Groups** → Join group → `redaccion`.
11. **Comprobar la herencia:** Users → `diego` → pestaña **Role mapping** → desactivar el filtro
    "Hide inherited roles" → debe aparecer `editor` heredado de `redaccion`. Repetir con `marta`:
    debe aparecer `lector` heredado de `lectura`. Ninguno de los dos tiene el rol asignado
    directamente — todo llega por el grupo, que es justo el patrón que evita el *privilege creep* del
    Módulo 1 (asignar a mano usuario a usuario es como se pierde el rastro de quién tiene qué).
12. **Checkpoint de login — la consecuencia real:** abrir una ventana privada →
    `http://localhost:8080/realms/curso/account/` → entrar como `diego` → editar cualquier campo del
    perfil (ej. el nombre) y guardar → funciona.

    > **No lo intentes con Marta.** Con solo `view-profile` (sin `manage-account`), la Account
    > Console v3 no degrada a un modo de solo lectura — directamente no carga y muestra una pantalla
    > de error genérica (401 en `supportedLocales` y en `userProfileMetadata`). Es una limitación real
    > de esta versión de la consola, verificada al montar el lab, no algo que hayamos hecho mal.
    > Enseñarle eso a un alumno da la sensación de que se ha roto todo el entorno, así que no forma
    > parte del guion — se compara de otra forma, en el siguiente paso.

13. **Abrir el token y comparar (el momento "abre el token" de este lab):** menú **Clients** →
    `account` → pestaña **Client scopes** → sub-pestaña **Evaluate** → seleccionar usuario `diego` →
    generar → en el JSON resultante, localizar `resource_access.account.roles`: aparece
    `manage-account`. Repetir con `marta`: en su token generado, `resource_access.account.roles`
    solo trae `view-profile` — `manage-account` no está. Mismo mecanismo, mismo sitio, y esta vez la
    prueba es el contenido del token, no una pantalla que funciona o revienta.
14. **Momento clave — aislamiento entre realms:** volver a la consola admin, cambiar el desplegable
    de `curso` a `master`, abrir **Users**. Ni `marta` ni `diego` existen ahí. Un usuario de `curso`
    no existe en `master`, y viceversa — el realm es una frontera dura, no una carpeta.

## Romperlo (10 min)

1. Volver a `curso` → **Groups** → `redaccion` → **Role mapping** → quitar (Unassign) el rol `editor`.
   No se toca a Diego en ningún momento.
2. Volver a la pestaña donde Diego tiene abierta su Account Console y refrescar la página (no hace
   falta re-login: el token se renueva solo con la sesión activa). Los campos de edición del perfil
   pasan a modo solo lectura.
3. Repetir el Evaluate del paso 13 para `diego`: `manage-account` ya no aparece en
   `resource_access.account.roles`. Mismo token, misma prueba, ahora en la dirección contraria.
4. Pregunta para el aula: *"¿qué pasaría si `redaccion` tuviera 200 personas en vez de una?"* — es
   el argumento a favor de RBAC por grupo frente a asignar roles usuario a usuario.

## Entregable (10 min)

1. Realm `curso` → **Realm settings** → menú **Action** (arriba derecha) → **Partial export**.
2. Marcar **Export groups and roles** → Export.
3. Guardar el JSON descargado en [`materiales/`](materiales/).

## Reto opcional — un tercer rol, sin instrucciones

Para quien termine el entregable antes de tiempo (usa el colchón, no le quita tiempo al resto):

> Crea un rol `baja`. Dale el permiso de cliente `account` → `delete-account`. Asígnalo a un grupo,
> mete un usuario, comprueba la herencia como antes. Entra a su Account Console. ¿Ves el botón de
> borrar cuenta? Si no, ¿por qué, si el rol está bien puesto?

No des la respuesta a menos que se atasquen del todo — la gracia es que descubran por sí mismos que
hace falta activar la required action **Delete Account** (**Authentication** → **Required
Actions**) además del rol: rol y required action son dos mecanismos independientes, y este mismo
patrón reaparece en el Lab 2 con WebAuthn. Si nadie llega, ciérralo tú en el resumen final del lab.

## Colchón (5 min)

Para el atasco típico: alguien se queda mirando `master` y no ve usuarios/roles que creó en
`curso` (realm equivocado en el desplegable), o el contenedor tarda en pasar a `healthy`.

## Reset

Para dejar el entorno limpio antes de un grupo nuevo (borra todo: realm, usuarios, roles):

```bash
docker compose down -v
docker compose up -d
```

Sin el `-v` el volumen `keycloak_data` persiste, que es justo lo que queremos **entre** los labs
1, 2, 3.1 y 3.2 dentro del mismo grupo de alumnos — no hay que reconstruir el realm cada vez.

## Pendiente
- [ ] Decidir si el dominio "editorial" (Marta/Diego, `lectura`/`redaccion`) se mantiene o se cambia
      a otro (ej. hospital, empresa) antes de dar el lab por cerrado.
- [ ] Decidir si se explican en clase, y dónde (¿aquí, en teoría del Módulo 1, o en el Módulo 4?),
      dos cosas que aparecen solas al hacer el lab y que no son ruido:
      - El aviso de **"temporary admin user"** al entrar por primera vez (Keycloak 26 marca como
        temporal el admin creado por bootstrap `KC_BOOTSTRAP_ADMIN_*`, precisamente porque esas
        credenciales suelen vivir en texto plano como en nuestro propio `.env` — engancha con
        Zero Trust del Módulo 1 y con NHI/secretos del Módulo 4).
      - Los parámetros del hash de contraseña en la pestaña Credentials (Argon2id, `memory: 7168`,
        `hashIterations: 5`, `parallelism: 1` — coincide con un preset recomendado por el OWASP
        Password Storage Cheat Sheet; buen gancho para explicar por qué menos iteraciones con
        Argon2 no significa menos seguridad que PBKDF2).

Fuente: [briefing §3, Lab 1](../../../docs/curso-identidad-briefing.md).
