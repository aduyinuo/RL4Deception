
FROM ubuntu@sha256:626ffe58f6e7566e00254b638eb7e0f3b11d4da9675088f4781a50ae288f3322


ENV DEBIAN_FRONTEND noninteractive

# Install challenge dependencies within the image
RUN apt-get update && apt-get install -y \
    openssh-server \
    socat \
    python3 \
    python3-pip

# Install python packages
RUN pip3 install pyspellchecker


# Create challenge dir for metadata.json and other file artifacts
RUN mkdir /challenge


# Bring in all environment vars from cmgr
ARG SEED
ARG FLAG_FORMAT
ARG FLAG


COPY config-box.py /challenge/config-box.py
COPY Special.py /usr/local/Special.py
COPY start.sh /opt/start.sh

RUN python3 /challenge/config-box.py



EXPOSE 5555
# PUBLISH 5555 AS ssh
CMD ["/opt/start.sh"]
