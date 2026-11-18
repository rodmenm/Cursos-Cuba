# H19 — Criptografía SD-JWT para divulgación selectiva y OpenID4VP

**Módulo:** [5 — Identidad descentralizada](../README.md) · **Formato:** Teoría · 60 min
**Lab del módulo:** [Lab 5 — SD-JWT y presentación selectiva](../laboratorio-5-sdjwt-presentacion-selectiva/) (H20)
**Actividad/entregable (cronograma):** Diseño de plantillas de credenciales SD-JWT.

## Objetivo de la hora
Entender la divulgación selectiva (revelar un subconjunto de atributos) y el protocolo que la
transporta. Es la teoría inmediata del Lab 5.

## Contenidos
- **Divulgación selectiva:** compartir solo parte de los datos (p. ej. **verificar mayoría de edad
  sin revelar la fecha de nacimiento**). Se ve sola abriendo un SD-JWT.
- **SD-JWT por dentro:** el payload firmado contiene **hashes**; los **disclosures** viajan aparte,
  separados por `~`. Quitar un disclosure no invalida la firma — el payload firmado no cambia.
- **OpenID4VP** (OpenID for Verifiable Presentations): protocolo de solicitud y presentación
  interactiva de credenciales. **Es el punto de convergencia** de los dos linajes (H18).
- **Fuera de alcance** (para público de cero): revocación y niveles de garantía.

## Conexiones
- Es exactamente lo que ejecuta el **Lab 5**: emitir con 4 atributos, presentar solo `mayor_de_edad`.
- El "mismo token, un disclosure menos, firma válida" es el **momento clave** del Lab 5.

## Preguntas para el aula
- [ ] (a desarrollar) ¿Cómo puede seguir validando la firma si he quitado un dato?

## Pendiente
- [ ] Desarrollar guion de aula / notas del instructor
- [ ] Ejercicio: diseño de una plantilla de credencial SD-JWT (qué atributos, cuáles selectivos)

Fuente: briefing §1 y §2 (Módulo 5); PDF cronograma H19.
