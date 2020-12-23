fish:

docker run -it --rm -v (pwd):/home/majima:delegated --name majima majima

To just analyze an already generated OpenFace extraction:

docker run -it --rm -v (pwd):/home/majima:delegated -e ANALYZE=<out dir name> --name majima majima

Other shells:

docker run -it --rm -v \$(pwd):/home/majima:delegated --name majima majima

TODO:

- Figure out why I can't use Process.run properly to stream output
- Full analysis:
  - Time processing
  - Calculate amount of time a face is visible
  - Calculate blinks / minute, adjusted by how long the face is visible
  - Calculate amount of time eyes are closed
- Figure out live streaming
- Setup on home server
