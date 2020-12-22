fish:

docker run -it --rm -v (pwd)/src:/home/majima/src:delegated --name majima majima

Other shells:

docker run -it --rm -v \$(pwd)/src:/home/majima/src:delegated --name majima majima

TODO:

- Figure out why I can't use Process.run properly to stream output
- Fix the absolute paths in the blink detector
- Can I setup a file listener daemon, like I did in Ruby?
- Full analysis:
  - Calculate amount of time a face is visible
  - Calculate blinks / minute, adjusted by how long the face is visible
  - Calculate amount of time eyes are closed
- Figure out live streaming
- Setup on home server
