#!/bin/bash

##
# WEnum - Web Enumeration Tool
# Author: DVMkhpte

##
# Load visualization functions
source ./visu.sh

##
# Trap signals to ensure proper cleanup
trap force_stop SIGINT SIGTERM
trap visu_stop EXIT

##
# Global Variables
LOADER=true
TARGET=""
DIR_WORDLIST=""
VHOST_WORDLIST=""
THREADS=20

##
# Core Functions
check_url() {
    local target=$1
    local path=$2
    
    local code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 "$target/$path")
    
    if [[ "$code" != "404" && "$code" != "000" ]]; then
        if [[ "$code" == "301" ]]; then
            echo -e "${YELLOW}[!]${NC} $code:/$path (Redirected)"
        fi
        echo "$code:/$path"
    fi
}
export -f check_url

##
# Parse command line arguments
usage() {
    echo "Usage: $0 --url <URL> --wordlist <FILE> [--vlist <FILE>]"
    echo ""
    echo "Options:"
    echo "  -u, --url       Target (ex: http://10.10.10.10)"
    echo "  -w, --wordlist  Wordlist for directories (Directory Enum)"
    echo "  -v, --vlist     Wordlist for subdomains (VHost Enum) [Optional]"
    echo "  -h, --help      Show this help message"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -u|--url) 
            TARGET="$2"; shift ;;
        -w|--wordlist) 
            DIR_WORDLIST="$2"; shift ;;
        -v|--vlist) 
            VHOST_WORDLIST="$2"; shift ;;
        -h|--help) 
            usage ;;
        *) 
            echo "Erreur: Paramètre inconnu $1"; usage ;;
    esac
    shift
done

if [[ -z "$TARGET" || -z "$DIR_WORDLIST" ]]; then
    msg_error "Target URL and Directory Wordlist are mandatory."
    usage
fi

if [[ ! -f "$DIR_WORDLIST" ]]; then
    msg_error "Wordlist file not found: $DIR_WORDLIST"
    exit 1
fi

if [[ -n "$VHOST_WORDLIST" && ! -f "$VHOST_WORDLIST" ]]; then
    msg_error "Wordlist file not found: $VHOST_WORDLIST"
    exit 1
fi

##
# Main Execution
visu_init 
print_banner

msg_info "Target: $TARGET"
msg_info "Wordlist: $(basename "$DIR_WORDLIST")"
if [[ -n "$VHOST_WORDLIST" ]]; then
    msg_info "VHost Wordlist: $(basename "$VHOST_WORDLIST")\n"
else
    msg_warning "No VHost Wordlist provided.\n"
fi

if ! curl -s -o /dev/null -w "%{http_code}" "$TARGET" | grep "200" > /dev/null; then
    msg_error "Target is not reachable. Exiting."
    exit 1
fi

msg_info "Starting Directory Enumeration...\n"
grep -v "^#" "$DIR_WORDLIST" | tr -d "\"'\"" | xargs -d '\n' -P "$THREADS" -I {} bash -c 'check_url "$1" "$2"' -- "$TARGET" "{}" | while true; do    
    if read -t 0.3 -r line; then
        if [ -z "$line" ]; then break; fi
        echo -ne "\r\033[K"

        code=${line%%:*}
        path=${line##*:}

        if [[ "$code" == "200" ]]; then
            msg_success "$code: $path"
        elif [[ "$code" == "301" || "$code" == "302" || "$code" == "308" ]]; then
            msg_warning "$code: $path"
        else
            msg_info "$code: $path"
        fi

    else
    print_loader $compteur
    ((compteur++))
    fi
done


msg_info "\nDirectory scan finished."

if [[ -n "$VHOST_WORDLIST" ]]; then
    msg_info "Starting VHost Enumeration...\n"
    grep -v "^#" "$VHOST_WORDLIST" | while read -r subdomain; do
        full_domain="$subdomain.${TARGET#*//}"
        code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 -H "Host: $full_domain" "$TARGET")
        
        if [[ "$code" != "404" && "$code" != "400"&& "$code" != "000" ]]; then
            if [[ "$code" == "301" || "$code" == "302" || "$code" == "308" ]]; then
                msg_warning "$code: $full_domain (Redirected)"
            else
                msg_success "$code: $full_domain"
            fi
        fi
    done
    msg_info "VHost scan finished."
fi

visu_stop