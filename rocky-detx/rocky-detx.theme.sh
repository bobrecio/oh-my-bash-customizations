# Custom Oh My Bash theme: rocky-detx
# rocky-detx:
#   - [path] (right aligned) [user] & [hostname]([ip]) [yyyy-mm-dd HH:mm:ss]

# Helper to retrieve primary non-loopback IP address
_detx_ip() {
  local ip
  ip=$(hostname -I 2>/dev/null | awk '{print $1}')
  echo "${ip:-127.0.0.1}"
}

_detx_prompt() {
  local last_status=$?

  # --- 1. Colors & Formatting ---
  local PATH_BG="\[\e[48;5;31m\]"       # Blue background for path
  local PATH_FG="\[\e[38;5;255m\]"      # White text for path
  local INFO_BG="\[\e[48;5;238m\]"      # Dark grey background for user info
  local INFO_FG="\[\e[38;5;255m\]"      # White text for user info
  local STATUS_BG="\[\e[48;5;28m\]"     # Green background for status
  [ $last_status -ne 0 ] && STATUS_BG="\[\e[48;5;124m\]" # Red background for failure
  local RESET="\[\e[0m\]"

  # --- 2. Build Unformatted Text Strings (for exact length calculation) ---
  # Replace home directory path ($HOME) with '~' for proper length calculation
  local printable_path="${PWD/#$HOME/\~}"
  local ip_addr
  ip_addr=$(_detx_ip)
  local current_time
  current_time=$(date +'%Y-%m-%d %H:%M:%S')

  local left_text=" ${printable_path} "
  local right_text=" ${USER} @ ${HOSTNAME}(${ip_addr}) ${current_time} "

  # --- 3. Calculate Padding Spaces ---
  local term_width=${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}
  local left_len=${#left_text}
  local right_len=${#right_text}

  local pad_len=$(( term_width - left_len - right_len ))
  [ $pad_len -lt 1 ] && pad_len=1 # Ensure at least 1 space if path is long

  local padding
  padding=$(printf '%*s' "$pad_len" '')

  # --- 4. Assemble Formatted Prompt ---
  local seg_left="${PATH_BG}${PATH_FG}${left_text}${RESET}"
  local seg_user="${INFO_BG}${INFO_FG} ${USER}@${HOSTNAME} (${ip_addr}) ${RESET}"
  local seg_time="${STATUS_BG}${INFO_FG} ${current_time} ${RESET}"

  # Line 1: Path (left) + Padding + User/IP/Date (right-justified)
  # Line 2: Shell prompt ($ or #)
  PS1="${seg_left}${padding}${seg_user}${seg_time}\n\$ "
}

safe_append_prompt_command _detx_prompt
