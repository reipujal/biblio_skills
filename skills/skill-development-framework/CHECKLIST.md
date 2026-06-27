# CHECKLIST — revisión antes de dar por hecha una skill

## Justificación
- [ ] ¿Cumple las cuatro condiciones (reutilizable · dominio estable · aislar mejora
      mantenimiento · reduce complejidad)?
- [ ] ¿Ha pasado la compuerta de promoción (validada 2-3 veces en proyectos reales)?
- [ ] ¿Podría esto reutilizar/extender una skill existente en lugar de ser nueva?

## Estructura
- [ ] ¿Tiene `SKILL.md`? ¿Está por debajo de ~500 líneas?
- [ ] ¿El `name` del frontmatter coincide con la carpeta y cumple kebab-case Agent Skills
      (`a-z`, `0-9`, guiones simples, máximo 64 caracteres)?
- [ ] ¿Cada documento tiene una única responsabilidad?
- [ ] ¿Algún documento se puede eliminar? ¿Cada uno está justificado?
- [ ] ¿Hay carpetas creadas "por si acaso"? (eliminarlas)

## Disparo (`description`)
- [ ] ¿Describe QUÉ hace y CUÁNDO usarse, con contextos concretos?
- [ ] ¿Está por debajo de 1024 caracteres?
- [ ] ¿Tiene tono suficientemente insistente para no infra-disparar?
- [ ] ¿Está acotada para no sobre-disparar?

## Recursos
- [ ] ¿Los recursos adjuntos se referencian con rutas relativas desde la raíz de la skill?
- [ ] Si hay scripts reutilizables, ¿viven en `scripts/`, no requieren interacción y explican
      su uso con `--help` o una sección breve en `SKILL.md`?
- [ ] Si hay plantillas o assets grandes, ¿se cargan bajo demanda en vez de copiarse dentro
      de `SKILL.md`?

## Conocimiento
- [ ] ¿Hay conocimiento duplicado? ¿Las reglas comunes se **referencian** en vez de
      copiarse?
- [ ] ¿Es independiente del proveedor de LLM (salvo que sea explícitamente específica)?
- [ ] ¿No introduce herencia/jerarquía entre skills?

## Mantenibilidad
- [ ] ¿Se entiende la estructura dentro de seis meses?
- [ ] ¿Otro ingeniero sabría dónde extenderla?
- [ ] ¿Las decisiones importantes están en `DECISIONS.md`?

## Validación mínima
- [ ] ¿Se probó con 2-3 prompts reales, incluyendo al menos un caso borde o near miss?
- [ ] ¿La skill aporta valor frente a resolver la tarea sin skill?
- [ ] ¿`python scripts/build_index.py --check` pasa después de los cambios?
