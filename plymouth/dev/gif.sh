#!/bin/bash
set -u
out=$1; export DISPLAY=${XVFB_DISPLAY:-:99}  # any free display; it must be 1920x1080
[[ -S /tmp/.X11-unix/X${DISPLAY#:} ]] || { Xvfb $DISPLAY -screen 0 1920x1080x24 >/dev/null 2>&1 & sleep 1; }
conf=$(dirname "$(readlink -f "$0")")/plymouthd.conf
sudo plymouth quit 2>/dev/null; sleep 0.5
sudo env DISPLAY=$DISPLAY unshare -m sh -c "mount --bind $conf /etc/plymouth/plymouthd.conf && \
  exec script -qfc 'plymouthd --no-daemon --mode=boot \
  --kernel-command-line=\"quiet splash plymouth.force-renderer=x11\" --graphical-boot --tty=\$(tty)' /dev/null" </dev/null >/dev/null 2>&1 &
sleep 1.5; sudo plymouth show-splash; sleep 1
ffmpeg -loglevel error -y -f x11grab -draw_mouse 0 -framerate 20 -video_size 1920x1080 -i $DISPLAY -t 9 "$out"
sudo plymouth quit
