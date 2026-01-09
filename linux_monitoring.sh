#!/bin/bash

HTML_FILE="dashboard.html"
REFRESH=5

# =========================
# HOST / OS
# =========================
HOSTNAME=$(hostname)
OS_NAME=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
KERNEL=$(uname -r)
ARCH=$(uname -m)
UPTIME=$(uptime -p)
CPU_CORES=$(nproc)

# =========================
# CPU (PER CORE)
# =========================
CPU_DATA=$(mpstat -P ALL 1 1 | awk '/Average/ && $2 ~ /[0-9]+/ {print $2, 100-$NF}')

MAX_CPU=0
MAX_CPU_CORE=""
CPU_ROWS=""

while read core usage; do
  usage_int=${usage%.*}
  [ -z "$usage_int" ] && usage_int=0

  if [ "$usage_int" -gt "$MAX_CPU" ]; then
    MAX_CPU=$usage_int
    MAX_CPU_CORE="CPU$core"
  fi

  CPU_ROWS+="
  <tr>
    <td>CPU$core</td>
    <td>
      <div class='progress'>
        <div class='bar cpu' style='width:${usage_int}%'>${usage_int}%</div>
      </div>
    </td>
  </tr>"
done <<< "$CPU_DATA"

# =========================
# MEMORY
# =========================
read MEM_TOTAL MEM_USED MEM_FREE MEM_AVAILABLE <<< $(free -m | awk '/Mem/ {print $2, $3, $4, $7}')
MEM_USED_PCT=$(( MEM_USED * 100 / MEM_TOTAL ))

# =========================
# DISK
# =========================
MAX_DISK=0
MAX_DISK_FS=""
DISK_ROWS=""

while read fs size used avail pct mount; do
  pct_val=${pct%\%}
  [ -z "$pct_val" ] && pct_val=0

  if [ "$pct_val" -gt "$MAX_DISK" ]; then
    MAX_DISK=$pct_val
    MAX_DISK_FS="$mount"
  fi

  DISK_ROWS+="
  <tr>
    <td>$mount</td>
    <td>$size</td>
    <td>$used</td>
    <td>$avail</td>
    <td>
      <div class='progress'>
        <div class='bar disk' style='width:${pct_val}%'>${pct_val}%</div>
      </div>
    </td>
  </tr>"
done <<< "$(df -h | awk 'NR>1 {print $1, $2, $3, $4, $5, $6}')"

# =========================
# SERVICES
# =========================
get_service_status() {
  systemctl is-active "$1" 2>/dev/null || echo "inactive"
}

NGINX_STATUS=$(get_service_status nginx)
SSH_STATUS=$(get_service_status ssh)
DOCKER_STATUS=$(get_service_status docker)

NGINX_CLASS="bad"; SSH_CLASS="bad"; DOCKER_CLASS="bad"
[ "$NGINX_STATUS" = "active" ] && NGINX_CLASS="ok"
[ "$SSH_STATUS" = "active" ] && SSH_CLASS="ok"
[ "$DOCKER_STATUS" = "active" ] && DOCKER_CLASS="ok"

# =========================
# SYSTEM INTEL (NEW)
# =========================
LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}')

TOP_PROCESSES=$(ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -6 | tail -5)
TOP_PROC_ROWS=""
while read pid cmd cpu mem; do
  TOP_PROC_ROWS+="
  <tr>
    <td>$pid</td>
    <td>$cmd</td>
    <td>${cpu}%</td>
    <td>${mem}%</td>
  </tr>"
done <<< "$TOP_PROCESSES"

read RX TX <<< $(awk '/:/ {rx+=$2; tx+=$10} END {print rx/1024/1024, tx/1024/1024}' /proc/net/dev)
RX=$(printf "%.2f" "$RX")
TX=$(printf "%.2f" "$TX")

# =========================
# HTML (HACKER UI)
# =========================
cat <<EOF > $HTML_FILE
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Linux Hacker Monitor</title>
<meta http-equiv="refresh" content="$REFRESH">

<style>
body {
  background:#000;
  color:#00ff9c;
  font-family: monospace;
  margin:0;
  text-shadow:0 0 5px #00ff9c66;
}
header {
  text-align:center;
  padding:20px;
  font-size:26px;
  border-bottom:1px solid #00ff9c44;
}
.container {
  display:grid;
  grid-template-columns:repeat(auto-fit,minmax(360px,1fr));
  gap:20px;
  padding:20px;
}
.card {
  background:#020617;
  border:1px solid #00ff9c44;
  border-radius:10px;
  padding:18px;
}
.card h2 {
  border-bottom:1px dashed #00ff9c44;
  padding-bottom:6px;
}
.kv {
  display:flex;
  justify-content:space-between;
  margin:6px 0;
}
.progress {
  background:#00110a;
  border-radius:10px;
  height:14px;
  overflow:hidden;
}
.bar {
  height:100%;
  font-size:11px;
  padding-right:6px;
  text-align:right;
  animation:pulse 1.5s infinite;
}
.cpu {background:#00ff9c;}
.mem {background:#00ffaa;}
.disk {background:#facc15;}

.badge {
  padding:4px 12px;
  border-radius:999px;
  border:1px solid;
}
.ok {color:#00ff9c;border-color:#00ff9c;}
.bad {color:#ff4d4d;border-color:#ff4d4d;}

.highlight {color:#ff4d4d;font-weight:bold;}

table {width:100%;border-collapse:collapse;}
td,th {padding:6px;}

@keyframes pulse {
  0%{opacity:.6}50%{opacity:1}100%{opacity:.6}
}
</style>
</head>

<body>

<header>☠️ LINUX SYSTEM HACKER DASHBOARD ☠️</header>

<div class="container">

<div class="card">
<h2>HOST / OS</h2>
<div class="kv"><span>HOST</span><span>$HOSTNAME</span></div>
<div class="kv"><span>OS</span><span>$OS_NAME</span></div>
<div class="kv"><span>KERNEL</span><span>$KERNEL</span></div>
<div class="kv"><span>ARCH</span><span>$ARCH</span></div>
<div class="kv"><span>UPTIME</span><span>$UPTIME</span></div>
<div class="kv"><span>CORES</span><span>$CPU_CORES</span></div>
</div>

<div class="card">
<h2>CPU PER CORE</h2>
<table>$CPU_ROWS</table>
<p class="highlight">HOT CORE → $MAX_CPU_CORE (${MAX_CPU}%)</p>
</div>

<div class="card">
<h2>MEMORY</h2>
<div class="kv"><span>TOTAL</span><span>${MEM_TOTAL} MB</span></div>
<div class="kv"><span>USED</span><span>${MEM_USED} MB</span></div>
<div class="kv"><span>FREE</span><span>${MEM_AVAILABLE} MB</span></div>
<div class="progress"><div class="bar mem" style="width:${MEM_USED_PCT}%">${MEM_USED_PCT}%</div></div>
</div>

<div class="card">
<h2>SYSTEM INTEL</h2>
<div class="kv"><span>LOAD AVG</span><span>$LOAD_AVG</span></div>

<h3>TOP PROCESSES</h3>
<table>
<tr><th>PID</th><th>CMD</th><th>CPU%</th><th>MEM%</th></tr>
$TOP_PROC_ROWS
</table>

<h3>NETWORK (MB)</h3>
<div class="kv"><span>RX</span><span>$RX</span></div>
<div class="kv"><span>TX</span><span>$TX</span></div>
</div>

<div class="card">
<h2>DISK</h2>
<table>
<tr><th>MOUNT</th><th>SIZE</th><th>USED</th><th>FREE</th><th>%</th></tr>
$DISK_ROWS
</table>
<p class="highlight">BOTTLENECK → $MAX_DISK_FS (${MAX_DISK}%)</p>
</div>

<div class="card">
<h2>SERVICES</h2>
<div class="kv"><span>nginx</span><span class="badge $NGINX_CLASS">$NGINX_STATUS</span></div>
<div class="kv"><span>ssh</span><span class="badge $SSH_CLASS">$SSH_STATUS</span></div>
<div class="kv"><span>docker</span><span class="badge $DOCKER_CLASS">$DOCKER_STATUS</span></div>
</div>

</div>

<p style="text-align:center;">Last update → $(date)</p>

</body>
</html>
EOF
