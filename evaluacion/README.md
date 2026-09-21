# Evaluación

- **Portafolio de laboratorios: 60%**
- **Capstone final: 40%**

## Principio de los entregables

> Captura del token decodificado con dos campos señalados vale más que captura de la pantalla de
> configuración. (Briefing §4.6)

El paso de "romperlo" al final de cada lab (5 minutos, sin escribir código) es lo único que separa
configurar de entender.

## Entregables por laboratorio

| Lab | Entregable |
|---|---|
| 1 | Export del realm en JSON con roles y grupos. |
| 2 | Captura del panel del autenticador virtual + frase sobre por qué no es phishable. |
| 3.1 | Las dos peticiones (`/auth`, `/token`) + access token decodificado (`iss`, `aud`, `exp`). |
| 3.2 | Las tres respuestas (sin sesión, válida, token manipulado) + cabecera inyectada. |
| 4 | Dos credenciales distintas, conexión correcta y fallo tras el TTL, con hora visible. |
| 5 | Los dos tokens, la política del verificador y una frase sobre qué datos vio y cuáles no. |

## Pendiente
- [ ] Rúbrica detallada por entregable
- [ ] Ajustar el lenguaje de nivel (el programa promete "experto"; el público llega de cero)

Fuente: [briefing §0 y §4](../docs/curso-identidad-briefing.md).
