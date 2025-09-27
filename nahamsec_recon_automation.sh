#!/bin/bash

# NahamSec Recon Automation Script
# Basado en la metodologia del video: https://www.youtube.com/watch?v=evyxNUzl-HA

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funcion para mostrar banners
show_banner() {
    echo -e "${BLUE}"
    echo "=================================================="
    echo "    NahamSec Recon Automation Script v1.0"
    echo "    Metodologia completa de reconocimiento"
    echo "=================================================="
    echo -e "${NC}"
}

# Funcion para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error_log() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

warn_log() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

# Verificar dependencias
check_dependencies() {
    log "Verificando dependencias..."
    
    local deps=("subfinder" "shuffledns" "alterx" "dnsx" "nmap" "httpx" "katana" "massdns")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v $dep &> /dev/null; then
            missing_deps+=($dep)
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        error_log "Dependencias faltantes: ${missing_deps[*]}"
        echo -e "${YELLOW}Instalas con:${NC}"
        for dep in "${missing_deps[@]}"; do
            echo "go install -v github.com/projectdiscovery/$dep/cmd/$dep@latest"
        done
        exit 1
    fi
    
    log "Todas las dependencias estan instaladas âœ“"
}

# Crear estructura de directorios
setup_dirs() {
    local domain=$1
    local base_dir="recon_$domain"
    
    log "Creando estructura de directorios para $domain"
    
    mkdir -p "$base_dir"/{subdomains,permutations,resolved,ports,httpx,content,wordlists}
    cd "$base_dir"
    
    echo "$base_dir"
}

# Fase 1: Asset Discovery - Subdomain Discovery
subdomain_discovery() {
    local domain=$1
    
    log "Iniciando descubrimiento de subdominios para $domain"
    
    # Subfinder con todas las fuentes
    log "Ejecutando subfinder..."
    subfinder -d "$domain" -all -silent -o subdomains/subfinder.txt
    
    # ShuffleDNS para brute force
    log "Ejecutando brute force con shuffledns..."
    
    # Descargar wordlist si no existe
    if [ ! -f "wordlists/subdomains.txt" ]; then
        log "Descargando wordlist de subdominios..."
        wget -q https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt -O wordlists/subdomains.txt
    fi
    
    # Descargar resolvers si no existen
    if [ ! -f "wordlists/resolvers.txt" ]; then
        log "Descargando resolvers..."
        wget -q https://raw.githubusercontent.com/trickest/resolvers/main/resolvers.txt -O wordlists/resolvers.txt
    fi
    
    shuffledns -d "$domain" -w wordlists/subdomains.txt -r wordlists/resolvers.txt -mode bruteforce -silent -o subdomains/shuffledns.txt
    
    # Combinar resultados
    cat subdomains/subfinder.txt subdomains/shuffledns.txt | sort -u > subdomains/all_subdomains.txt
    
    local count=$(wc -l < subdomains/all_subdomains.txt)
    log "Encontrados $count subdominios unicos"
}

# Fase 2: Permutaciones con AlterX
generate_permutations() {
    log "Generando permutaciones con AlterX..."
    
    # Usando el pipe automation del video (minuto 16)
    cat subdomains/all_subdomains.txt | alterx -silent > permutations/alterx_permutations.txt
    
    local count=$(wc -l < permutations/alterx_permutations.txt)
    log "Generadas $count permutaciones"
}

# Fase 3: Resolucion DNS con DNSX
resolve_domains() {
    log "Resolviendo dominios con DNSX..."
    
    # Pipe automation como en el video
    cat permutations/alterx_permutations.txt | dnsx -silent -o resolved/resolved_domains.txt
    
    local count=$(wc -l < resolved/resolved_domains.txt)
    log "Resueltos $count dominios validos"
}

# Fase 4: Port Scanning con Naboo/Nmap
port_scanning() {
    log "Escaneando puertos..."
    
    # Usar nmap como alternativa a naboo (mas disponible)
    log "Ejecutando nmap en top 1000 puertos..."
    nmap -iL resolved/resolved_domains.txt -T4 --top-ports 1000 -oG ports/nmap_results.txt >/dev/null 2>&1
    
    # Extraer hosts con puertos abiertos
    grep "open" ports/nmap_results.txt | awk '{print $2":"$5}' | sed 's/\/open//' > ports/open_ports.txt
    
    local count=$(wc -l < ports/open_ports.txt)
    log "Encontrados $count servicios con puertos abiertos"
}

# Fase 5: Information Gathering con HTTPX
http_probing() {
    log "Realizando HTTP probing con HTTPX..."
    
    # Pipeline automation del video (minuto 16+)
    cat resolved/resolved_domains.txt | httpx -silent -title -status-code -content-length -location -o httpx/httpx_results.txt
    
    # Tambien probar puertos especificos encontrados
    if [ -f ports/open_ports.txt ]; then
        cat ports/open_ports.txt | httpx -silent -title -status-code -content-length -o httpx/httpx_ports.txt
    fi
    
    local count=$(wc -l < httpx/httpx_results.txt)
    log "Identificados $count servicios HTTP/HTTPS"
}

# Fase 6: Content Discovery con Katana
content_discovery() {
    log "Iniciando content discovery con Katana..."
    
    # Crawling basico
    cat httpx/httpx_results.txt | awk '{print $1}' | katana -jc -silent -d 3 -o content/crawled_urls.txt
    
    # Crawling con JavaScript parsing (como en el video)
    log "Ejecutando crawling avanzado con JS parsing..."
    cat httpx/httpx_results.txt | awk '{print $1}' | katana -jsl -xhr -aff -silent -d 5 -o content/crawled_js_urls.txt
    
    # Combinar resultados
    cat content/crawled_urls.txt content/crawled_js_urls.txt | sort -u > content/all_urls.txt
    
    local count=$(wc -l < content/all_urls.txt)
    log "Descubiertas $count URLs unicas"
}

# Pipeline completo automatizado (como en el video minuto 16)
automated_pipeline() {
    local domain=$1
    
    log "Ejecutando pipeline automatizado completo..."
    
    # El one-liner mencionado en el video
    log "Pipeline: subfinder -> alterx -> dnsx -> nmap -> httpx -> katana"
    
    subfinder -d "$domain" -all -silent | \
    alterx -silent | \
    dnsx -silent | \
    tee resolved/pipeline_resolved.txt | \
    httpx -silent -title -status-code -content-length | \
    tee httpx/pipeline_httpx.txt | \
    awk '{print $1}' | \
    katana -jc -silent -d 3 -o content/pipeline_content.txt
    
    log "Pipeline automatizado completado"
}

# Funcion para recon completo paso a paso
full_recon() {
    local domain=$1
    
    show_banner
    
    log "Iniciando reconocimiento completo para: $domain"
    
    # Setup
    local work_dir=$(setup_dirs "$domain")
    
    # Asset Discovery
    subdomain_discovery "$domain"
    generate_permutations
    resolve_domains
    port_scanning
    
    # Information Gathering  
    http_probing
    
    # Content Discovery
    content_discovery
    
    # Pipeline automatizado adicional
    automated_pipeline "$domain"
    
    # Resumen final
    echo -e "${GREEN}"
    echo "=================================================="
    echo "           RESUMEN DE RECONOCIMIENTO"
    echo "=================================================="
    echo "Dominio objetivo: $domain"
    echo "Subdominios encontrados: $(wc -l < subdomains/all_subdomains.txt)"
    echo "Permutaciones generadas: $(wc -l < permutations/alterx_permutations.txt)"
    echo "Dominios resueltos: $(wc -l < resolved/resolved_domains.txt)"
    echo "Servicios HTTP: $(wc -l < httpx/httpx_results.txt)"
    echo "URLs descubiertas: $(wc -l < content/all_urls.txt)"
    echo "Directorio de trabajo: $(pwd)"
    echo "=================================================="
    echo -e "${NC}"
    
    log "Reconocimiento completado para $domain"
}

# Funcion principal
main() {
    if [ $# -eq 0 ]; then
        echo "Uso: $0 <dominio>"
        echo "Ejemplo: $0 example.com"
        exit 1
    fi
    
    local domain=$1
    
    check_dependencies
    full_recon "$domain"
}

# Ejecutar funcion principal
main "$@"
