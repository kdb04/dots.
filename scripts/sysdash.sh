#!/usr/bin/env bash

set -u

REFRESH_INTERVAL=2
HISTORY_SIZE=40

RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
MAGENTA='\033[35m'
BLUE='\033[34m'
RED='\033[31m'
WHITE='\033[97m'

if terminal_size=$(stty size 2>/dev/null); then
  ROWS=${terminal_size%% *}
  COLS=${terminal_size##* }
else
  COLS=$(tput cols)
  ROWS=$(tput lines)
fi

if [[ ! -t 0 || ! -t 1 ]]; then
  echo "sysdash must run in an interactive terminal."
  exit 1
fi

if (( COLS < 120 || ROWS < 40 )); then
  echo "sysdash needs at least 120 columns and 40 rows."
  echo "Current size: ${COLS}x${ROWS}"
  exit 1
fi

if (( BASH_VERSINFO[0] >= 4 )); then
  POLL_TIMEOUT=0.1
  POLLS_PER_SECOND=10
else
  POLL_TIMEOUT=1
  POLLS_PER_SECOND=1
fi

WAIT_POLLS=$((REFRESH_INTERVAL * POLLS_PER_SECOND))

ORIGINAL_STTY=$(stty -g)
trap 'cleanup' EXIT
trap 'exit 0' INT TERM

cleanup() {
  printf '\033[?25h\033[0m'
  stty "$ORIGINAL_STTY"
  clear
}

+stty -echo -icanon min 1 time 0 
printf '\033[?25l'

move_to() {
  printf '\033[%s;%sH' "$2" "$1"
}

put() {
  move_to "$1" "$2"
  printf '%b' "$3"
}

draw_box() {
  local x=$1 y=$2 w=$3 h=$4 title=$5 color=$6
  local i

  for ((i = 0; i < w; i++)); do
    put "$((x + i))" "$y" "${color}-"
    put "$((x + i))" "$((y + h - 1))" "${color}-"
  done

  for ((i = 0; i < h; i++)); do
    put "$x" "$((y + i))" "${color}|"
    put "$((x + w - 1))" "$((y + i))" "${color}|"
  done

  put "$x" "$y" "${color}+"
  put "$((x + w - 1))" "$y" "${color}+"
  put "$x" "$((y + h - 1))" "${color}+"
  put "$((x + w - 1))" "$((y + h - 1))" "${color}+"
  put "$((x + 2))" "$y" "${BOLD}${color} ${title} ${RESET}"
}

panel_line() {
  local x=$1 y=$2 width=$3 text=$4
  text=$(printf '%s' "$text" | cut -c1-"$width")
  put "$x" "$y" "${WHITE}${text}${RESET}"
}

field() {
  printf '%s\n' "$output" | grep "^$1" | tail -n 1
}

percent_value() {
  printf '%s\n' "$1" |
    sed -E 's/^[^0-9]*([0-9]+([.][0-9]+)?).*/\1/'
}

push_history() {
  local name=$1 value=$2

  case "$name" in
    cpu) cpu_history[${#cpu_history[@]}]=$value ;;
    mem) mem_history[${#mem_history[@]}]=$value ;;
    net) net_history[${#net_history[@]}]=$value ;;
    disk) disk_history[${#disk_history[@]}]=$value ;;
  esac

  case "$name" in
    cpu)
      while (( ${#cpu_history[@]} > HISTORY_SIZE )); do
        cpu_history=("${cpu_history[@]:1}")
      done ;;
    mem)
      while (( ${#mem_history[@]} > HISTORY_SIZE )); do
        mem_history=("${mem_history[@]:1}")
      done ;;
    net)
      while (( ${#net_history[@]} > HISTORY_SIZE )); do
        net_history=("${net_history[@]:1}")
      done ;;
    disk)
      while (( ${#disk_history[@]} > HISTORY_SIZE )); do
        disk_history=("${disk_history[@]:1}")
      done ;;
  esac
}

draw_graph() {
  local x=$1 y=$2 w=$3 h=$4 name=$5 color=$6
  local -a values=()
  local count i j value max_value=1
  local prev_x=-1 prev_y=-1
  local px py dx dy steps k plot_x plot_y
  local char grid

  case "$name" in
    cpu)  values=("${cpu_history[@]}") ;;
    mem)  values=("${mem_history[@]}") ;;
    net)  values=("${net_history[@]}") ;;
    disk) values=("${disk_history[@]}") ;;
  esac

  count=${#values[@]}

  for ((j = 0; j < h; j++)); do
    grid=''
    for ((i = 0; i < w; i++)); do
      grid="${grid} "
    done
    put "$x" "$((y + j))" "${DIM}${grid}${RESET}"
  done

  (( count == 0 )) && return

  for value in "${values[@]}"; do
    (( value > max_value )) && max_value=$value
  done

  for ((i = 0; i < count; i++)); do
    value=${values[$i]}

    if (( count == 1 )); then
      px=$((x + w - 1))
    else
      px=$((x + i * (w - 1) / (count - 1)))
    fi

    py=$((y + h - 1 - value * (h - 1) / max_value))

    if (( prev_x >= 0 )); then
      dx=$((px - prev_x))
      dy=$((py - prev_y))
      steps=$dx
      (( steps < 1 )) && steps=1

      for ((k = 0; k <= steps; k++)); do
        plot_x=$((prev_x + k * dx / steps))
        plot_y=$((prev_y + k * dy / steps))

        if (( dy < 0 )); then
          char='/'
        elif (( dy > 0 )); then
          char='\\'
        else
          char='-'
        fi

        put "$plot_x" "$plot_y" "${color}${char}${RESET}"
      done
    fi

    put "$px" "$py" "${BOLD}${color}o${RESET}"

    prev_x=$px
    prev_y=$py
  done
}

draw_bar() {
  local x=$1 y=$2 width=$3 pct=$4 color=$5
  local filled i
  filled=$((pct * width / 100))
  (( filled > width )) && filled=$width
  (( filled < 0 )) && filled=0

  for ((i = 0; i < width; i++)); do
    if (( i < filled )); then
      put "$((x + i))" "$y" "${color}#${RESET}"
    else
      put "$((x + i))" "$y" "${DIM}-${RESET}"
    fi
  done
}

cpu_history=()
mem_history=()
net_history=()
disk_history=()

previous_net_in=0
previous_net_out=0
previous_disk_read=0
previous_disk_write=0
previous_sample=0
sort_mode=cpu
network_mode=0
disk_mode=0

hostname_value=$(scutil --get ComputerName 2>/dev/null || hostname)
os_version=$(sw_vers -productVersion)
kernel_version=$(uname -r)
architecture=$(uname -m)
model_name=$(sysctl -n hw.model 2>/dev/null || echo "Mac")
cpu_count=$(sysctl -n hw.logicalcpu 2>/dev/null || echo 1)
memory_bytes=$(sysctl -n hw.memsize 2>/dev/null || echo 0)
memory_gb=$((memory_bytes / 1073741824))

network_interface=$(route -n get default 2>/dev/null |
  awk '/interface:/{print $2; exit}')
[[ -z "$network_interface" ]] && network_interface="en0"

read_network_counters() {
  netstat -ibn 2>/dev/null |
    awk -v iface="$network_interface" '
      $1 == iface && $3 ~ /^<Link#/ {
        print $7, $10
        exit
      }'
}

read_disk_counters() {
  field 'Disks:' |
    sed -E 's/.*Disks: *([0-9]+)\/[0-9.]+[KMGT]? read, *([0-9]+)\/[0-9.]+[KMGT]? written.*/\1 \2/'
}

while true; do
  output=$(top -l 2 -n 0 -s 1 2>/dev/null)

  cpu=$(field 'CPU usage:')
  load=$(field 'Load Avg:')
  processes=$(field 'Processes:')
  memory=$(field 'PhysMem:')
  vm=$(field 'VM:')
  networks=$(field 'Networks:')
  disks=$(field 'Disks:')

  # CPU utilization
  user_pct=$(printf '%s\n' "$cpu" |
    sed -E 's/.*CPU usage: *([0-9.]+)% user.*/\1/')
  sys_pct=$(printf '%s\n' "$cpu" |
    sed -E 's/.*, *([0-9.]+)% sys.*/\1/')
  idle_pct=$(printf '%s\n' "$cpu" |
    sed -E 's/.*, *([0-9.]+)% idle.*/\1/')

  [[ "$user_pct" =~ ^[0-9]+([.][0-9]+)?$ ]] || user_pct=0
  [[ "$sys_pct" =~ ^[0-9]+([.][0-9]+)?$ ]] || sys_pct=0
  [[ "$idle_pct" =~ ^[0-9]+([.][0-9]+)?$ ]] || idle_pct=100

  cpu_pct=$(awk -v u="$user_pct" -v s="$sys_pct" \
    'BEGIN {printf "%d", u+s}')

  mem_used=$(printf '%s\n' "$memory" |
    sed -E 's/.*PhysMem: *([0-9.]+)([GMK]?) used.*/\1 \2/')
  mem_free=$(printf '%s\n' "$memory" |
    sed -E 's/.*used.*[, ] *([0-9.]+)([GMK]?) unused.*/\1 \2/')

  mem_used_num=$(printf '%s\n' "$mem_used" | awk '{print $1}')
  mem_used_unit=$(printf '%s\n' "$mem_used" | awk '{print $2}')
  mem_free_num=$(printf '%s\n' "$mem_free" | awk '{print $1}')
  mem_free_unit=$(printf '%s\n' "$mem_free" | awk '{print $2}')

  [[ "$mem_used_num" =~ ^[0-9]+([.][0-9]+)?$ ]] || mem_used_num=0
  [[ "$mem_free_num" =~ ^[0-9]+([.][0-9]+)?$ ]] || mem_free_num=0

  mem_used_mb=$(awk -v n="$mem_used_num" -v u="$mem_used_unit" \
    'BEGIN {if(u=="G") n*=1024; else if(u=="K") n/=1024; print n}')
  mem_free_mb=$(awk -v n="$mem_free_num" -v u="$mem_free_unit" \
    'BEGIN {if(u=="G") n*=1024; else if(u=="K") n/=1024; print n}')

  mem_pct=$(awk -v u="$mem_used_mb" -v f="$mem_free_mb" \
    'BEGIN {if(u+f>0) printf "%d", u*100/(u+f); else print 0}')

  # Network rates 
  net_counters=$(read_network_counters)
  net_in=$(printf '%s\n' "$net_counters" | awk '{print $1}')
  net_out=$(printf '%s\n' "$net_counters" | awk '{print $2}')
  [[ "$net_in" =~ ^[0-9]+$ ]] || net_in=0
  [[ "$net_out" =~ ^[0-9]+$ ]] || net_out=0

  net_in_rate=0
  net_out_rate=0
  if (( previous_sample > 0 )); then
    net_in_rate=$(( (net_in - previous_net_in) / REFRESH_INTERVAL ))
    net_out_rate=$(( (net_out - previous_net_out) / REFRESH_INTERVAL ))
    (( net_in_rate < 0 )) && net_in_rate=0
    (( net_out_rate < 0 )) && net_out_rate=0
  fi
  previous_net_in=$net_in
  previous_net_out=$net_out

  net_total_rate=$(( (net_in_rate + net_out_rate) / 1024 ))

  # Disk counters
  disk_values=$(read_disk_counters)

  disk_reads=$(printf '%s\n' "$disk_values" | awk '{print $1}')
  disk_writes=$(printf '%s\n' "$disk_values" | awk '{print $2}')

  [[ "$disk_reads" =~ ^[0-9]+$ ]] || disk_reads=0
  [[ "$disk_writes" =~ ^[0-9]+$ ]] || disk_writes=0

  disk_read_rate=0
  disk_write_rate=0

  if (( previous_sample > 0 )); then
    disk_read_rate=$(( (disk_reads - previous_disk_read) / REFRESH_INTERVAL ))
    disk_write_rate=$(( (disk_writes - previous_disk_write) / REFRESH_INTERVAL ))

    (( disk_read_rate < 0 )) && disk_read_rate=0
    (( disk_write_rate < 0 )) && disk_write_rate=0
  fi

  previous_disk_read=$disk_reads
  previous_disk_write=$disk_writes

  push_history cpu "$cpu_pct"
  push_history mem "$mem_pct"
  push_history net "$net_total_rate"
  push_history disk "$((disk_read_rate + disk_write_rate))"
  previous_sample=1

  # Dashboard 
  printf '\033[2J\033[H'

  put 2 1 "${BOLD}${CYAN}SYS-DASH${RESET} ${DIM}— macOS system monitor${RESET}"
  put 64 1 "Host: ${hostname_value}"
  put 108 1 "Uptime: $(uptime | sed 's/.*up /up /' | sed 's/, [0-9]* users.*//')"
  put 151 1 "Updated: $(date '+%H:%M:%S')"

  draw_box 1 3 85 12 "CPU & LOAD" "$GREEN"
  draw_box 88 3 84 12 "MEMORY & VIRTUAL MEMORY" "$MAGENTA"
  draw_box 1 16 85 16 "PROCESSES" "$YELLOW"
  draw_box 88 16 43 16 "SYSTEM INFO" "$CYAN"
  draw_box 132 16 40 16 "CPU PER CORE" "$BLUE"
  draw_box 1 33 85 14 "NETWORK" "$CYAN"
  draw_box 88 33 84 14 "DISK & FILESYSTEMS" "$YELLOW"

  # CPU panel
  panel_line 3 5 79 "CPU ${cpu_pct}% active | User ${user_pct}% | System ${sys_pct}% | Idle ${idle_pct}%"
  panel_line 3 6 79 "$load"
  panel_line 3 8 79 "CPU history (recent samples)"
  draw_graph 3 9 78 4 cpu "$GREEN" 100

  # Memory panel
  panel_line 90 5 78 "Physical memory: ${mem_used_num}${mem_used_unit} used | ${mem_free_num}${mem_free_unit} unused"
  panel_line 90 6 78 "Estimated usage: ${mem_pct}% of used + unused memory"
  draw_bar 90 7 48 "$mem_pct" "$MAGENTA"
  panel_line 140 7 25 "${mem_pct}%"
  panel_line 90 9 78 "Memory usage history"
  draw_graph 90 10 78 3 mem "$MAGENTA" 100
  panel_line 90 13 78 "$vm"

  # Processes
  panel_line 3 18 80 "${processes:-Process information unavailable}"
  panel_line 3 19 80 "Sort: ${sort_mode} (press s to switch)"
  panel_line 3 20 80 "$(printf '%-5s %5s %4s %2s  %9s' \
    'PID' 'CPU%' 'MEM%' 'RSS' 'COMMAND')"

  if [[ "$sort_mode" == "cpu" ]]; then
    process_rows=$(ps -axo pid,%cpu,%mem,rss,comm | tail -n +2 | sort -k2,2nr | head -n 10)
  else
    process_rows=$(ps -axo pid,%cpu,%mem,rss,comm | tail -n +2 | sort -k3,3nr | head -n 10)
  fi

  row=21
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    panel_line 3 "$row" 80 "$line"
    row=$((row + 1))
  done <<EOF
$process_rows
EOF

  # System information
  panel_line 90 18 39 "OS: macOS ${os_version}"
  panel_line 90 19 39 "Kernel: ${kernel_version}"
  panel_line 90 20 39 "Arch: ${architecture}"
  panel_line 90 21 39 "Model: ${model_name}"
  panel_line 90 22 39 "CPU cores: ${cpu_count}"
  panel_line 90 23 39 "RAM: ${memory_gb} GiB"
  panel_line 90 24 39 "Shell: ${SHELL##*/}"
  panel_line 90 25 39 "Hostname: ${hostname_value}"

  # Per-core section
  panel_line 134 18 36 "Logical CPUs: ${cpu_count}"
  panel_line 134 20 36 "Overall CPU: ${cpu_pct}%"
  draw_bar 134 21 30 "$cpu_pct" "$GREEN"
  panel_line 134 23 36 "User: ${user_pct}%"
  panel_line 134 24 36 "System: ${sys_pct}%"
  panel_line 134 25 36 "Idle: ${idle_pct}%"

  # Network panel
  panel_line 3 35 80 "Interface: ${network_interface}"
  panel_line 3 36 80 "RX: $((net_in_rate / 1024)) KiB/s   TX: $((net_out_rate / 1024)) KiB/s"
  panel_line 3 38 80 "Network throughput history (KiB/s)"
  draw_graph 3 39 78 4 net "$CYAN" 10240
  panel_line 3 44 80 "Cumulative: RX $((net_in / 1048576)) MiB | TX $((net_out / 1048576)) MiB"

  # Disk panel
  panel_line 90 35 78 "Disk reads: ${disk_read_rate} ops/s   Writes: ${disk_write_rate} ops/s"
  panel_line 90 36 78 "Disk activity history (ops/s)"
  draw_graph 90 37 78 3 disk "$YELLOW" 10240
  panel_line 90 41 78 "Filesystem                SIZE   USED   AVAIL   USE%"
  disk_rows=$(df -h / | awk 'NR == 2 {
    printf "%-22s %7s %6s %7s %4s\n", $1, $2, $3, $4, $5
  }')
  row=42

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    panel_line 90 "$row" 78 "$line"
    row=$((row + 1))
  done <<EOF
$disk_rows
EOF

  put 2 48 "${DIM}Manual refresh | r: refresh | q: quit${RESET}"

  key=''
  IFS= read -rsn1 key

  case "$key" in
    q) exit 0 ;;
    r) continue ;;
    s)
      if [[ "$sort_mode" == "cpu" ]]; then
        sort_mode=mem
      else
        sort_mode=cpu
      fi
      ;;
  esac 
done
