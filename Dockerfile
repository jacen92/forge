FROM ubuntu:20.04

LABEL Version="2.0"
LABEL Maintainer="Nicolas Gargaud <jacen92@gmail.com>"
LABEL Description="Environment to use the forge playbook"

ENV USER_UID 1000
ENV USER_NAME ansible
ENV SHARED_DIRECTORY /opt/shared
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
  && apt-get install -y sudo git nano htop wget tree unzip python3 python3-pip openssh-client \
  && rm -rf /var/lib/apt/lists/

RUN adduser --disabled-password --gecos "" $USER_NAME --uid $USER_UID \
  && usermod -aG sudo $USER_NAME && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
  && echo "$USER_NAME:$USER_NAME" | chpasswd

USER $USER_NAME
RUN mkdir /home/$USER_NAME/.ansible-vault && mkdir /home/$USER_NAME/.ssh
RUN pip3 install --user ansible==2.10.3

USER root
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chown ${USER_NAME}:${USER_NAME} /usr/bin/entrypoint.sh && chmod 0740 /usr/bin/entrypoint.sh

COPY ansible /home/$USER_NAME/forge
COPY .git /home/$USER_NAME/forge/.git
RUN chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/forge && mkdir $SHARED_DIRECTORY && chown -R $USER_NAME:$USER_NAME $SHARED_DIRECTORY

USER $USER_NAME
WORKDIR /home/$USER_NAME/forge
VOLUME ["$SHARED_DIRECTORY"]
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
