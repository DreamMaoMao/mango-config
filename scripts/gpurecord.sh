#!/usr/bin/env bash
set -uo pipefail

self_path=$(readlink -f -- "${BASH_SOURCE[0]}")
out_dir=${GPURECORD_DIR:-$HOME/video}
signal_n=${GPURECORD_SIGNAL:-8}
state_dir=${GPURECORD_STATE_DIR:-${XDG_RUNTIME_DIR:-/tmp}/gpurecord-$(id -u)}
start_delay=${GPURECORD_START_DELAY:-0.1}

pid_file=$state_dir/pid
out_file=$state_dir/out
log_file=$state_dir/recorder.log

icon="󰨜"
default_args=(-w screen -f 60 -a default_output)

usage() {
    cat <<'EOF'
Usage:
  gpurecord.sh              no args = toggle: start if not recording, stop if recording
  gpurecord.sh start [extra gpu-screen-recorder args...]
  gpurecord.sh stop
  gpurecord.sh toggle
  gpurecord.sh status

Environment variables:
  GPURECORD_DIR          Output directory, default ~/video
  GPURECORD_SIGNAL       SIGRTMIN+N to poke mangobar, default 8
  GPURECORD_STATE_DIR    State directory, default $XDG_RUNTIME_DIR/gpurecord-$UID
  GPURECORD_START_DELAY  Seconds to wait after the start notification before
                         launching gpu-screen-recorder, default 0.1
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

poke_bar() {
    pkill -"RTMIN+$signal_n" -x mangobar 2>/dev/null || true
}

notify() {
    local title=$1 body=${2:-} urgency=${3:-low}
    command -v notify-send >/dev/null 2>&1 || return 0
    if [[ -n $body ]]; then
        notify-send -a gpurecord -u "$urgency" -i gpu-screen-recorder \
            -h string:x-canonical-private-synchronous:gpurecord "$title" "$body" || true
    else
        notify-send -a gpurecord -u "$urgency" -i gpu-screen-recorder \
            -h string:x-canonical-private-synchronous:gpurecord "$title" || true
    fi
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
    printf '%s recording\n' "$icon"
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
    rm -f "$pid_file" "$out_file"
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
    notify "$icon Recording failed to start" "$reason"
    return 1
}

cmd_stop() {
    local pid
    if ! pid=$(recorder_pid); then
        rm -f "$pid_file" "$out_file"
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
    rm -f "$pid_file" "$out_file"
    poke_bar
}

cmd_supervise() {
    local out rec rc i stopping=0 reason body

    out_dir=$(readlink -f -- "$out_dir")
    out="$out_dir/$(date +%Y-%m-%d_%H-%M-%S).mp4"

    notify "$icon Recording started" "" low
    sleep "$start_delay"

    gpu-screen-recorder "${default_args[@]}" "$@" -o "$out" >>"$log_file" 2>&1 &
    rec=$!
    printf '%s\n' "$rec" > "$pid_file"
    printf '%s\n' "$out" > "$out_file"

    poke_bar

    for ((i = 0; i < 10; i++)); do
        kill -0 "$rec" 2>/dev/null || break
        sleep 0.1
    done
    if ! kill -0 "$rec" 2>/dev/null; then
        wait "$rec"
        rc=$?
        rm -f "$pid_file" "$out_file"
        poke_bar
        reason=$(tail -n 4 "$log_file" 2>/dev/null | tr '\n' ' ' |
            sed -e 's/  */ /g' -e 's/^ //' -e 's/ $//')
        [[ -n $reason ]] || reason="gpu-screen-recorder exited (rc=$rc)"
        notify "$icon Recording failed to start" "$reason" low
        return 1
    fi

    trap 'stopping=1; kill -INT "$rec" 2>/dev/null' INT TERM HUP
    wait "$rec"
    rc=$?
    if ((stopping)); then
        wait_gone "$rec" 50 || kill -KILL "$rec" 2>/dev/null
    fi
    wait "$rec" 2>/dev/null

    rm -f "$pid_file" "$out_file"
    poke_bar

    body="record save in:$out"
    if ((rc != 0 && rc != 130 && !stopping)); then
        body="$body (abnormal exit rc=$rc)"
    fi
    notify "$icon Recording stopped" "$body" normal
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