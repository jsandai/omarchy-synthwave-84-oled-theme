#!/bin/bash
# Drive plymouthd (x11 renderer on Xvfb) through boot -> password -> wrong -> unlock and screenshot.
set -u
out=$1 mode=${2:-boot}
export DISPLAY=:99
[[ -S /tmp/.X11-unix/X99 ]] || { Xvfb :99 -screen 0 ${SIZE:-1600x1000}x24 >/dev/null 2>&1 & sleep 1; }
shot() { sleep "${2:-0.3}"; import -window root "$out/$1.png"; }
sudo plymouth quit 2>/dev/null; sleep 0.5
conf=$(dirname "$(readlink -f "$0")")/plymouthd.conf
sudo env DISPLAY=:99 unshare -m sh -c "mount --bind $conf /etc/plymouth/plymouthd.conf && \
  exec script -qfc 'plymouthd --no-daemon --debug --debug-file=$out/debug.log --mode=$mode \
  --kernel-command-line=\"quiet splash plymouth.force-renderer=x11\" --graphical-boot --tty=\$(tty)' /dev/null" </dev/null >/dev/null 2>&1 &
sleep 1.5
sudo plymouth show-splash
shot 00-splash 1
for i in 0 1 2 3; do shot pulse-$i 0.75; done
if [[ $mode == boot ]]; then
  ( sudo plymouth ask-for-password --prompt="pw" --number-of-tries=2 --command="grep -qx ok" ) &
  sleep 0.8; shot 10-prompt
  xdotool type --delay 120 "badpw"; shot 11-typing 0.02
  shot 12-typed 0.5
  xdotool key Return; sleep 0.25; shot 13-reprompt-a 0.02; shot 14-reprompt-b 0.25; shot 15-reprompt-c 0.6
  xdotool type --delay 100 "ok"; xdotool key Return
  shot 20-progress-a 0.5; shot 21-progress-b 3
fi
sudo plymouth quit
