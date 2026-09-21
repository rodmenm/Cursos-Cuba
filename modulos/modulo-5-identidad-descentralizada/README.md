# Módulo 5 — Identidad descentralizada (SSI, eIDAS 2.0 / EUDI)

## Estructura del módulo

| Carpeta | Contenido |
|---|---|
| [`teoria/`](teoria/) | Guion teórico y notas de aula. |
| [`diapositivas/`](diapositivas/) | Diapositivas del módulo (se generan más adelante). |
| [`recursos/`](recursos/) | Enlaces y bibliografía (ARF, OpenID4VP, SD-JWT VC, ISO mdoc). |
| [`laboratorio-6-sdjwt-presentacion-selectiva/`](laboratorio-6-sdjwt-presentacion-selectiva/) | Lab 6: SD-JWT y presentación selectiva. |

## Contenidos (para público de cero)

- Cuesta entender **por qué** hace falta, no cómo funciona. Anclar en el problema concreto: hoy,
  para demostrar mayoría de edad, entregas el DNI entero.
- Triángulo **emisor / titular / verificador**. Lo que no entra: que el verificador no llama al
  emisor. Pararse ahí.
- La **divulgación selectiva** se ve sola abriendo un SD-JWT.
- **Dos linajes distintos** (una frase, una diapositiva):
  - W3C / SSI: DIDs, documentos DID, VCDM 2.0 con Data Integrity Proofs.
  - Europeo (ARF / EUDI Wallet): confianza X.509 sobre trust lists; formatos SD-JWT VC e ISO
    mdoc. **No usa DIDs.** Convergen solo en el protocolo (OpenID4VP), no en el modelo de confianza.
- Fuera de alcance: revocación y niveles de garantía.

## Matiz importante (corrección al programa original)

SSI es identidad **auto**soberana (self-sovereign). "Identidad Soberana" a secas suena a
soberanía estatal, casi lo contrario.

## Pendiente
- [ ] Diapositivas en [`diapositivas/`](diapositivas/)
- [ ] Guion teórico en [`teoria/`](teoria/)

Fuente: [briefing §2, Módulo 5](../../docs/curso-identidad-briefing.md).
