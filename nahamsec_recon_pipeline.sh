!/bin/bash

# Script de Automatizacion NahamSec - Minuto 16 del Video
# Replicando exactamente los pipes mencionados en: https://www.youtube.com/watch?v=evyxNUzl-HA

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Banner
echo -e "${BLUE}"
echo "=========================================="
echo "  NahamSec Pipeline Automation (Min 16)"
echo "  Automatizacion con Pipes del Video"
echo "=========================================="
echo -e "${NC}"

if [ $# -eq 0 ]; then
    echo -e "${RED}Uso: $0 <dominio>${NC}"
    echo "Ejemplo: $0 example.com"
    exit 1
fi

DOMAIN=$1
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="recon_${DOMAIN}_${TIMESTAMP}"

echo -e "${GREEN}[+] Creando directorio: $OUTPUT_DIR${NC}"
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# ====== PIPELINE 1: Basico del Minuto 16 ======
echo -e "${YELLOW}[+] Ejecutando Pipeline 1: subfinder -> alterx -> dnsx${NC}"
echo -e "${BLUE}Comando: subfinder -d $DOMAIN -all -silent | alterx -silent | dnsx -silent -o pipeline1_resolved.txt${NC}"

subfinder -d "$DOMAIN" -all -silent | \
alterx -silent | \
dnsx -silent -o pipeline1_resolved.txt

echo -e "${GREEN}[+] Pipeline 1 completado. Resultados: $(wc -l < pipeline1_resolved.txt) dominios resueltos${NC}"

# ====== PIPELINE 2: Con Port Scanning ======  
echo -e "${YELLOW}[+] Ejecutando Pipeline 2: + nmap port scanning${NC}"
echo -e "${BLUE}Comando: cat pipeline1_resolved.txt | nmap -iL - --top-ports 1000 -oG pipeline2_ports.txt${NC}"

cat pipeline1_resolved.txt | nmap -iL - --top-ports 1000 -oG pipeline2_ports.txt 2>/dev/null

# Extraer hosts con puertos abiertos
grep "open" pipeline2_ports.txt | awk '{print $2}' > pipeline2_live_hosts.txt 2>/dev/null || touch pipeline2_live_hosts.txt

echo -e "${GREEN}[+] Pipeline 2 completado. Hosts con puertos abiertos: $(wc -l < pipeline2_live_hosts.txt)${NC}"

# ====== PIPELINE 3: Con HTTPX (Information Gathering) ======
echo -e "${YELLOW}[+] Ejecutando Pipeline 3: + httpx information gathering${NC}"  
echo -e "${BLUE}Comando: cat pipeline1_resolved.txt | httpx -silent -title -sc -cl -location -o pipeline3_httpx.txt${NC}"

cat pipeline1_resolved.txt | \
httpx -silent -title -sc -cl -location -o pipeline3_httpx.txt

echo -e "${GREEN}[+] Pipeline 3 completado. Servicios HTTP encontrados: $(wc -l < pipeline3_httpx.txt)${NC}"

# ====== PIPELINE 4: Completo del Video (End-to-End) ======
echo -e "${YELLOW}[+] Ejecutando Pipeline 4: Completo end-to-end con Katana${NC}"
echo -e "${BLUE}Comando: subfinder -> alterx -> dnsx -> httpx -> katana${NC}"

subfinder -d "$DOMAIN" -all -silent | \
alterx -silent | \
dnsx -silent | \
tee pipeline4_resolved.txt | \
httpx -silent -title -sc -cl | \
tee pipeline4_httpx.txt | \
awk '{print $1}' | \
katana -jc -silent -d 3 -o pipeline4_urls.txt

echo -e "${GREEN}[+] Pipeline 4 completado. URLs descubiertas: $(wc -l < pipeline4_urls.txt)${NC}"

# ====== PIPELINE 5: Avanzado con JS Parsing ======
echo -e "${YELLOW}[+] Ejecutando Pipeline 5: Con JavaScript parsing avanzado${NC}"
echo -e "${BLUE}Comando: Con -jsl -xhr -aff para maximo descubrimiento${NC}"

cat pipeline4_resolved.txt | \
httpx -silent | \
katana -jsl -xhr -aff -silent -d 5 -o pipeline5_js_urls.txt

echo -e "${GREEN}[+] Pipeline 5 completado. URLs con JS parsing: $(wc -l < pipeline5_js_urls.txt)${NC}"

# ====== PIPELINE 6: Ejemplo PayPal (Minuto 30) ======
echo -e "${YELLOW}[+] Ejecutando Pipeline 6: Estilo PayPal con filtros${NC}"
echo -e "${BLUE}Comando: subfinder -> grep API -> alterx -> dnsx -> httpx${NC}"

subfinder -d "$DOMAIN" -all -silent | \
grep -i -E "(api|dev|staging|test|admin)" | \
alterx -silent | \
dnsx -silent | \
httpx -silent -title -sc -cl -o pipeline6_interesting.txt

echo -e "${GREEN}[+] Pipeline 6 completado. Servicios interesantes: $(wc -l < pipeline6_interesting.txt)${NC}"

# ====== RESUMEN FINAL ======
echo -e "${BLUE}"
echo "=========================================="
echo "           RESUMEN DE RESULTADOS"
echo "=========================================="
echo -e "${NC}"
echo -e "${GREEN}Dominio objetivo:${NC} $DOMAIN"
echo -e "${GREEN}Directorio de salida:${NC} $(pwd)"
echo ""
echo -e "${YELLOW}Pipeline 1 (Basico):${NC} $(wc -l < pipeline1_resolved.txt) dominios resueltos"
echo -e "${YELLOW}Pipeline 2 (+ Nmap):${NC} $(wc -l < pipeline2_live_hosts.txt) hosts con puertos abiertos"  
echo -e "${YELLOW}Pipeline 3 (+ HTTPX):${NC} $(wc -l < pipeline3_httpx.txt) servicios HTTP"
echo -e "${YELLOW}Pipeline 4 (+ Katana):${NC} $(wc -l < pipeline4_urls.txt) URLs descubiertas"
echo -e "${YELLOW}Pipeline 5 (JS Advanced):${NC} $(wc -l < pipeline5_js_urls.txt) URLs con JS parsing"
echo -e "${YELLOW}Pipeline 6 (Filtered):${NC} $(wc -l < pipeline6_interesting.txt) servicios interesantes"
echo ""
echo -e "${BLUE}Archivos generados:${NC}"
ls -la *.txt | awk '{printf "  %s (%s lineas)\n", $9, "?"}'
echo ""
echo -e "${GREEN}[+] Todos los pipelines completados exitosamente!${NC}"
echo -e "${YELLOW}[!] Revisa los archivos .txt para analizar los resultados${NC}"

# Crear script de analisis rapido
cat > analyze_results.sh << 'EOF'
#!/bin/bash
echo "=== ANALISIS RAPIDO DE RESULTADOS ==="
echo ""
echo "Servicios interesantes (titulos):"
grep -i -E "(admin|login|dashboard|panel|api|dev)" pipeline3_httpx.txt || echo "Ninguno encontrado"
echo ""
echo "URLs potencialmente vulnerables:"
grep -i -E "(admin|login|api|dev|test)" pipeline4_urls.txt | head -10 || echo "Ninguna encontrada"
echo ""
echo "Servicios con codigos de estado interesantes:"
grep -E "200|403|401" pipeline3_httpx.txt | head -10 || echo "Ninguno encontrado"
EOF
chmod +x analyze_results.sh

echo -e "${BLUE}[+] Script de analisis creado: analyze_results.sh${NC}"
echo -e "${YELLOW}    Ejecutalo con: ./analyze_results.sh${NC}"
