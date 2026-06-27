# Instalación De Máquina Para Windows

Esta guía es para preparar un PC desde cero después de instalar Antigravity. No
asume que sepas usar Git, PowerShell o una terminal.

La idea es:

```text
Instalar Antigravity
Descargar biblio_skills
Abrir PowerShell dentro de la carpeta de biblio_skills
Ejecutar bootstrap-machine
Reabrir Antigravity
Comprobar que las skills aparecen
```

## 1. Instala Antigravity

Instala Antigravity como instalarías cualquier aplicación de Windows.

Cuando termine, ábrelo una vez para comprobar que arranca. Después puedes
cerrarlo. El bootstrap espera que Antigravity ya exista en la máquina.

## 2. Descarga `biblio_skills`

Tienes dos caminos. Usa el primero si no sabes qué es Git.

### Opción A: Descargar ZIP

1. Abre el navegador.
2. Entra en:

   ```text
   https://github.com/reipujal/biblio_skills
   ```

3. Pulsa el botón verde `Code`.
4. Pulsa `Download ZIP`.
5. Espera a que se descargue.
6. Abre la carpeta `Descargas`.
7. Busca el archivo `biblio_skills-main.zip`.
8. Haz clic derecho sobre el ZIP.
9. Pulsa `Extraer todo...`.
10. Acepta la carpeta que propone Windows.
11. Entra en la carpeta extraída.

Al final debes ver archivos como:

```text
README.md
AGENTS.md
install.ps1
setup
skills
rules
```

Si ves otra carpeta llamada `biblio_skills-main` dentro, entra en ella. La carpeta
correcta es la que contiene `README.md` y `setup`.

### Opción B: Clonar con Git

Usa esta opción solo si ya sabes abrir una terminal y tienes Git instalado.

```powershell
git clone https://github.com/reipujal/biblio_skills.git
cd biblio_skills
```

Si no sabes qué significa esto, usa la opción A.

## 3. Abre PowerShell En La Carpeta Correcta

Este paso es importante. El comando del bootstrap debe ejecutarse dentro de la
carpeta `biblio_skills`.

Hazlo así:

1. Abre la carpeta extraída de `biblio_skills`.
2. Comprueba que ves `README.md`, `AGENTS.md`, `install.ps1` y la carpeta `setup`.
3. En la parte superior del Explorador de Windows hay una barra con la ruta de la
   carpeta. Suele parecerse a:

   ```text
   Este equipo > Descargas > biblio_skills-main
   ```

4. Haz clic una vez dentro de esa barra de dirección.
5. El texto se convertirá en una ruta, por ejemplo:

   ```text
   C:\Users\TuNombre\Downloads\biblio_skills-main
   ```

6. Borra lo que haya escrito en esa barra.
7. Escribe:

   ```text
   powershell
   ```

8. Pulsa `Enter`.

Se abrirá una ventana de PowerShell ya colocada dentro de la carpeta correcta.

Cómo saber que estás en la carpeta correcta:

- La ventana debe mostrar una ruta que acaba en `biblio_skills` o
  `biblio_skills-main`.
- Si escribes `dir` y pulsas `Enter`, deberías ver `README.md`, `install.ps1` y
  `setup`.

## 4. Ejecuta El Bootstrap

En la ventana de PowerShell, copia este comando completo:

```powershell
pwsh -File setup\bootstrap-machine.ps1
```

Pulsa `Enter`.

Qué puede pasar:

- Si Windows pregunta si permites cambios, acepta.
- Si aparece un instalador o una confirmación de `winget`, acepta.
- Si GitHub CLI dice que no estás autenticado, ejecuta:

  ```powershell
  gh auth login
  ```

  Sigue las instrucciones que aparezcan en pantalla. Después vuelve a ejecutar:

  ```powershell
  pwsh -File setup\bootstrap-machine.ps1
  ```

El bootstrap se puede ejecutar más de una vez. Si algo queda a medias, vuelve a
ejecutarlo después de corregir el problema.

## 5. Qué Instala El Bootstrap

El bootstrap prepara herramientas globales de la máquina:

- Git.
- GitHub CLI (`gh`).
- `uv`.
- Node.js/npm.
- Python gestionado por `uv`.
- `pre-commit`.
- `detect-secrets`.
- `ruff`.
- CLIs LLM auxiliares: `codex`, `claude`, `gemini`.
- Poppler para trabajar con PDFs.
- Conexión de `biblio_skills` con Antigravity.

También ejecuta `install.ps1`, que hace que Antigravity vea:

- las rules globales;
- las skills globales;
- workflows por proyecto si se le pasa una ruta de proyecto.

El bootstrap no instala Antigravity. Antigravity va antes.

El bootstrap no instala dependencias de un proyecto concreto. Cada proyecto tiene
su propio entorno y sus propios locks.

## 6. Señal De Éxito

Al final deberías ver algo parecido a:

```text
== Bootstrap completado ==
Reabre Antigravity. En el agente nativo, pide: 'que skills tienes disponibles?'
```

Cuando lo veas:

1. Cierra Antigravity.
2. Vuelve a abrir Antigravity.
3. Usa el panel del agente nativo de Antigravity, no el panel Claude Code.
4. Pregunta:

   ```text
   qué skills tienes disponibles?
   ```

Deberían aparecer skills de `biblio_skills`, por ejemplo:

- `project-bootstrap`
- `project-guardrails-audit`
- `memory-keeper`
- `skill-finder`

## 7. Si Falla

No intentes adivinar a ciegas.

Haz esto:

1. Copia el error completo.
2. Copia también las últimas 20-30 líneas anteriores al error.
3. Abre la guía:

   [Depuración del bootstrap para LLM](bootstrap-debug-llm.md)

4. Pega el error y esa guía a un LLM y dile:

   ```text
   Estoy instalando biblio_skills. El bootstrap falló. Lee esta guía de depuración
   y dime qué comprobación hago primero.
   ```

## 8. Instalar `/cierre` En Un Proyecto

La instalación de máquina deja rules y skills globales. Los workflows, como
`/cierre`, se instalan por proyecto.

Cuando ya tengas un proyecto concreto, ejecuta desde la carpeta `biblio_skills`:

```powershell
pwsh -File setup\bootstrap-machine.ps1 -Project C:\ruta\a\mi-proyecto
```

Ejemplo:

```powershell
pwsh -File setup\bootstrap-machine.ps1 -Project C:\Users\Ana\Desktop\mi-proyecto
```

Después abre ese proyecto en Antigravity, escribe `/` en el agente nativo y busca
`/cierre`.
