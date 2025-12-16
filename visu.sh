##
# Color codes definition
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
OLD='\033[1m'
NC='\033[0m'

Blue1='\033[38;5;21m'
Blue2='\033[38;5;27m'
Blue3='\033[38;5;33m'
Blue4='\033[38;5;39m'
Blue5='\033[38;5;45m'
Blue6='\033[38;5;51m'

##
# Functions visuals
visu_init() {
    tput civis
    compteur=0
}

visu_stop() {
    tput cnorm
    echo ""
}

force_stop() {
    trap - SIGINT SIGTERM
    visu_stop
    kill 0
    exit 1
}

##
# Message Functions
msg_info() {
    echo -e "${Blue6}[*]${NC} $1"
}

msg_success() {
    echo -e "${GREEN}[+]${NC} $1"
}

msg_warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

msg_error() {
    echo -e "${RED}[✘] ERROR: $1${NC}" >&2
}


print_banner() {
    echo -e "${Blue1}                                     "
    echo -e "${Blue2}░██       ░██ ░██████████            "                           
    echo -e "${Blue3}░██       ░██ ░██                    "                           
    echo -e "${Blue4}░██  ░██  ░██ ░██         ░████████  ░██    ░██ ░█████████████  "
    echo -e "${Blue5}░██ ░████ ░██ ░█████████  ░██    ░██ ░██    ░██ ░██   ░██   ░██ "
    echo -e "${Blue6}░██░██ ░██░██ ░██         ░██    ░██ ░██    ░██ ░██   ░██   ░██ "
    echo -e "${Blue5}░████   ░████ ░██         ░██    ░██ ░██   ░███ ░██   ░██   ░██ "
    echo -e "${Blue4}░███     ░███ ░██████████ ░██    ░██  ░█████░██ ░██   ░██   ░██ "
    echo -e "${NC}"

    echo -e "${Blue1}       --- Web Enumeration Tool ---${NC}"
    echo ""
}

print_loader() {
    local tick=$1
    local text="Scanning..."
    local len=${#text}

    local phase=$((tick % (len + 1)))
    local display_text="${text:0:$phase}"

    echo -ne "\r${Blue1}[*] ${display_text}${NC}\033[K"
}