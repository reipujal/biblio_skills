# CHECKLIST — revisión antes de dar por hecha una skill

## Justificación
- [ ] ¿Cumple las cuatro condiciones (reutilizable · dominio estable · aislar mejora
      mantenimiento · reduce complejidad)?
- [ ] ¿Ha pasado la compuerta de promoción (validada 2-3 veces en proyectos reales)?
- [ ] ¿Podría esto reutilizar/extender una skill existente en lugar de ser nueva?

## Estructura
- [ ] ¿Tiene `SKILL.md`? ¿Está por debajo de ~500 líneas?
- [ ] ¿Cada documento tiene una única responsabilidad?
- [ ] ¿Algún documento se puede eliminar? ¿Cada uno está justificado?
- [ ] ¿Hay carpetas creadas "por si acaso"? (eliminarlas)

## Disparo (`description`)
- [ ] ¿Describe QUÉ hace y CUÁNDO usarse, con contextos concretos?
- [ ] ¿Tiene tono suficientemente insistente para no infra-disparar?
- [ ] ¿Está acotada para no sobre-disparar?

## Conocimiento
- [ ] ¿Hay conocimiento duplicado? ¿Las reglas comunes se **referencian** en vez de
      copiarse?
- [ ] ¿Es independiente del proveedor de LLM (salvo que sea explícitamente específica)?
- [ ] ¿No introduce herencia/jerarquía entre skills?

## Mantenibilidad
- [ ] ¿Se entiende la estructura dentro de seis meses?
- [ ] ¿Otro ingeniero sabría dónde extenderla?
- [ ] ¿Las decisiones importantes están en `DECISIONS.md`?
