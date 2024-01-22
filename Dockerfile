FROM ubuntu:22.04

LABEL Version="4.0"
LABEL Maintainer="Nicolas Gargaud <jacen92@gmail.com>"
LABEL Description="Environment to use the forge playbook"

ENV USER_UID 1000
ENV USER_NAME ansible
ENV PATH /home/$USER_NAME/.local/bin/:/usr/local/go/bin:$PATH
ENV SHARED_DIRECTORY /opt/shared
ENV DEBIAN_FRONTEND noninteractive
ENV EDITOR nano
RUN apt-get update \
  && apt-get install -y sudo git nano htop wget tree unzip python3 python3-pip openssh-client libnss3-tools zip \
  && rm -rf /var/lib/apt/lists/

RUN adduser --disabled-password --gecos "" $USER_NAME --uid $USER_UID \
  && usermod -aG sudo $USER_NAME && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
  && echo "$USER_NAME:$USER_NAME" | chpasswd
# install mkcert tool to make CA if not provided
RUN wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz && rm -rf /usr/local/go && tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
RUN cd /home/$USER_NAME/ && git clone https://github.com/FiloSottile/mkcert && cd mkcert && go build -ldflags "-X main.Version=$(git describe --tags)"

USER $USER_NAME
RUN mkdir /home/$USER_NAME/.ansible-vault && mkdir /home/$USER_NAME/.ssh
RUN pip3 install --user ansible

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
