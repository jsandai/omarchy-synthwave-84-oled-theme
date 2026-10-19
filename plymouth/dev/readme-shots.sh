#!/bin/bash
# README captures from a real plymouthd at 1920x1080: unlock, wrong passphrase, boot progress,
# shutdown, and a pulse GIF of the logo glow.
set -u
out=$1; mkdir -p "$out"/raw
export DISPLAY=:99
[[ -S /tmp/.X11-unix/X99 ]] || { Xvfb :99 -screen 0 1920x1080x24 >/dev/null 2>&1 & sleep 1; }
conf=$(dirname "$(readlink -f "$0")")/plymouthd.conf
start() {
  sudo plymouth quit 2>/dev/null; sleep 0.5
  sudo env DISPLAY=:99 unshare -m sh -c "mount --bind $conf /etc/plymouth/plymouthd.conf && \
    exec script -qfc 'plymouthd --no-daemon --mode=$1 \
    --kernel-command-line=\"quiet splash plymouth.force-renderer=x11\" --graphical-boot --tty=\$(tty)' /dev/null" </dev/null >/dev/null 2>&1 &
  sleep 1.5; sudo plymouth show-splash; sleep 0.5
}
shot() { import -window root "$out/raw/$1.png"; }

start boot
# pulse GIF frames: ~3 s cycle
for i in $(seq -w 0 39); do shot gif-$i; sleep 0.04; done
( sudo plymouth ask-for-password --prompt=pw --number-of-tries=2 --command="grep -qx hunter22" ) &
sleep 0.8
xdotool type --delay 90 "hunter2"; sleep 0.35; shot unlock
xdotool key Return; sleep 0.12; shot wrong-a; sleep 0.08; shot wrong-b
sleep 1.2
xdotool type --delay 60 "hunter22"; xdotool key Return
sleep 18; shot boot
sudo plymouth quit; sleep 0.5
start shutdown
sleep 0.2; shot shutdown
sudo plymouth quit
