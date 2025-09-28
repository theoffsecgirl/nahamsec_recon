#!/bin/bash

# NahamSec Recon Automation Script v1.1
# Basado en la metodologia del video: https://www.youtube.com/watch?v=evyxNUzl-HA

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones para logging
show_banner() {
    echo -e "${BLUE}"
    echo "=================================================="
    echo "    NahamSec Recon Automation Script "
    echo "    Metodologia completa de reconocimiento"
    echo "=================================================="
    echo -e "${NC}"
}

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
        echo -e "${YELLOW}Instala con:${NC}"
        for dep in "${missing_deps[@]}"; do
            echo "go install -v github.com/projectdiscovery/$dep/cmd/$dep@latest"
        done
        exit 1
    fi
    log "Todas las dependencias estan instaladas ✓"
}

# Crear estructura de directorios
setup_dirs() {
    local domain=$1
    local base_dir="recon_$domain"

    log "Creando estructura de directorios para $domain"

    mkdir -p "$base_dir"/{subdomains,permutations,resolved,ports,httpx,content,wordlists}
    cd "$base_dir" || { error_log "No se pudo cambiar al directorio $base_dir"; exit 1; }
    echo "$base_dir"
}

# Descargar wordlists necesarias
download_wordlists() {
    mkdir -p wordlists
    cd wordlists || exit

    if [ ! -f "subdomains-top1million-5000.txt" ]; then
        log "Descargando wordlist de subdominios..."
        curl -s -O https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt
    fi

    if [ ! -f "resolvers.txt" ]; then
        log "Descargando resolvers publicos..."
        curl -s -O https://raw.githubusercontent.com/projectdiscovery/public-resolvers/master/resolvers.txt
    fi

    if [ ! -f "common.txt" ]; then
        log "Descargando lista comun de paths/directorios..."
        curl -s -O https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/common.txt
    fi

    cd ..
}

# Asegurar que todos los directorios existen
ensure_dirs() {
    mkdir -p subdomains permutations resolved ports httpx content wordlists
}

# Fase 1: Asset Discovery
subdomain_discovery() {
    local domain=$1
    ensure_dirs
    download_wordlists

    log "Iniciando descubrimiento de subdominios para $domain"
    log "Ejecutando subfinder..."
    subfinder -d "$domain" -all -silent -o subdomains/subfinder.txt

    log "Ejecutando brute force con shuffledns..."
    shuffledns -d "$domain" -w wordlists/subdomains-top1million-5000.txt -r wordlists/resolvers.txt -mode bruteforce -silent -o subdomains/shuffledns.txt

    cat subdomains/subfinder.txt subdomains/shuffledns.txt | sort -u > subdomains/all_subdomains.txt

    local count=$(wc -l < subdomains/all_subdomains.txt)
    log "Encontrados $count subdominios unicos"
}

# Fase 2: Permutaciones
generate_permutations() {
    ensure_dirs
    log "Generando permutaciones con AlterX..."
    cat subdomains/all_subdomains.txt | alterx -silent > permutations/alterx_permutations.txt
    local count=$(wc -l < permutations/alterx_permutations.txt)
    log "Generadas $count permutaciones"
}

# Fase 3: Resolucion DNS
resolve_domains() {
    ensure_dirs
    log "Resolviendo dominios con DNSX..."
    cat permutations/alterx_permutations.txt | dnsx -silent -o resolved/resolved_domains.txt
    local count=$(wc -l < resolved/resolved_domains.txt)
    log "Resueltos $count dominios validos"
}

# Fase 4: Port Scanning
port_scanning() {
    ensure_dirs
    log "Escaneando puertos..."
    log "Ejecutando nmap en top 1000 puertos..."
    nmap -iL resolved/resolved_domains.txt -T4 --top-ports 1000 -oG ports/nmap_results.txt >/dev/null 2>&1
    grep "open" ports/nmap_results.txt | awk '{print $2":"$5}' | sed 's/\/open//' > ports/open_ports.txt
    local count=$(wc -l < ports/open_ports.txt)
    log "Encontrados $count servicios con puertos abiertos"
}

# Fase 5: Information Gathering
http_probing() {
    ensure_dirs
    log "Realizando HTTP probing con HTTPX..."
    cat resolved/resolved_domains.txt | httpx -silent -title -status-code -content-length -location -o httpx/httpx_results.txt
    if [ -f ports/open_ports.txt ]; then
        cat ports/open_ports.txt | httpx -silent -title -status-code -content-length -o httpx/httpx_ports.txt
    fi
    local count=$(wc -l < httpx/httpx_results.txt)
    log "Identificados $count servicios HTTP/HTTPS"
}

# Fase 6: Content Discovery
content_discovery() {
    ensure_dirs
    log "Iniciando content discovery con Katana..."
    cat httpx/httpx_results.txt | awk '{print $1}' | katana -jc -silent -d 3 -o content/crawled_urls.txt
    log "Ejecutando crawling avanzado con JS parsing..."
    cat httpx/httpx_results.txt | awk '{print $1}' | katana -jsl -xhr -aff -silent -d 5 -o content/crawled_js_urls.txt
    cat content/crawled_urls.txt content/crawled_js_urls.txt | sort -u > content/all_urls.txt
    local count=$(wc -l < content/all_urls.txt)
    log "Descubiertas $count URLs unicas"
}

# Pipeline completo automatizado
automated_pipeline() {
    local domain=$1
    ensure_dirs
    log "Ejecutando pipeline automatizado completo..."
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

# Recon completo paso a paso
full_recon() {
    local domain=$1
    show_banner
    log "Iniciando reconocimiento completo para: $domain"
    local work_dir=$(setup_dirs "$domain")
    subdomain_discovery "$domain"
    generate_permutations
    resolve_domains
    port_scanning
    http_probing
    content_discovery
    automated_pipeline "$domain"
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

main "$@"
