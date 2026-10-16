#!/usr/bin/env bash
set -uo pipefail

self_path=$(readlink -f -- "${BASH_SOURCE[0]}")
out_dir=${GPURECORD_DIR:-$HOME/video}
signal_n=${GPURECORD_SIGNAL:-8}
state_dir=${GPURECORD_STATE_DIR:-${XDG_RUNTIME_DIR:-/tmp}/gpurecord-$(id -u)}

pid_file=$state_dir/pid
start_file=$state_dir/start
out_file=$state_dir/out
log_file=$state_dir/recorder.log

icon="⏺"
default_args=(-w screen -f 60 -a default_output)

usage() {
    cat <<'EOF'
用法:
  gpurecord.sh              不带参数 = toggle, 没录就开录, 在录就停
  gpurecord.sh start [gpu-screen-recorder 的额外参数...]
  gpurecord.sh stop
  gpurecord.sh toggle
  gpurecord.sh status

环境变量:
  GPURECORD_DIR        输出目录, 默认 ~/video
  GPURECORD_SIGNAL     触发 mangobar 的 SIGRTMIN+N, 默认 8
  GPURECORD_STATE_DIR  状态目录, 默认 $XDG_RUNTIME_DIR/gpurecord-$UID
EOF
}

recorder_pid() {
    local pid comm
    [[ -r $pid_file ]] || return 1
    read -r pid < "$pid_file" || return 1
    [[ $pid =~ ^[0-9]+$ ]] || return 1
    comm=$(<"/proc/$pid/comm") || return 1
    [[ $comm == gpu-screen-re* ]] || return 1
    printf '%s\n' "$pid"
}

is_recording() {
    recorder_pid >/dev/null
}

elapsed_text() {
    local start now secs
    [[ -r $start_file ]] || return 0
    read -r start < "$start_file" || return 0
    now=$(date +%s)
    secs=$((now - start))
    ((secs < 0)) && secs=0
    printf '%02d:%02d:%02d\n' $((secs / 3600)) $((secs % 3600 / 60)) $((secs % 60))
}

poke_bar() {
    pkill -"RTMIN+$signal_n" -x mangobar 2>/dev/null || true
}

notify() {
    command -v notify-send >/dev/null 2>&1 || return 0
    notify-send -a gpurecord -u low -i gpu-screen-recorder \
        -h string:x-canonical-private-synchronous:gpurecord "$1" "$2" || true
}

wait_gone() {
    local pid=$1 i
    for ((i = 0; i < ${2:-50}; i++)); do
        kill -0 "$pid" 2>/dev/null || return 0
        sleep 0.1
    done
    return 1
}

cmd_status() {
    is_recording || return 0
    printf '%s 录制 %s\n' "$icon""$(elapsed_text)"
}

cmd_start() {
    local pid
    if pid=$(recorder_pid); then
        poke_bar
        printf 'gpurecord: already recording (pid %s)\n' "$pid" >&2
        return 0
    fi
    if ! mkdir -p "$out_dir"; then
        printf 'gpurecord: cannot create %s\n' "$out_dir" >&2
        return 1
    fi
    if ! mkdir -p "$state_dir"; then
        printf 'gpurecord: cannot create %s\n' "$state_dir" >&2
        return 1
    fi
    rm -f "$pid_file" "$start_file" "$out_file"
    : > "$log_file"

    setsid "$self_path" __supervise "$@" >/dev/null 2>&1 </dev/null &
    local sup=$!

    local i
    for ((i = 0; i < 60; i++)); do
        is_recording && return 0
        kill -0 "$sup" 2>/dev/null || break
        sleep 0.1
    done

    local reason
    reason=$(tail -n 4 "$log_file" 2>/dev/null | tr '\n' ' ' |
        sed -e 's/  */ /g' -e 's/^ //' -e 's/ $//')
    [[ -n $reason ]] || reason="gpu-screen-recorder failed to start"
    printf 'gpurecord: %s\n' "$reason" >&2
    notify "$icon 录制启动失败" "$reason"
    return 1
}

cmd_stop() {
    local pid
    if ! pid=$(recorder_pid); then
        rm -f "$pid_file" "$start_file" "$out_file"
        poke_bar
        printf 'gpurecord: not recording\n' >&2
        return 0
    fi
    kill -INT "$pid" 2>/dev/null || true
    if ! wait_gone "$pid" 50; then
        kill -TERM "$pid" 2>/dev/null || true
        if ! wait_gone "$pid" 30; then
            kill -KILL "$pid" 2>/dev/null || true
            wait_gone "$pid" 10
        fi
    fi
    rm -f "$pid_file" "$start_file" "$out_file"
    poke_bar
}

cmd_supervise() {
    local out rec rc i stopping=0 secs reason body start_secs
    out="$out_dir/$(date +%Y-%m-%d_%H-%M-%S).mp4"

    gpu-screen-recorder "${default_args[@]}" "$@" -o "$out" >>"$log_file" 2>&1 &
    rec=$!
    printf '%s\n' "$rec" > "$pid_file"
    printf '%s\n' "$out" > "$out_file"
    start_secs=$(date +%s)
    printf '%s\n' "$start_secs" > "$start_file"

    poke_bar
    notify "$icon 开始录制" "输出: $(basename "$out")
点击状态栏的 $icon 录制 模块可停止"

    for ((i = 0; i < 10; i++)); do
        kill -0 "$rec" 2>/dev/null || break
        sleep 0.1
    done
    if ! kill -0 "$rec" 2>/dev/null; then
        wait "$rec"
        rc=$?
        rm -f "$pid_file" "$start_file" "$out_file"
        poke_bar
        reason=$(tail -n 4 "$log_file" 2>/dev/null | tr '\n' ' ' |
            sed -e 's/  */ /g' -e 's/^ //' -e 's/ $//')
        [[ -n $reason ]] || reason="gpu-screen-recorder exited (rc=$rc)"
        notify "$icon 录制启动失败" "$reason"
        return 1
    fi

    trap 'stopping=1; kill -INT "$rec" 2>/dev/null' INT TERM HUP
    wait "$rec"
    rc=$?
    if ((stopping)); then
        wait_gone "$rec" 50 || kill -KILL "$rec" 2>/dev/null
    fi
    wait "$rec" 2>/dev/null

    secs=$(($(date +%s) - start_secs))
    ((secs < 0)) && secs=0
    rm -f "$pid_file" "$start_file" "$out_file"
    poke_bar

    body="$(basename "$out")
时长 $(printf '%02d:%02d:%02d' $((secs / 3600)) $((secs % 3600 / 60)) $((secs % 60)))"
    if ((rc != 0 && rc != 130 && !stopping)); then
        body="$body（异常退出 rc=$rc）"
    fi
    notify "$icon 录制结束" "$body"
}

case ${1:-toggle} in
start)
    shift
    cmd_start "$@"
    ;;
stop)
    cmd_stop
    ;;
toggle)
    if is_recording; then cmd_stop; else cmd_start; fi
    ;;
status)
    cmd_status
    ;;
__supervise)
    shift
    cmd_supervise "$@"
    ;;
-h | --help | help)
    usage
    ;;
*)
    usage >&2
    exit 2
    ;;
esac
