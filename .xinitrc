#!/usr/bin/env bash

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto

xrdb -merge -I "$HOME" ~/.Xresources
xmodmap ~/.Xmodmap

xbindkeys
unclutter &
x11_statusbar_text &

exec dwm

