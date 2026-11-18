# Lab 4 — Acceso efímero con Vault (secretos dinámicos)

**Módulo:** [4 — PAM e identidades de máquina](../README.md).
**Infra:** Vault (modo servidor, **no** dev, con almacenamiento en fichero) + Postgres + Adminer
([`docker-compose.yml`](docker-compose.yml)). **Todo por web:** UI de Vault (`:8200`) y Adminer (`:8083`).
**Config:** [`config/`](config/) — `vault.hcl`, seed de Postgres y la SQL de creación del rol.
**Materiales/entregables:** [`materiales/`](materiales/).
**Duración:** ~60 min.

Sustituye al lab de PIM del programa original (PIM es Entra ID: nube, tenant, licencia P2, sin
contenedor).

## Versión

`hashicorp/vault:1.21.3` · `postgres:17-alpine` · `adminer:4.8.1`.

Dos avisos importantes:

- El versionado de Vault está en transición (conviven la línea `1.21.x` y referencias a una `2.2.x`).
  Confirma el tag exacto en Docker Hub al primer `docker compose up` y ajústalo si hiciera falta.
- **Este lab NO usa el modo dev de Vault.** El modo dev auto-inicializa y auto-desella el servidor con
  un token root fijo, y entonces **no se ven** las fases de inicialización, sellado y desellado — que
  aquí son parte del contenido. Por eso Vault va en modo servidor con `storage "file"`: arranca
  sellado y sin inicializar, y el alumno lo inicializa y lo desella con la mano desde la UI.

## Prerrequisitos

- Docker y Docker Compose.
- Puertos **8200** (Vault) y **8083** (Adminer) libres.
- No depende de labs anteriores.

## Idea del lab (tenlo claro tú antes de clase)

Vault **no** guarda una contraseña fija de Postgres para repartirla. Vault se conecta a Postgres como
administrador y, cada vez que alguien pide acceso al rol, **crea en ese instante** un usuario nuevo de
Postgres, con contraseña aleatoria y un *lease* con TTL (60 s). Cuando el TTL expira —o cuando revocas
el lease— Vault **borra** ese usuario. No hay secreto persistente que robar ni que rotar: ese es el
argumento de fondo contra las identidades de máquina (NHI) del Módulo 4.

El alumno toca con la mano dos cosas:

1. **El ciclo de vida de Vault:** *inicialización* (reparto de claves Shamir + token root), *sellado*
   (Vault tiene los datos cifrados pero no puede leerlos) y *desellado* (hay que reunir *k* de *n*
   claves para reconstruir la master key). Al reiniciar el contenedor, Vault se vuelve a sellar.
2. **Los secretos dinámicos:** credenciales efímeras con TTL — acceso *just-in-time*.

## Arranque

```bash
cp .env.example .env
docker compose up -d
```

Vault arranca **sellado y sin inicializar** — es lo esperado, no un fallo. No hay healthcheck verde
que esperar: el siguiente paso se hace desde la UI.

## Guiado

### A. Inicialización, sellado y desellado (el ciclo de vida)

1. Abrir `http://localhost:8200`. Como Vault no está inicializado, la UI muestra el asistente
   **Initialize**.
2. **Inicializar:** Key shares = `5`, Key threshold = `3` → **Initialize**. Vault genera **5 claves de
   desellado (unseal keys)** y un **Initial Root Token**. Hay que descargarlos o copiarlos: sin ellos
   no se puede operar y **no se vuelven a mostrar**.

   > **Momento clave — el reparto de Shamir.** La master key no se guarda entera en ningún sitio: se
   > parte en 5 trozos y hacen falta 3 cualesquiera para reconstruirla. Ni una sola persona con una
   > sola clave puede abrir Vault. Eso es *secret sharing* (Shamir), y es lo que convierte "desellar"
   > en un acto deliberado y repartido, no en un simple arranque.

3. **Desellar:** Vault aparece **Sealed**. Pegar una unseal key → **Unseal**; repetir con una segunda
   y una tercera (distintas). Al alcanzar el umbral (3/3), Vault pasa a **Unsealed**. Fíjate en el
   contador de progreso `1/3 → 2/3 → 3/3`.
4. **Entrar:** método **Token** → pegar el *Initial Root Token* → Sign in.

   > **Pregunta de aula:** ¿qué diferencia hay entre *sellado* y *apagado*? → Sellado = el proceso
   > está vivo y responde, pero no tiene la master key en memoria, así que no puede descifrar nada;
   > apagado = no hay proceso. Reiniciar el contenedor no "apaga el secreto", pero sí vuelve a sellar
   > Vault: habría que volver a desellarlo con las 3 claves.

### B. Motor de secretos dinámicos (database)

5. **Habilitar el motor:** **Secrets** → **Enable new engine** → **Databases** → Next (ruta por
   defecto `database/`).
6. **Configurar la conexión a Postgres** (dentro del motor → Connection / Create):
   - Database plugin: **PostgreSQL**.
   - Connection name: `appdb`.
   - Connection URL: `postgresql://{{username}}:{{password}}@postgres:5432/appdb?sslmode=disable`
   - Username / Password (las credenciales **admin** que Vault usa por dentro): `postgres` / `postgres`.
   - Allowed roles: `efimero`.
   - Si ofrece rotar la contraseña de la raíz al guardar, **no lo marques** en clase (perderías el
     admin que Vault necesita para seguir creando usuarios).

   > **Nota:** estas credenciales admin son el único secreto *fijo* del montaje. Es el precio
   > inevitable: alguien tiene que poder crear usuarios. Pero los clientes que piden acceso ya no las
   > ven nunca — solo ven credenciales desechables.

7. **Crear el rol efímero:** **Roles** → **Create role**:
   - Role name: `efimero`.
   - Connection: `appdb`.
   - TTL = `60s`, Max TTL = `120s`.
   - **Creation statements** (pegar — también en [`config/creation-statement.sql`](config/creation-statement.sql)):
     ```sql
     CREATE ROLE "{{name}}" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
     GRANT SELECT ON ALL TABLES IN SCHEMA public TO "{{name}}";
     ```

### C. Pedir, conectar y caducar

8. **Pedir credenciales:** Roles → `efimero` → **Generate credentials**. Vault devuelve un **username**
   (del estilo `v-root-efimero-xxxx`), un **password** y un **lease** con su duración (60 s). Apunta la
   hora.
9. **Conectar por web (Adminer):** `http://localhost:8083` → System: **PostgreSQL**, Server:
   `postgres`, Username/Password: los recién generados, Database: `appdb` → **Login**. Entra y puede
   leer la tabla `articulos`. **Funciona.**

   > **Momento clave:** ese usuario de Postgres no existía hace diez segundos. Lo acaba de crear Vault
   > al pedirlo, y no estaba escrito en ninguna parte.

10. **Esperar el TTL (60 s) y reintentar:** pasado el minuto, en Adminer cierra sesión e intenta entrar
    de nuevo con las **mismas** credenciales → **falla**. Vault borró el usuario al expirar el lease.
11. **Pedir otras y comparar:** Generate credentials otra vez → el **username es distinto**. Cada
    petición es un usuario nuevo y desechable.

    > **Pregunta de aula:** ¿qué hay que *rotar* aquí? → Nada: no hay contraseña persistente. El
    > problema NHI (secretos hardcodeados que nadie recuerda rotar) desaparece porque no hay secreto
    > que dure más de un minuto.

## Romperlo — revocación frente a expiración

1. Pide credenciales nuevas y entra con ellas en Adminer (deja la sesión abierta).
2. En la UI de Vault → **Access** → **Leases** → localiza el lease bajo `database/creds/efimero` →
   **Revoke**.
   - Si no lo encuentras cómodo en la UI, el equivalente por consola es:
     ```bash
     docker compose exec vault vault lease revoke -prefix database/creds/efimero
     ```
     (requiere exportar antes `VAULT_TOKEN` con el root token dentro del contenedor).
3. Vuelve a Adminer y ejecuta cualquier consulta → la conexión ya no vale: Vault borró el usuario
   **antes** de que expirara el TTL.

   > Esto es **revocación** (acto inmediato y deliberado) frente a **expiración** (pasiva, por TTL).
   > Es el mismo debate del JWT del Módulo 3, pero con el signo cambiado: allí el servidor **no** podía
   > cancelar un token ya emitido; aquí **sí** puede cortar en caliente, porque la credencial es suya y
   > vive en su base de datos, no es un JWT autocontenido que ya circula por ahí fuera.

## Entregable

Dos credenciales distintas (dos *usernames* generados), una captura de la conexión correcta en Adminer
leyendo `articulos`, y el fallo tras el TTL con la hora visible → [`materiales/`](materiales/).

## Preguntas para el aula

| Momento | Pregunta | Respuesta |
|---|---|---|
| Init, paso 2 | ¿Por qué 5 claves y umbral 3, y no una sola contraseña de admin? | La master key se parte (Shamir): ninguna persona sola puede abrir Vault, hacen falta 3 de 5. Reparte la confianza y evita el único punto de fallo humano. |
| Desellado, paso 3 | ¿Dónde está la master key mientras Vault está sellado? | En ningún sitio en claro. Vault tiene los datos cifrados en disco, pero sin reunir el umbral de claves no reconstruye la master key y no puede descifrar nada. |
| Sellado, paso 4 | ¿Reiniciar el contenedor borra los secretos? | No: el storage en fichero persiste. Pero Vault vuelve a arrancar **sellado**; hay que desellarlo otra vez. Sellado ≠ borrado ≠ apagado. |
| Conexión, paso 9 | ¿Quién creó el usuario con el que entra Adminer? | Vault, en el momento de pedirlo, usando sus credenciales admin de Postgres. No lo escribió nadie ni estaba guardado. |
| TTL, paso 10 | ¿Por qué fallan ahora las mismas credenciales? | El lease expiró y Vault ejecutó el borrado del usuario en Postgres. La credencial no "caduca" sola en un fichero: el usuario deja de existir en la base de datos. |
| Romperlo | Revocar vs esperar el TTL, ¿qué diferencia hay? | Expiración = pasiva, llega sola al cumplirse el TTL. Revocación = activa, la fuerzas tú antes de tiempo. En ambos casos Vault borra el usuario; cambia solo el *cuándo* y el *quién* lo decide. |
| Cierre | ¿Qué resuelve esto de las NHI del Módulo 4? | Las NHI son secretos de máquina sin dueño, sin rotación, hardcodeados. Aquí no hay secreto persistente: lo que se reparte caduca en 60 s, así que no hay nada estable que robar ni que haya que acordarse de rotar. |

## Reset

```bash
docker compose down -v
docker compose up -d
```

Borra el volumen de Vault (habrá que **volver a inicializar y desellar**) y el de Postgres. Para un
grupo nuevo es lo correcto: que vean el init y el unseal desde cero.

## Pendiente

- [ ] Enunciado de alumno (`README-ALUMNO.md`) en el formato ensayo/impersonal con cabecera UPM/DIT,
      como en los labs 1–3.
- [ ] Verificar el tag exacto de la imagen de Vault al primer arranque y, si procede, fijarlo.

Fuente: [briefing §3, Lab 4](../../../docs/curso-identidad-briefing.md).
