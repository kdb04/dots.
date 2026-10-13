#!/usr/bin/env bash

set -u

MIN_COLS=172
MIN_ROWS=44

RESET=$'\033[0m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
WHITE=$'\033[37m'

terminal_size=$(stty size 2>/dev/null || echo "0 0")
ROWS=${terminal_size%% *}
COLS=${terminal_size##* }

if [[ ! -t 0 || ! -t 1 ]]; then
  echo "devcheck requires an interactive terminal."
  exit 1
fi

if (( COLS < MIN_COLS || ROWS < MIN_ROWS )); then
  echo "Terminal too small: ${COLS}x${ROWS}. Minimum: ${MIN_COLS}x${MIN_ROWS}."
  exit 1
fi

ORIGINAL_STTY=$(stty -g)

cleanup() {
  printf '\033[?25h\033[0m\033[?1049l'
  stty "$ORIGINAL_STTY" 2>/dev/null || true
}

trap cleanup EXIT
trap 'exit 0' INT TERM HUP

# Helpers
move_to() {
  printf '\033[%s;%sH' "$2" "$1"
}

put() {
  local x=$1
  local y=$2
  local text=$3

  move_to "$x" "$y"
  printf '%s' "$text"
}

panel_line() {
  local x=$1
  local y=$2
  local width=$3
  local text=$4

  text=${text:0:$((width - 2))}
  put "$((x + 1))" "$y" "$text"
}

draw_box() {
  local x=$1 y=$2 width=$3 height=$4 title=$5 color=$6
  local i

  move_to "$x" "$y"
  printf '%b┌' "$color"
  printf '─%.0s' $(seq 1 "$((width - 2))")
  printf '┐%b' "$RESET"

  move_to "$((x + 2))" "$y"
  printf '%b %s %b' "$color" "$title" "$RESET"

  for ((i = 1; i < height - 1; i++)); do
    move_to "$x" "$((y + i))"
    printf '%b│%b' "$color" "$RESET"
    move_to "$((x + width - 1))" "$((y + i))"
    printf '%b│%b' "$color" "$RESET"
  done

  move_to "$x" "$((y + height - 1))"
  printf '%b└' "$color"
  printf '─%.0s' $(seq 1 "$((width - 2))")
  printf '┘%b' "$RESET"
}

command_version() {
  local command_name=$1
  local version_command=$2
  local result

  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'not installed'
    return
  fi

  result=$(eval "$version_command" 2>/dev/null | head -n 1)
  printf '%s' "${result:-installed}"
}

check_service() {
  local name=$1
  local port=$2

  if command -v nc >/dev/null 2>&1 && nc -z -G 1 127.0.0.1 "$port" >/dev/null 2>&1; then
    printf '%s|%s|%s' "$name" "$port" "UP"
  else
    printf '%s|%s|%s' "$name" "$port" "DOWN"
  fi
}

get_activity_tools() {
  local history_file="${HISTFILE:-$HOME/.zsh_history}"

  if [[ ! -r "$history_file" ]]; then
    printf 'No readable zsh history'
    return
  fi

  tail -n 400 "$history_file" 2>/dev/null |
    sed -E 's/^: [0-9]+:[0-9]+;//' |
    awk '
      {
        cmd = $1

        if (cmd == "g++" || cmd == "clang++" || cmd == "c++" || cmd == "gcc" || cmd == "clang") count["C/C++"]++
        else if (cmd == "go") count["Go"]++
        else if (cmd == "python" || cmd == "python3" || cmd == "uv" || cmd == "pytest") count["Python"]++
        else if (cmd == "node" || cmd == "npm" || cmd == "npx" || cmd == "bun" || cmd == "pnpm" || cmd == "yarn" || cmd == "tsc") count["JS/TS"]++
        else if (cmd == "cargo" || cmd == "rustc") count["Rust"]++
        else if (cmd == "docker" || cmd == "docker-compose") count["Docker"]++
      }
      END {
        for (tool in count) {
          printf "%d %s\n", count[tool], tool
        }
      }
    ' |
    sort -rn |
    head -n 6
}

check_updates() {
  if ! command -v brew >/dev/null 2>&1; then
    UPDATE_STATUS="Homebrew not installed"
    return
  fi

  local outdated
  outdated=$(HOMEBREW_NO_AUTO_UPDATE=1 brew outdated --quiet 2>/dev/null)

  if [[ -n "$outdated" ]]; then
    UPDATE_STATUS="$(printf '%s\n' "$outdated" | wc -l | tr -d ' ') package(s) outdated"
  else
    UPDATE_STATUS="All installed formulae current"
  fi
}

get_listening_ports() {
  lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null |
    awk '
      NR > 1 {
        process = $1
        pid = $2
        address = $9
        port = address
        sub(/^.*:/, "", port)

        service = port
        if (port == 3000) service = "Next.js"
        else if (port == 3306) service = "MySQL"
        else if (port == 5432) service = "PostgreSQL"
        else if (port == 6379) service = "Redis"
        else if (port == 8000) service = "FastAPI"
        else if (port == 8080) service = "HTTP server"
        else if (port == 9000) service = "App / metrics"
        else if (port == 27017) service = "MongoDB"
        else if (port == 9090) service = "Prometheus"

        printf "%-16s %-7s %-18s %s\n", process, pid, service, address
      }
    ' |
    sort -k3,3 -k2,2n |
    head -n 6
}

get_nvim_log() {
  local log_file="$HOME/.local/state/nvim/log"

  if [[ -r "$log_file" ]]; then
    tail -n 12 "$log_file" 2>/dev/null
  else
    printf 'No Neovim log found at:\n%s' "$log_file"
  fi
}

get_docker_status() {
  if ! command -v docker >/dev/null 2>&1; then
    DOCKER_STATUS="Docker CLI not installed"
    DOCKER_CONTAINERS=""
    return
  fi

  if ! docker info >/dev/null 2>&1; then
    DOCKER_STATUS="Engine not running"
    DOCKER_CONTAINERS=""
    return
  fi

  local count
  count=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')

  DOCKER_STATUS="Engine running"
  DOCKER_CONTAINERS="$count running container(s)"
}

get_system_info() {
  DISK_INFO=$(df -h / | awk 'NR == 2 { printf "%s used / %s total (%s)", $3, $2, $5 }')
  UPTIME_INFO=$(uptime | sed 's/^[[:space:]]*//')
  MEMORY_INFO=$(memory_pressure 2>/dev/null | awk '/System-wide memory free percentage:/ { print $5 " free" }')
  [[ -n "$MEMORY_INFO" ]] || MEMORY_INFO="Unavailable"
}

get_tool_versions() {
  GO_VERSION=$(command_version go 'go version')
  PYTHON_VERSION=$(command_version python3 'python3 --version')
  NODE_VERSION=$(command_version node 'node --version')
  RUST_VERSION=$(command_version rustc 'rustc --version')
  DOCKER_VERSION=$(command_version docker 'docker --version')
  NVIM_VERSION=$(command_version nvim 'nvim --version')
  GIT_VERSION=$(command_version git 'git --version')
  BREW_VERSION=$(command_version brew 'brew --version')
  CPP_VERSION=$(command_version clang++ 'clang++ --version')
}

get_database_status() {
  POSTGRES_STATUS=$(check_service PostgreSQL 5432)
  MYSQL_STATUS=$(check_service MySQL 3306)
  REDIS_STATUS=$(check_service Redis 6379)
}

draw_dashboard() {
  clear

  get_tool_versions
  get_docker_status
  get_system_info
  get_database_status
  ACTIVITY=$(get_activity_tools)
  PORTS=$(get_listening_ports)
  NVIM_LOG=$(get_nvim_log)

  put 2 1 "${BOLD}${CYAN}devcheck${RESET} ${DIM}developer environment dashboard${RESET}"
  put 2 2 "${DIM}$(date '+%a %d %b %Y  %H:%M:%S')${RESET}"

  draw_box 1 5 59 13 "DEVELOPMENT TOOLS" "$GREEN"
  panel_line 3 7 55  "Go:       $GO_VERSION"
  panel_line 3 8 55  "C++:      $CPP_VERSION"
  panel_line 3 9 55  "Python:   $PYTHON_VERSION"
  panel_line 3 10 55 "Node.js:  $NODE_VERSION"
  panel_line 3 11 55 "Rust:     $RUST_VERSION"
  panel_line 3 12 55 "Docker:   $DOCKER_VERSION"
  panel_line 3 13 55 "Neovim:   $NVIM_VERSION"
  panel_line 3 14 55 "Git:      $GIT_VERSION"
  panel_line 3 15 55 "Homebrew: $BREW_VERSION"
  panel_line 3 16 55 "Updates:  ${UPDATE_STATUS:-press u to check}"

  draw_box 61 5 58 13 "DOCKER" "$MAGENTA"
  panel_line 63 7 54 "$DOCKER_STATUS"
  panel_line 63 8 54 "${DOCKER_CONTAINERS:-No container data}"
  if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    panel_line 63 10 54 "Container summary:"
    panel_line 63 11 54 "$(docker ps --format '{{.Names}}  {{.Status}}' 2>/dev/null | head -n 4)"
    panel_line 63 16 54 "No containers will be stopped automatically."
  else
    panel_line 63 10 54 "Start Docker Desktop if needed."
    panel_line 63 11 54 "This dashboard is read-only."
  fi

  draw_box 121 5 51 13 "SYSTEM" "$CYAN"
  panel_line 123 7 47 "Disk: $DISK_INFO"
  panel_line 123 9 47 "Memory: $MEMORY_INFO"
  panel_line 123 11 47 "Uptime:"
  panel_line 123 12 47 "$UPTIME_INFO"

  draw_box 1 19 59 10 "LOCAL SERVICES" "$BLUE"
  panel_line 3 21 55 "$(printf '%s' "$POSTGRES_STATUS" | awk -F'|' '{printf "%-12s port %-5s %s", $1, $2, $3}')"
  panel_line 3 23 55 "$(printf '%s' "$MYSQL_STATUS" | awk -F'|' '{printf "%-12s port %-5s %s", $1, $2, $3}')"
  panel_line 3 25 55 "$(printf '%s' "$REDIS_STATUS" | awk -F'|' '{printf "%-12s port %-5s %s", $1, $2, $3}')"

  draw_box 61 19 111 10 "LISTENING PORTS" "$YELLOW"
  panel_line 63 21 107 "$(printf '%-16s %-7s %-18s %s' PROCESS PID SERVICE ADDRESS)"
  local port_line=22
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    panel_line 63 "$port_line" 107 "$line"
    ((port_line++))
    ((port_line > 27)) && break
  done <<< "$PORTS"

  draw_box 1 30 171 12 "NEOVIM LOG" "$RED"
  local nvim_line=32
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    panel_line 3 "$nvim_line" 167 "$line"
    ((nvim_line++))
    ((nvim_line > 40)) && break
  done <<< "$NVIM_LOG"

  put 2 42 "${BOLD}r${RESET} refresh  ${BOLD}u${RESET} check updates  ${BOLD}p${RESET} ports  ${BOLD}n${RESET} Neovim log  ${BOLD}h${RESET} system health  ${BOLD}q${RESET} quit"
}

show_detail() {
  local title=$1
  local command_text=$2

  clear
  printf '%s\n\n' "$title"
  eval "$command_text"
  printf '\n\nPress any key to return...'
  IFS= read -r -s -n 1 _
}

show_health() {
  clear
  printf '%s\n\n' "SYSTEM HEALTH"
  printf 'Disk usage:\n'
  df -h /
  printf '\nMemory pressure:\n'
  memory_pressure 2>/dev/null || true
  printf '\nUptime and load:\n'
  uptime
  printf '\n\nPress any key to return...'
  IFS= read -r -s -n 1 _
}

show_ports() {
  clear
  printf '%s\n\n' "LISTENING PORTS"
  lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null || true
  printf '\n\nPress any key to return...'
  IFS= read -r -s -n 1 _
}

show_nvim() {
  clear
  printf '%s\n\n' "NEOVIM LOG"
  local log_file="$HOME/.local/state/nvim/log"

  if [[ -r "$log_file" ]]; then
    tail -n 80 "$log_file"
  else
    printf 'No log found at %s\n' "$log_file"
  fi

  printf '\n\nPress any key to return...'
  IFS= read -r -s -n 1 _
}

show_updates() {
  clear
  printf '%s\n\n' "HOMEBREW UPDATE CHECK"
  printf 'Checking installed formulae. This does not install or upgrade anything.\n\n'
  check_updates
  printf '%s\n' "$UPDATE_STATUS"
  printf '\n\nPress any key to return...'
  IFS= read -r -s -n 1 _
}

# Start
printf '\033[?1049h'
stty -echo -icanon min 1 time 0

UPDATE_STATUS="Press u to check"
while true; do
  draw_dashboard

  IFS= read -r -s -n 1 key || exit 0

  case "$key" in
    r|R) ;;
    q|Q) exit 0 ;;
    u|U) show_updates ;;
    p|P) show_ports ;;
    n|N) show_nvim ;;
    h|H) show_health ;;
  esac
done
