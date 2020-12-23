FROM algebr/openface:latest

# Install Crystal
RUN curl -sL "https://keybase.io/crystal/pgp_keys.asc" | sudo apt-key add -
RUN echo "deb http://dist.crystal-lang.org/apt crystal main" | sudo tee /etc/apt/sources.list.d/crystal.list
RUN sudo apt-get update
RUN apt-get install crystal -y

# Setup and compile the tool
WORKDIR /home/majima
COPY ./src ./src
COPY ./data ./data
WORKDIR /home/majima

ENV OPENFACE_EXECUTABLE_PATH /home/openface-build/build/bin/FeatureExtraction
ENV MAJIMA_PATH /home/majima

ENTRYPOINT ["/usr/bin/env"]
CMD ["crystal", "run", "/home/majima/src/one_eyed_daemon.cr"]
