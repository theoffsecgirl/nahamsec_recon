# NahamSec One-Liners - Automatizacion con Pipes (Minuto 16 del video)

## Pipeline Basico (Asset Discovery)
```bash
# 1. Subfinder -> AlterX -> DNSX (Minuto 16)
subfinder -d example.com -all -silent | alterx -silent | dnsx -silent

# 2. Desde archivo de subdominios
cat domains.txt | alterx -silent | dnsx -silent

# 3. Pipeline completo basico
subfinder -d example.com -all -silent | alterx -silent | dnsx -silent -o resolved_domains.txt
```

## Pipeline Avanzado con Port Scanning
```bash
# 4. Agregar Nmap al pipeline
subfinder -d example.com -all -silent | alterx -silent | dnsx -silent | nmap -iL - --top-ports 1000

# 5. Con output a archivo
cat domains.txt | alterx -silent | dnsx -silent | tee resolved.txt | nmap -iL - -oG ports.txt
```

## Pipeline con HTTP Probing
```bash
# 6. HTTPX para information gathering (Minuto 16+)
cat resolved.txt | httpx -silent -title -status-code -content-length

# 7. Pipeline completo hasta HTTP
subfinder -d example.com -all -silent | alterx -silent | dnsx -silent | httpx -silent -title -sc -cl

# 8. Con mas opciones de HTTPX
cat domains.txt | alterx -silent | dnsx -silent | httpx -silent -title -sc -cl -location -fr
```

## Pipeline con Content Discovery
```bash
# 9. Agregar Katana para crawling
cat resolved.txt | httpx -silent | katana -jc -silent -d 3

# 10. Pipeline completo end-to-end
subfinder -d example.com -all -silent | alterx -silent | dnsx -silent | httpx -silent | katana -jc -silent

# 11. Con JavaScript parsing avanzado
cat domains.txt | alterx -silent | dnsx -silent | httpx -silent | katana -jsl -xhr -aff -silent
```

## Pipeline PayPal Example (Minuto 30 del video)
```bash
# 12. Ejemplo con Chaos/Subfinder + filtro API
subfinder -d paypal.com -all -silent | grep -i api | alterx -silent | dnsx -silent | nmap -iL - --top-ports 100

# 13. Con HTTPX y output
chaos -d paypal.com -silent | grep -i api | alterx -silent | dnsx -silent | httpx -silent -title -sc -cl -o paypal_recon.txt
```

## One-Liners para Diferentes Escenarios

### Para Bug Bounty Programs
```bash
# 14. Recon completo para un programa
echo "target.com" | subfinder -all -silent | alterx -silent | dnsx -silent | httpx -silent -title -sc | katana -jc -silent

# 15. Con autenticacion (cookies)
echo "target.com" | subfinder -all -silent | alterx -silent | dnsx -silent | httpx -silent | katana -H "Cookie: session=value" -jsl -xhr
```

### Para Multiples Dominios
```bash
# 16. Desde lista de dominios
cat scope.txt | xargs -I{} subfinder -d {} -all -silent | alterx -silent | dnsx -silent | httpx -silent

# 17. Parallel processing
cat scope.txt | parallel -j10 "subfinder -d {} -all -silent | alterx -silent | dnsx -silent | httpx -silent"
```

### Optimizaciones y Filtros
```bash
# 18. Solo APIs
subfinder -d example.com -all -silent | grep -i api | alterx -silent | dnsx -silent | httpx -silent

# 19. Excluir CDNs y servicios comunes
subfinder -d example.com -all -silent | alterx -silent | dnsx -silent | httpx -silent | grep -v "cloudflare\|amazonaws\|cloudfront"

# 20. Solo aplicaciones web interesantes
subfinder -d example.com -all -silent | alterx -silent | dnsx -silent | httpx -silent -title | grep -i "admin\|login\|dashboard\|panel"
```

## Comandos de Setup para macOS

### Instalacion rapida de todas las herramientas
```bash
# Project Discovery tools
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest  
go install -v github.com/projectdiscovery/alterx/cmd/alterx@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/katana/cmd/katana@latest

# Dependencias adicionales
brew install nmap
brew install massdns
```

### Configuracion de Subfinder (Importante - Minuto 9 del video)
```bash
# Configurar APIs para mejores resultados
nano ~/.config/subfinder/provider-config.yaml

# Agregar tus API keys:
# virustotal: ["your-api-key"]
# passivetotal: ["your-api-key"] 
# shodan: ["your-api-key"]
# censys: ["your-api-key"]
```

## Script de Uso Rapido
```bash
#!/bin/bash
# Uso: ./quick_recon.sh example.com

DOMAIN=$1
echo "[+] Iniciando recon para $DOMAIN"

# One-liner completo del video
subfinder -d "$DOMAIN" -all -silent | \
alterx -silent | \
dnsx -silent | \
tee "${DOMAIN}_resolved.txt" | \
httpx -silent -title -sc -cl | \
tee "${DOMAIN}_httpx.txt" | \
awk '{print $1}' | \
katana -jc -silent -d 3 -o "${DOMAIN}_urls.txt"

echo "[+] Recon completado. Archivos generados:"
echo "  - ${DOMAIN}_resolved.txt"  
echo "  - ${DOMAIN}_httpx.txt"
echo "  - ${DOMAIN}_urls.txt"
```
