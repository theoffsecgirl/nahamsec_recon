```markdown
# NahamSec Recon Automation Scripts

Basado en el vídeo: [Free Recon Course and Methodology For Bug Bounty Hunters](https://www.youtube.com/watch?v=evyxNUzl-HA) de NahamSec.

---

## ¿Qué incluye este repositorio?

- `nahamsec_recon_automation.sh`: Script completo paso a paso para reconocimiento profesional.
- `nahamsec_recon_pipeline.sh`: Serie de pipelines automatizados desde reconocimiento básico hasta avanzado.
- `nahamsec_quick_oneliner.sh`: Pipeline rápido con un solo comando (minuto 16 del vídeo).
- `nahamsec_oneliners.md`: Documentación detallada con todos los comandos y variantes para recon.

---

## Por qué usar estos scripts

Estos scripts automatizan con las mejores herramientas (Project Discovery, nmap, Katana...) el descubrimiento de activos, escaneo, probing y crawling. Ideales para bug bounty hunters que quieren ahorrar tiempo y seguir la metodología recomendada por uno de los mejores del sector.

---

## Requisitos

- macOS o Linux
- Go instalado (`brew install go`)
- Herramientas de Project Discovery (instalación automática recomendada en los scripts)
- nmap instalado (`brew install nmap`)
- wget o curl para descargas

---

## Cómo usar

1. Clona o descarga este repositorio.
2. Da permisos de ejecución a los scripts:

   ```
   chmod +x *.sh
   ```

3. Ejecuta el script deseado con el dominio objetivo. Ejemplos:

   - Recon completo profesional:  
     ```
     ./recon_automation_fixed.sh example.com
     ```
   
   - Pipelines automatizados:  
     ```
     ./pipeline_automation_fixed.sh example.com
     ```
   
   - Pipeline rápido (one-liner):  
     ```
     ./quick_oneliner_fixed.sh example.com
     ```

---

## Descarga y uso de wordlists

Los scripts crean automáticamente la carpeta `wordlists` y descargan las listas principales de subdominios y resolvers para maximizar cobertura.

Si quieres explorar más wordlists puedes clonar directamente SecLists:

```
git clone https://github.com/danielmiessler/SecLists.git wordlists/SecLists
```

---

## Estructura de directorios creada

```
recon_example.com/
├── subdomains/
├── permutations/
├── resolved/
├── ports/
├── httpx/
├── content/
└── wordlists/
```

---

## Créditos

- NahamSec, por la metodología y los tutoriales que inspiran estos scripts.
- Project Discovery, por las herramientas open source de recon.
- Daniel Miessler y comunidad SecLists, por las wordlists.

---

**Aviso legal:** Usa estos scripts solo en entornos autorizados y para fines legales (bug bounty, pentesting autorizado, formación).

---

# Happy Hunting!
```


