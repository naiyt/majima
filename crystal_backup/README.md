fish:

docker run -it --rm -v (pwd):/home/majima:delegated --name majima majima

To just analyze an already generated OpenFace extraction:

docker run -it --rm -v (pwd):/home/majima:delegated -e ANALYZE=<out dir name> --name majima majima

Other shells:

docker run -it --rm -v \$(pwd):/home/majima:delegated --name majima majima

TODO:

- Figure out why I can't use Process.run properly to stream output
- Figure out live streaming
- Setup on home server
