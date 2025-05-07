FROM ubuntu:20.04
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y  \
    python3 \
    ssh \
    vim \
    sudo

RUN useradd -m -s /bin/bash picoplayer
RUN echo 'picoplayer  ALL=(ALL) /usr/bin/vi ' > /etc/sudoers.d/picoplayer
RUN chmod 0440 /etc/sudoers.d/picoplayer

RUN mkdir /challenge
RUN mkdir /var/run/sshd
ARG FLAG

COPY password.py /challenge/flag.py
USER root
RUN python3 /challenge/flag.py
RUN rm /challenge/flag.py
RUN /bin/bash set-passwords.sh && rm set-passwords.sh
WORKDIR /home/picoplayer

RUN chmod 0000 /challenge
RUN chmod 0000 /challenge/*

RUN /usr/bin/ssh-keygen -A
RUN sudo service ssh --full-restart

CMD /usr/sbin/sshd -D

EXPOSE 22
# PUBLISH 22 AS ssh
