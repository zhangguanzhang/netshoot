ARG BASE_IMG=alpine:3.23

FROM ${BASE_IMG} AS bin

COPY build/bin/ /tmp/

RUN set -ex; \
	case "$(uname -m)" in \
	'amd64' | 'x86_64') \
		GOARCH='amd64' \
		;; \
	'mips64' | 'mips64le' | 'mips64el') \
		GOARCH='mips64el' \
		;; \
	'aarch64') \
		GOARCH='arm64' \
		;; \
	'loongarch64') \
		GOARCH='loong64' \
		;; \
	esac; \
	\
	ls -l /tmp /tmp/${GOARCH}/; \
	mv /tmp/${GOARCH}/* /opt/

FROM ${BASE_IMG}

RUN set -ex; \
    if [ $(uname -m) != loongarch64 ];then \
      echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories; \
      echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories; \
      echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories; \
    fi; \
    apk update; \
    apk add --no-cache \
      apache2-utils \
      bash \
      bind-tools \
      bird \
      bridge-utils \
      busybox-extras \
      conntrack-tools \
      curl \
      dhcping \
      drill \
      ethtool \
      file\
      fping \
      iftop \
      iperf \
      iperf3 \
      iproute2 \
      ipset \
      iptables \
      iptraf-ng \
      iputils \
      ipvsadm \
      httpie \
      jq \
      libc6-compat \
      liboping \
      ltrace \
      mtr \
      net-snmp-tools \
      netcat-openbsd \
      nftables \
      ngrep \
      nmap \
      nmap-nping \
      nmap-scripts \
      openssl \
      py3-pip \
      py3-setuptools \
      scapy \
      socat \
      speedtest-cli \
      openssh \
      oh-my-zsh \
      strace \
      tcpdump \
      tcptraceroute \
      tshark \
      util-linux \
      vim \
      git \
      zsh \
      websocat \
      perl-crypt-ssleay \
      perl-net-ssleay \
    ; \
    if [ $(uname -m) != loongarch64 ];then \
      apk add --no-cache \
        trippy \
        swaks \
      ; \
    fi;

COPY --from=bin /opt/* /usr/local/bin/

# Setting User and Home
USER root
WORKDIR /root
ENV HOSTNAME=netshoot

# ZSH Themes
RUN set -eux; \
  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh; \
  find /root/.oh-my-zsh/plugins -type f -name demo.gif -delete;
  
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
COPY zshrc .zshrc
COPY motd motd

# Fix permissions for OpenShift and tshark
RUN chmod -R g=u /root
RUN chown root:root /usr/bin/dumpcap

# Running ZSH
CMD ["zsh"]
