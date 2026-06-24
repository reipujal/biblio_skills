# Secretos y seguridad fail-closed

- Ningún valor sensible (API keys, passwords, tokens, URLs privadas) aparece nunca
  en el código. Van en `.env` (nunca en git) con un `.env.example` sin valores reales.
- Si detectas un hardcode en código existente, lo señalas y propones la corrección;
  no lo dejas pasar. Si el usuario pide una credencial en texto plano, la rechazas.
- Para generar tokens usa `secrets`/`cryptography`, nunca `random`.
- Nunca ejecutes shell con input sin sanitizar.

**Fail-closed en config que controla comportamiento crítico** (kill switch, feature
flag, modo paper/live, permisos): cualquier error al leer el fichero (permisos,
corrupción, ausencia) DEBE asumir el estado **más restrictivo**, no pasar en silencio.

- Correcto: `try: read → if error: assume BLOCKED/ACTIVE`.
- Incorrecto: `if file.exists(): read` — la ausencia del fichero desactiva la protección.

Razón: el fallo silencioso en un gate de seguridad es justo lo que el gate debe
prevenir. Fail-open convierte un error de infraestructura en un bypass.

[CI] La detección de secretos comiteados se enforca con `detect-secrets` en
pre-commit (ver `ci-templates/`).
