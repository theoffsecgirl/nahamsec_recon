# Nahamsec Recon Scripts

Colección de *one-liners* y scripts para automatizar el reconocimiento en bug bounty, basados en el workflow de [NahamSec](https://www.youtube.com/watch?v=evyxNUzl-HA).

***

## Contenido del Repositorio

*   **`nahamsec_oneliners.md`**: Fichero Markdown con una colección de *one-liners* y pipelines para distintas fases del reconocimiento.
*   **`nahamsec_quick_oneliner.sh`**: Script de Bash que ejecuta un pipeline de reconocimiento de subdominios.

***

## Descripción Técnica

Este repositorio adapta el workflow de NahamSec para automatizar el descubrimiento de activos. Los scripts encadenan herramientas de reconocimiento (`Subfinder`, `Alterx`, `Httpx`, etc.) mediante *pipes* (`|`) para optimizar el proceso y reducir la intervención manual.

***

## Casos de Uso

### `nahamsec_oneliners.md`

*   **Cuándo usarlo**: Para construir o adaptar cadenas de herramientas complejas. Útil como base de conocimiento y para experimentar con diferentes combinaciones.
*   **Finalidad**: Sirve como referencia técnica para ejecutar flujos de trabajo específicos o modificar parámetros según el objetivo.
*   **Contenido**:
    *   Más de 20 pipelines para descubrimiento, escaneo, *crawling* y filtrado.
    *   Comandos de instalación de dependencias para macOS/Linux.
    *   Ejemplos de configuración de claves de API.

### `nahamsec_quick_oneliner.sh`

*   **Cuándo usarlo**: Para una ejecución rápida del pipeline principal de descubrimiento de subdominios contra un objetivo.
*   **Finalidad**: Implementa la secuencia de descubrimiento, permutación, resolución DNS, *probing* HTTP y *crawling* para obtener una enumeración inicial de activos. Es idóneo para la fase inicial de reconocimiento.

***

## Instrucciones de Uso

### 1. Instalación de Dependencias

Ejecuta este bloque si no tienes las herramientas instaladas:
```bash
brew install nmap massdns
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest
go install -v github.com/projectdiscovery/alterx/cmd/alterx@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/katana/cmd/katana@latest
```

### 2. Ejecución del Script Rápido

```bash
# Asignar permisos de ejecución
chmod +x nahamsec_quick_oneliner.sh

# Ejecutar contra un dominio
./nahamsec_quick_oneliner.sh example.com
```

### 3. Consulta de Pipelines

Para revisar la colección completa de comandos y sus variantes:
```bash
cat nahamsec_oneliners.md
```

***

## Notas Adicionales

*   Revisa el fichero `.md` para entender los parámetros de cada herramienta y adaptar los *pipelines*.
*   Se recomienda expandir la colección con tus propios *one-liners* a medida que desarrolles tu metodología.

***

## Créditos

El workflow está basado en el contenido público de NahamSec. Este repositorio es una adaptación para facilitar su implementación.

