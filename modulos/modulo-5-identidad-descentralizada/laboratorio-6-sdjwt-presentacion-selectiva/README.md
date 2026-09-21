# Lab 6 — SD-JWT y presentación selectiva

**Módulo:** [5 — Identidad descentralizada](../README.md).
**Infra:** stack emisor + verificador con interfaz web + decodificador SD-JWT en el compose.
**Config del lab:** [`config/`](config/) (emisor/verificador/decodificador).
**Materiales/entregables:** [`materiales/`](materiales/).

## Montaje
Stack emisor y verificador empaquetado en el compose, más un decodificador de SD-JWT. Verificar
versiones la semana anterior (el ecosistema se mueve rápido). Salida de emergencia: hacerlo todo
contra un decodificador con credenciales de ejemplo preparadas de antemano (pedagógicamente pierde poco).

## El alumno
Emite una credencial con cuatro atributos (nombre, fecha de nacimiento, nacionalidad, mayor de
edad), abre el token crudo y localiza los hashes en el payload y los disclosures separados por `~`.
Luego presenta al verificador revelando solo `mayor_de_edad`.

## Momento clave
El mismo token dos veces, con un disclosure quitado. El payload firmado es idéntico, la firma sigue
validando, el dato ya no está.

## Romperlo
Quitar un disclosure que el verificador exige y ver que rechaza la presentación. Cierre del curso:
el verificador ha validado sin hablar con el emisor en ningún momento.

## Entregable
Los dos tokens, la política del verificador y una frase sobre qué datos ha visto y cuáles no
→ [`materiales/`](materiales/).

## Pendiente
- [ ] Guion clic-a-clic con salida esperada y comando de reset
- [ ] Stack emisor/verificador en [`config/`](config/)

Fuente: [briefing §3, Lab 6](../../../docs/curso-identidad-briefing.md).
