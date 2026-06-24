# Audit Board Framework — Generic Pipeline & Standards

> Este documento es el motor del audit board. No contiene roles ni preguntas de dominio — eso
> vive en el `audit_board_profile.md` del proyecto. Este documento no cambia entre proyectos.

---

## PIPELINE DE EJECUCIÓN PARALELA

### Fase 1 — Agentes paralelos

Lanzar SIMULTÁNEAMENTE en el mismo mensaje de Claude (una llamada al Agent tool por cluster).
El número de clusters, sus nombres, sus roles asignados y sus context bundles están en el profile.

**Prompt estándar para cada agente de Fase 1** (sustituir variables del profile):

```
Eres el agente de auditoría CLUSTER_ID del Board Adversarial del proyecto PROJECT_NAME.
Ejecuta ÚNICAMENTE los roles: LISTA_ROLES. No ejecutes ningún otro rol.

Lee en este orden:
1. CONTEXT_SHARED  ← contexto obligatorio del proyecto (definido en el profile, leer primero)
2. El profile del proyecto — SOLO las secciones de tus roles asignados
3. CONTEXT_BUNDLE de tu cluster (definido en la tabla de asignaciones del profile)
4. Si algún rol requiere leer código adicional, hazlo.

Para cada rol:
- Objetivo y mentalidad
- Análisis exhaustivo del sistema desde la perspectiva de este rol
- Hallazgos críticos (con archivo:línea cuando sea posible)
- Mejoras prioridad alta
- Riesgos existenciales
- Scoring 5 dimensiones (ver sección SCORING de este framework)

Escribe el output completo en: ARCHIVO_OUTPUT
Empieza con: # Auditoría Fase 1 — CLUSTER_NAME — YYYY-MM-DD
```

### Fase 2 — Agente de síntesis

Lanzar cuando todos los outputs de Fase 1 existen en disco.

```
Eres el agente de Síntesis del Board Adversarial del proyecto PROJECT_NAME.

Lee todos los outputs de Fase 1:
[lista de archivos definida en el profile]

Lee también:
- El profile del proyecto — SOLO las secciones SYNTHESIS_ROLES y DEBATES
- CONTEXT_BUNDLE completo (todos los contextos relevantes)

Ejecuta en orden:
1. DEVIL'S_ADVOCATE_ROLE (definido en el profile) — critica los findings de TODOS los clusters
2. SYSTEM_DECOMPOSITION_ROLE (definido en el profile) — análisis cross-cutting
3. ATTRIBUTION_ROLE (definido en el profile) — atribución de problemas por componente
4. DEBATES definidos en el profile (uno por uno, en el formato del framework)
5. META-REVIEW FINAL (ver sección FASE FINAL de este framework)

Escribe el output consolidado en: research/results/audit_board_vX_YYYY-MM-DD.md
```

### Notas operativas

- Los roles de síntesis (Devil's Advocate, etc.) DEBEN ir en Fase 2: critican los outputs de Fase 1.
- Los debates requieren outputs de roles de distintos clusters — solo el agente de síntesis puede hacerlos.
- Si un agente de Fase 1 falla, relanzarlo individualmente antes de iniciar Fase 2.
- Si más de la mitad de los clusters fallan, detener y verificar que los agentes son `general-purpose` (no `Explore`).
- FECHA en nombres de archivo = `YYYY-MM-DD`.

---

## TIERS DE AUDITORÍA

| Tier | Cobertura | Cuándo usar |
|------|-----------|-------------|
| **Quick** | 30-40% de roles (los más críticos) | Tras sesión de cambios importantes de código |
| **Standard** | 50-60% de roles | Mensual / tras hitos importantes / tras PASS formal |
| **Full** | Todos los roles | Pre-transición de fase / trimestral / sistema heredado desconocido |

Los roles incluidos en cada tier se definen en el profile del proyecto.

---

## REGLAS ABSOLUTAS

1. NO asumas que el diseño es correcto. Asume que puede haber errores graves, sesgos, optimizaciones falsas, riesgos ocultos, arquitectura incorrecta, y edge/valor inexistente. No asumas que correcciones pasadas fueron correctas — revísalas.

2. NO seas complaciente. Sé extremadamente crítico, riguroso, escéptico, adversarial, técnico, detallista.

3. Cada rol analiza el sistema desde SU perspectiva exclusiva, ignora presiones políticas, maximiza SU objetivo específico, y critica duramente decisiones incorrectas.

4. Cuando detectes inconsistencias, riesgos, tradeoffs, contradicciones, o mejoras potenciales, documéntalas explícitamente.

5. NO des respuestas superficiales. Quiero profundidad, razonamiento, ejemplos, escenarios de fallo, análisis sistémico, análisis adversarial, y mejoras accionables.

6. NO simplifiques. Si hay ambigüedad: plantea hipótesis, evalúa múltiples escenarios, analiza implicaciones.

7. Cada rol revisa también las conclusiones de los roles anteriores, critica posibles errores de otros roles, y genera debate técnico interno.

> El profile del proyecto puede añadir reglas adicionales específicas del dominio (ver sección REGLAS_ADICIONALES del profile).

---

## FORMATO DE EJECUCIÓN POR ROL

Para cada rol asignado:

1. Explica brevemente: objetivo, prioridades, y mentalidad.
2. Realiza un análisis exhaustivo del sistema.
3. Identifica: riesgos, errores, vulnerabilidades, contradicciones, limitaciones, falsos supuestos, dependencias peligrosas, problemas futuros, cuellos de botella.
4. Propón: mejoras concretas, refactors, mitigaciones, validaciones, rediseños, y prioridades.
5. Critica explícitamente: decisiones previas y posibles autoengaños del diseño.
6. Al finalizar: sección **"Hallazgos Críticos"**, sección **"Mejoras Prioridad Alta"**, sección **"Riesgos Existenciales"**.
7. Aplica scoring 5 dimensiones (ver sección siguiente).

---

## SCORING POR ROL — 5 DIMENSIONES

Al finalizar cada rol, puntuar en escala 1-10 con justificación de 1 línea:

- **Correctitud**: ¿Las afirmaciones son factualmente verificables en el código/datos?
- **Completitud**: ¿Se cubrieron todos los aspectos del dominio del rol sin lagunas obvias?
- **Adversarialidad**: ¿El análisis empujó contra las asunciones favorables, o fue complaciente?
- **Accionabilidad**: ¿Los hallazgos se traducen en acciones concretas con criterio de éxito?
- **Independencia**: ¿El análisis aportó perspectiva propia o repitió conclusiones anteriores?

---

## DEBATES INTER-ROL

### Formato de cada debate

> (1) **Posición inicial del ROL A** — sus evidencias y argumentos principales
> (2) **Respuesta del ROL B** — contraargumentos con evidencia específica
> (3) **Réplica del ROL A** — qué puntos de B son convincentes, qué puntos no tienen respuesta
> (4) **Veredicto conjunto** — posición más sólida + acción recomendada

Los debates específicos (qué roles debaten qué tensión) se definen en el profile del proyecto.
Recomendación: 2-3 debates sobre las tensiones más importantes del sistema — no más.

---

## PLANTILLA DE ROL (para el profile del proyecto)

Cada rol en el profile sigue esta estructura:

```
### ROL N — [Título del Especialista]

**Objetivo:** Una frase que define qué analiza este rol y desde qué perspectiva exclusiva.

**Mentalidad:** Cómo debe pensar el rol — adversarial / escéptico / constructor / técnico / fiscal.

**Nota de posicionamiento (opcional):** Por qué este rol va en este cluster / por qué en esta fase.

**Preguntas específicas del proyecto:**
- Pregunta concreta con datos reales del sistema (no preguntas genéricas de manual)
- Incluir umbrales, nombres de componentes, comportamientos observados, incidentes conocidos
- Referenciar archivos o secciones específicas cuando sea posible
```

Guías para escribir buenas preguntas:
- Malo: "¿El sistema tiene buena seguridad?"
- Bueno: "El endpoint `/api/execute` no valida el campo `amount` antes de llamar a `broker.submit()`. ¿Bajo qué condiciones puede enviarse una orden con amount negativo o cero, y qué consecuencia tiene?"
- Las preguntas genéricas producen análisis genérico. Las preguntas específicas producen hallazgos accionables.

---

## FASE FINAL — META-REVISIÓN GLOBAL

El agente de síntesis, tras completar los roles de síntesis y los debates, ejecuta:

1. **Análisis cruzado consolidado**: contradicciones entre clusters, tensiones estructurales, tradeoffs inevitables, riesgos sistémicos.

2. **Listas de salida**:
   - TOP 20 riesgos críticos
   - TOP 20 mejoras prioritarias
   - TOP 10 riesgos existenciales
   - TOP 10 quick wins
   - TOP 10 decisiones arquitectónicas más peligrosas

3. **Roadmap**: orden recomendado de implementación, secuencia de refactors, plan de endurecimiento.

4. **Evaluación de madurez**: percentil institucional del sistema (0-25% / 25-50% / 50-75% / 75-100%) con justificación.

5. **Síntesis de roles de Fase 2**: cada rol de síntesis (Devil's Advocate, System Decomposition, Attribution) tiene una sección de síntesis propia en la meta-revisión.

6. **Síntesis de debates**: qué debate produjo el desacuerdo más material, qué posición ganó con mayor solidez empírica, qué punto quedó sin resolver.

7. **Veredicto final**: el comité, actuando como evaluador extremadamente escéptico, responde:
   > "¿Confiaríamos en este sistema para su propósito declarado con las consecuencias reales que implica?"
   > Responde: SÍ / NO / PARCIALMENTE — con justificación brutal.

---

## IMPORTANTE

Durante toda la revisión:
- Piensa paso a paso
- Muestra razonamiento profundo
- Cuestiona supuestos
- Busca contradicciones
- Prioriza rigor sobre positividad

NO optimices por agradar. Optimiza por encontrar la verdad y maximizar robustez.
