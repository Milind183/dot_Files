# Set wallpaper using feh
feh --bg-scale ~/Downloads/walls/abstract-swirls.jpg &

# Start Picom for compositing
picom --config ~/.config/picom/picom.conf &

#Start your window manager
exec dwm 

