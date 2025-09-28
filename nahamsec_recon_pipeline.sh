#!/bin/bash

# NahamSec Pipeline Automation Script v1.1

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
  echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

ensure_dirs(){
  mkdir -p resolved httpx content wordlists ports
}

download_wordlists(){
  mkdir -p wordlists
  cd wordlists || exit
  if [ ! -f "subdomains-top1million-5000.txt" ]; then
      log "Descargando wordlist de subdominios..."
      curl -s -O https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt
  fi
  if [ ! -f "resolvers.txt" ]; then
      log "Descargando resolvers..."
      curl -s -O https://raw.githubusercontent.com/projectdiscovery/public-resolvers/master/resolvers.txt
  fi
  cd ..
}

if [ $# -eq 0 ]; then
  echo "Uso: $0 <dominio>"
  exit 1
fi

DOMAIN=$1

log "Inicio pipeline automatizado para $DOMAIN"
ensure_dirs
download_wordlists

log "Pipeline 1: subfinder + alterx + dnsx"
subfinder -d $DOMAIN -all -silent | alterx -silent | dnsx -silent -o resolved/pipeline1_resolved.txt

log "Pipeline 2: Nmap port scan"
cat resolved/pipeline1_resolved.txt | nmap -iL - --top-ports 1000 -oG ports/pipeline2_ports.txt

log "Pipeline 3: HTTP probing"
cat resolved/pipeline1_resolved.txt | httpx -silent -title -sc -cl -location -o httpx/pipeline3_httpx.txt

log "Pipeline 4: Crawling con Katana"
subfinder -d $DOMAIN -all -silent | alterx -silent | dnsx -silent | \
    tee resolved/pipeline4_resolved.txt | httpx -silent -title -sc -cl | tee httpx/pipeline4_httpx.txt | \
    awk '{print $1}' | katana -jc -silent -d 3 -o content/pipeline4_urls.txt

log "Pipeline 5: JavaScript parsing avanzado"
cat resolved/pipeline4_resolved.txt | httpx -silent | katana -jsl -xhr -aff -silent -d 5 -o content/pipeline5_js_urls.txt

log "Pipeline 6: Filtrado especial para APIs y admin"
subfinder -d $DOMAIN -all -silent | grep -i -E "(api|dev|staging|test|admin)" | alterx -silent | dnsx -silent | httpx -silent -title -sc -cl -o httpx/pipeline6_interesting.txt

log "Pipelines completados. Archivos generados en los respectivos directorios."
