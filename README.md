If you need x11:

Setting up x11 w/Docker on macOS: https://gist.github.com/paul-krohn/e45f96181b1cf5e536325d1bdee6c949

docker run -it -e DISPLAY=(local ip):0 -e XAUTHORITY=/.Xauthority --net host -v /tmp/.X11-unix:/tmp/.X11-unix -v ~/.Xauthority:/.Xauthority --rm --name majima majima

If you don't need x11:

fish:

docker run -it --rm -v (pwd)/src:/home/openface-build/majima:delegated --name majima majima

Other shells:

docker run -it --rm -v \$(pwd)/src:/home/openface-build/majima:delegated --name majima majima
