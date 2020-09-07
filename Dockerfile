FROM algebr/openface:latest

RUN apt-get update && apt-get install x11-apps -y

WORKDIR /home/openface-build

COPY testvideo.mov .

COPY ./src ./majima
