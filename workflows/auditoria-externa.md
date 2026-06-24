# Auditoría externa

Descripción: prepara el contexto para una segunda opinión independiente de un modelo
de otra familia (Gemini / GPT), reservada a decisiones irreversibles o de governance.
Invocar con `/auditoria-externa`. Ver la skill `multi-agent-collaboration`.

Pasos:

1. Confirma que la decisión justifica independencia fuerte (irreversible o governance).
   Si es rutina, no la uses: basta director + ejecutor + CI.
2. Define UNA sola pregunta binaria o claim a verificar, con criterio de aceptación
   (binario o cuantitativo, con referencia externa cuando aplique).
3. Reúne el contexto mínimo necesario (ficheros concretos, no "todo el repo"). Si el
   proyecto es público en GitHub, basta el enlace; si no, exporta los ficheros.
4. El auditor entrega un report con: hallazgo + archivo:línea + severidad + razonamiento.
   Prohibido que proponga implementaciones o specs: identifica, no decide.
5. El director evalúa el report y decide: incorporar, abrir corrección, o descartar
   (con justificación). El auditor no modifica ficheros del proyecto.
