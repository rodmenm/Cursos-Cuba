# Curso de Identidad Digital, Autenticación y Autorización — Briefing completo

Documento de contexto para construir los componentes técnicos del curso.
Recoge el análisis del programa, las decisiones tomadas y el diseño de los 6 laboratorios.

---

## 0. Contexto

Curso de 20 horas (14h teoría + 6h laboratorios) sobre identidad digital, autenticación y
autorización. **Público que llega de cero**, pese a que el programa original se titula
"Adiestramiento Experto" y su rúbrica evalúa a nivel experto.

Evaluación según el programa: portafolio de laboratorios 60%, capstone final 40%.

Restricción operativa acordada con dirección: **todo en Docker, el alumno trabaja con
interfaces, no escribe backend**. La justificación no es solo de tiempo: un alumno de cero
que escribe Node no aprende OAuth, aprende a pelearse con npm.

Riesgo de esa decisión: si todo es clicar en consolas, sale un curso de Keycloak y no de
identidad. **Antídoto:** cada laboratorio termina en el mismo sitio, abrir el token y mirarlo
(DevTools, pestaña de red, decodificar el JWT, señalar qué campo exige qué RFC).

---

## 1. Crítica al programa original

### Se mantiene

**Las horas de laboratorio no cuadran.** Seis labs de una hora. Un alumno novato no tarda
menos en montar endpoints WebAuthn, tarda más: los 60 minutos se los comen Docker, las
versiones de Node y un CORS mal puesto. O se entrega el entorno hecho y el lab es
"arranca, observa, cambia algo y mira qué se rompe", o el lab no existe.

**El módulo 5 mezcla dos linajes como si fueran uno.** Presenta SSI (DIDs, documentos DID,
resolución en registros verificables) y a continuación eIDAS 2.0 / EUDI Wallet como
continuación natural. El ARF no usa DIDs: la cadena de confianza es X.509 sobre trust
lists, y los formatos son SD-JWT VC e ISO mdoc, no VCDM 2.0 con Data Integrity Proofs.
Convergen en el protocolo (OpenID4VP), no en el modelo de confianza. No es un problema de
profundidad: corregirlo cuesta una frase y evita que el alumno salga creyendo algo falso.

**La bibliografía es floja.** Medium, blogs de vendor, páginas de cursos. Sustituir por RFCs
y specs: RFC 9700 (OAuth Security BCP), RFC 9449 (DPoP), RFC 8705 (mTLS), RFC 7662
(introspección), WebAuthn L3, el propio ARF. Es el arreglo más barato y el que más sube la
credibilidad.

**Incoherencia de nivel.** El programa promete nivel experto y el público llega de cero. O se
ajusta el lenguaje a lo que es (introductorio-práctico y ambicioso), o se sube el requisito de
entrada. No puede ser las dos cosas.

**Detalle de traducción:** SSI es identidad *auto*soberana. "Identidad Soberana" a secas suena
a soberanía estatal, que es casi lo contrario.

### Se descarta por nivel del público

OPA/Cedar/AuthZEN, Token Exchange (RFC 8693), SPIFFE/SPIRE. Para alguien de cero es ruido.
Como mucho, una diapositiva de "esto existe y es el siguiente paso" al cierre del módulo 4.

### Recortes propuestos para comprar horas

- **3.6 y 3.7** (alg:none, confusión de algoritmo, DPoP, mTLS): 15 minutos de "por qué el token
  robado sigue funcionando y qué se hace al respecto". Sin lab.
- **Lab 2**: fuera el backend WebAuthn a mano. Keycloak lo trae nativo.
- **Lab 5**: fuera el SDK. Emitir con herramienta ya hecha y abrir el token.
- **Módulo 4**: de 3h a 2h (es el más abstracto para gente sin contexto organizativo). La hora
  liberada va al módulo 3, que es donde se ahogan.

### Decisión transversal

**Un único `docker-compose.yml` para todo el curso.** Keycloak levantado en el lab 1 y
reutilizado en el 2, 3 y 4. Cada setup nuevo son 30 minutos perdidos y tres alumnos
descolgados.

---

## 2. Contenido teórico, resumen por módulo

### Módulo 1. Zero Trust y ciclo de vida

- **Zero Trust**: verificar explícitamente, asumir la brecha, mínimo privilegio. La red deja de
  ser una credencial. Referencia NIST SP 800-207. Vocabulario: PDP (decide), PEP (ejecuta,
  normalmente el gateway). Señales: dispositivo gestionado, geolocalización, hora, comportamiento.
- **IAAA**: identificación, autenticación, autorización, accounting. Analogía útil: el DNI en el
  hotel te autentica, la tarjeta de la habitación te autoriza, caducan distinto.
- **Atributos**: inherentes (fecha de nacimiento), acumulados (historial), asignados (rol). Define
  quién puede cambiarlos y cuánto duran.
- **JML**: Joiner (alta desde RRHH, fuente de verdad), Mover (punto débil: permisos que se suman y
  no se restan, *privilege creep*), Leaver (desaprovisionamiento; caso peligroso, el contratista
  externo que no aparece en la baja de RRHH). Métrica: tiempo entre baja efectiva y cierre.
- **RBAC** (permisos por rol, audita bien, *role explosion* con excepciones), **ABAC** (decisión
  calculada con atributos de sujeto, recurso, acción y entorno; flexible, difícil de auditar),
  **PBAC** (políticas declarativas externalizadas). En la práctica se combinan.

### Módulo 2. Autenticación robusta

- **Por qué fallan los factores clásicos**: SMS (SIM swapping), TOTP (phishable vía proxy inverso
  tipo Evilginx en tiempo real), push (fatiga). Patrón común: todos son un secreto que el usuario
  puede entregar a un tercero sin darse cuenta.
- **FIDO2** = WebAuthn (API del navegador) + CTAP (protocolo navegador ↔ autenticador). Registro:
  par de claves nuevo, privada se queda dentro. Login: reto aleatorio firmado, verificado con la
  pública. Nunca viaja un secreto reutilizable.
- **Origin binding**: la resistencia al phishing no viene de la biometría, viene de que el
  autenticador incluye el origen en lo que firma. En `banc0.com` no existe credencial que ofrecer.
  La biometría solo desbloquea localmente.
- **Passkey sincronizada** (iCloud/Google, recuperable) vs **vinculada al dispositivo** (llave
  física, no se copia, obligatoria en entornos regulados).
- **Step-up**: ver saldo pide menos que transferir. En OIDC se pide con `acr_values` y se comprueba
  en los claims `acr` y `amr`.

### Módulo 3. Federación y microservicios

- **OAuth 2.1**: cuatro roles (propietario, cliente, servidor de autorización, servidor de
  recursos). Es delegación, no login. 2.1 elimina implicit (token en la URL, queda en historial y
  logs) y ROPC (la app maneja la contraseña). PKCE obligatorio.
- **OIDC**: el **ID token** es para el cliente, lo consume y lo tira. El **access token** es para la
  API y el cliente lo trata como opaco. Confundirlos y mandar el ID token a la API es el error
  número uno. Scope es lo que la app pide, claim lo que el token afirma, `aud` impide que un token
  valga en otro servicio.
- **Edge authentication**: el gateway valida una vez en el borde. **Phantom token**: fuera circula
  un token opaco, el gateway lo canjea vía introspección (RFC 7662) por un JWT firmado interno.
- **BFF**: el SPA no guarda tokens en JS porque cualquier XSS los roba. Backend propio guarda el
  token, al navegador solo cookie HttpOnly + Secure + SameSite.
- **JWT**: header (alg, kid), payload, firma. Base64URL no es cifrado. HS256 simétrica (quien valida
  puede emitir, no escala). RS256/ES256 asimétricas. JWKS publica las claves públicas, `kid` permite
  rotar sin corte.
- **Ataques**: `alg: none`; confusión de algoritmo (cambiar RS256 por HS256 y firmar con la pública
  como secreto, se evita fijando el algoritmo esperado en el validador). El JWT no se revoca por
  diseño; lista de `jti` en Redis reintroduce estado.
- **Sender-constrained**: el bearer es efectivo, quien lo tiene lo gasta. mTLS y DPoP lo atan a una
  clave. DPoP en navegador, mTLS backend a backend.

### Módulo 4. PAM e identidades de máquina

- **IGA**: certificación periódica de accesos, compensa el fallo de la M del JML. Problema real:
  *rubber stamping*.
- **PAM**: bóveda (nadie conoce root, se rota al devolver), proxy de sesión (conectas al proxy, que
  abre y graba), aislamiento del equipo del admin.
- **JIT** elimina la permanencia (pides, se aprueba, expira). **JEA** elimina el exceso de alcance
  (tres comandos, no una shell). Se aplican juntos.
- **NHI**: tokens de CI/CD, claves de API, certificados de servicio. Mayoría frente a las humanas,
  sin dueño, sin rotación, hardcodeadas. Solución operativa: secretos dinámicos con TTL corto.

### Módulo 5. Notas para público de cero

- Cuesta entender **por qué** hace falta, no cómo funciona. Anclar en el problema concreto: hoy,
  para demostrar mayoría de edad, entregas el DNI entero.
- El triángulo emisor/titular/verificador se entiende rápido. Lo que no entra es que el verificador
  no llame al emisor. Pararse ahí.
- La divulgación selectiva se ve sola abriendo un SD-JWT.
- Los dos linajes (W3C con DIDs / europeo con X.509 y trust lists) en una frase y una diapositiva.
- Dejar fuera revocación y niveles de garantía.

---

## 3. Diseño de los laboratorios

Reparto de los 60 minutos: 10 de arranque, 25 guiados, 10 de romperlo, 10 de entregable,
5 de colchón.

### Lab 1 — Keycloak, realms y RBAC

**Montaje:** compose con Keycloak (tag fijo) y `start-dev --import-realm`, con `./realms` montado
en `/opt/keycloak/data/import`. Realm exportado vacío pero **con el cliente ya creado**, para que el
lab 3.1 no dependa de que acertaran aquí.

**El alumno:** levanta el stack, entra a la consola admin, crea el realm `curso`, dos usuarios, los
roles `lector` y `editor`, el grupo `redaccion` con `editor` asignado, mete un usuario en el grupo y
comprueba la herencia.

**Momento clave:** el realm es una frontera de aislamiento. Un usuario del realm master no existe en
`curso`. Se pilla mirando dos consolas de login distintas.

**Romperlo:** quitar el rol del grupo y ver que el usuario lo pierde sin tocar al usuario.

**Entregable:** export del realm en JSON con roles y grupos dentro.

### Lab 2 — WebAuthn sin escribir backend

**Montaje:** el mismo Keycloak. Probar antes en un portátil igual al del aula.

**El alumno:** copia el flow `browser`, lo pone como passwordless, activa la política WebAuthn del
realm y añade la required action de registro. Antes de probar abre DevTools → More tools → WebAuthn
y activa el **autenticador virtual** (CTAP2, resident keys y user verification activadas). Registra
la passkey y vuelve a entrar sin contraseña.

> Sin el autenticador virtual este lab se muere en tres máquinas de veinte (portátiles sin Touch ID
> ni llave física). Es obligatorio.

**Momento clave:** el panel del autenticador virtual lista las credenciales creadas con su ID y su
contador. Prueba visual de que la privada vive en el autenticador y de que hay una credencial por
dominio.

**Romperlo:** borrar la credencial del panel y ver que el login es imposible aunque el usuario
exista. Da pie a hablar de recuperación de cuenta, que es el problema de verdad de passwordless.

**Entregable:** captura del panel con la credencial, más una frase explicando por qué no es phishable.

### Lab 3.1 — SPA con PKCE

**Montaje:** `index.html` estático con keycloak-js servido por nginx en el compose. Nada de Node.
`pkceMethod: 'S256'`, arranque con `check-sso`. Registrar `http://localhost:8081/*` como redirect URI
válida en el cliente público.

**El alumno:** login con la pestaña de red abierta y *preserve log* activado. Sigue la secuencia:
petición a `/auth` con `code_challenge` y `code_challenge_method=S256`, retorno con `code`, POST a
`/token` con el `code_verifier` en claro.

**Momento clave:** poner los dos valores uno al lado del otro y calcular el SHA-256 del verifier en
base64url para comprobar que da el challenge. Única vez en el curso que tocan cripto a mano, dos
minutos.

**Romperlo:** interceptar el `code` y reintentar el canje desde curl sin el verifier correcto. El
servidor lo rechaza: el código robado no vale sin la prueba de que eres quien lo pidió.

**Entregable:** las dos peticiones capturadas y el access token decodificado con `iss`, `aud` y `exp`
señalados.

### Lab 3.2 — Gateway, autenticación en el borde y cabeceras inyectadas

**Decisión:** se descarta APISIX (modelo mental de rutas, upstreams, plugins y admin API demasiado
costoso de aprender). **Se usa oauth2-proxy**: un binario con un solo propósito y configuración plana.

```
oauth2-proxy:
  image: quay.io/oauth2-proxy/oauth2-proxy:v7.6.0
  command:
    - --provider=keycloak-oidc
    - --oidc-issuer-url=http://keycloak:8080/realms/curso
    - --client-id=gateway
    - --client-secret=...
    - --cookie-secret=...          # 32 bytes, base64
    - --email-domain=*
    - --http-address=0.0.0.0:4180
    - --upstream=http://whoami:80
    - --pass-authorization-header=true
    - --set-xauthrequest=true
    - --skip-provider-button=true
```

Detrás, `traefik/whoami`, que solo imprime las cabeceras que recibe.

**Matiz a conocer:** oauth2-proxy está pensado para sesiones de navegador, no para llamadas de API
con Bearer. Admite `--skip-jwt-bearer-tokens=true`, pero su flujo natural es cookie. Consecuencia:
es un lab más de "proxy de autenticación" que de "API gateway", y se pierde la introspección de token
opaco. Con público de cero, ese matiz se explica en pizarra en tres minutos.

**Alternativa descartada:** Traefik con middleware `jwt` (valida contra JWKS sin código, pero está
en la edición de pago; en la community habría que montar `forwardAuth`, otra pieza más).

**El alumno:** pide al backend sin sesión y recibe 401. Se autentica y recibe 200 más el volcado de
cabeceras.

**Momento clave:** el alumno no ha puesto ninguna cabecera y aparecen `X-Auth-Request-User` y
`X-Auth-Request-Email` en la respuesta del whoami. Las ha inyectado el gateway.

**Romperlo:** editar el payload del JWT en el decodificador y ver que la firma no cuadra. Dejar
expirar el token y ver el 401 por `exp`. Si da tiempo, apagar Keycloak y comprobar el efecto, que es
el argumento a favor de validar localmente.

**Entregable:** las tres respuestas (sin sesión, válida, token manipulado) y la cabecera inyectada.

> **Fallo que causa el 90% de los problemas en este lab:** `--oidc-issuer-url` tiene que resolver
> igual desde el contenedor y desde el navegador. El token se emite para `localhost:8080` pero el
> gateway resuelve `keycloak:8080` y la validación falla por issuer mismatch. Arrancar Keycloak con
> `KC_HOSTNAME=keycloak` y añadir `keycloak` al `/etc/hosts` de los alumnos, o usar la misma URL en
> ambos lados. Probarlo en frío una vez, borrando volúmenes, antes de la clase.

### Lab 4 — Acceso efímero con Vault

Sustituye al lab de PIM del programa original: PIM es Entra ID (nube, tenant, licencia P2), no hay
contenedor.

**Montaje:** Vault en modo dev con token root fijo, más Postgres en el compose. Habilitar el motor
`database`, configurar la conexión y crear un rol con TTL por defecto de 60 segundos.

**El alumno:** pide credenciales al rol, recibe usuario y contraseña generados al momento, conecta a
Postgres y funciona. Espera el TTL, reintenta y falla. Pide otras y ve que el usuario es distinto.

**Momento clave:** el usuario de base de datos no existía antes de pedirlo y no existe un minuto
después. Eso es JIT y es también la respuesta a NHI: no hay secreto que rotar porque no hay secreto
persistente.

**Romperlo:** revocar el lease a mano antes de que expire y ver que la sesión abierta se corta.
Introduce revocación frente a expiración, mismo debate que el JWT del módulo 3.

**Entregable:** las dos credenciales distintas, la conexión correcta y el fallo tras el TTL, con la
hora visible.

### Lab 5 — SD-JWT y presentación selectiva

**Montaje:** stack emisor y verificador con interfaz web empaquetado en el compose, más un
decodificador de SD-JWT. Verificar versiones la semana anterior, el ecosistema se mueve rápido.
Salida de emergencia si algo se ha movido: hacerlo todo contra un decodificador con credenciales de
ejemplo preparadas de antemano, que pedagógicamente pierde poco.

**El alumno:** emite una credencial con cuatro atributos (nombre, fecha de nacimiento, nacionalidad,
mayor de edad), abre el token crudo y localiza los hashes en el payload y los disclosures separados
por `~`. Luego presenta al verificador revelando solo `mayor_de_edad`.

**Momento clave:** el mismo token dos veces, con un disclosure quitado. El payload firmado es
idéntico, la firma sigue validando, el dato ya no está.

**Romperlo:** quitar un disclosure que el verificador exige y ver que rechaza la presentación. Cierre
del curso: enseñar que el verificador ha validado sin hablar con el emisor en ningún momento.

**Entregable:** los dos tokens, la política del verificador y una frase sobre qué datos ha visto y
cuáles no.

---

## 4. Trabajo de preparación (checklist)

1. **Un repo, un compose, un realm exportado.** Todo el curso sobre la misma instancia de Keycloak.
2. **Fijar tags de imagen.** Nada de `:latest`: la consola de Keycloak cambia entre versiones y las
   capturas y el guion dejan de coincidir.
3. **Resolver el issuer antes de la clase** (ver aviso del lab 3.2).
4. **Plan sin red.** Veinte personas haciendo pull de Keycloak a la vez en el wifi del centro no
   termina bien. Imágenes precargadas o registry local.
5. **Guion clic a clic con salida esperada** en cada paso, y comando de reset. El que se descuelga en
   el minuto 10 no vuelve solo.
6. **Definir el entregable de cada lab** (el portafolio es el 60%). Captura del token decodificado
   con dos campos señalados vale más que captura de la pantalla de configuración.
7. **Paso de romperlo al final de cada lab.** Cinco minutos, sin escribir código, y es lo único que
   separa configurar de entender.
