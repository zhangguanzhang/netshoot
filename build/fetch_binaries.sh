#!/usr/bin/env bash
set -e

readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
     jq -r '.tag_name'                                          # Get tag
}

get_latest_assets_list() {
  curl -s  https://api.github.com/repos/$1/releases/latest | jq -r '.assets[].name'
}

if [ -z "$ARCH" ];then
  ARCH=$(uname -m)
  case $ARCH in
      x86_64)
          ARCH=amd64
          ;;
      aarch64)
          ARCH=arm64
          ;;
  esac
fi

bin_dir=${CUR_DIR}/bin/${ARCH}
mkdir -p ${bin_dir}

get_ctop() {
  local file VERSION LINK
  VERSION=$(get_latest_release zhangguanzhang/ctop)
  file=$(get_latest_assets_list zhangguanzhang/ctop | grep -P "linux-${ARCH}\$")
  LINK="https://github.com/zhangguanzhang/ctop/releases/download/${VERSION}/${file}"
  wget "$LINK" -O ${bin_dir}/ctop && chmod +x ${bin_dir}/ctop
  ${bin_dir}/ctop -h
}

get_calicoctl() {
  local file TERM_ARCH VERSION LINK
  VERSION=$(get_latest_release projectcalico/calico)
  file=$(get_latest_assets_list projectcalico/calico | grep calicoctl-linux-${ARCH})
  LINK="https://github.com/projectcalico/calico/releases/download/${VERSION}/${file}"
  wget "$LINK" -O ${bin_dir}/calicoctl && chmod +x ${bin_dir}/calicoctl
  ${bin_dir}/calicoctl version
}

get_termshark() {
  local file TERM_ARCH VERSION LINK
  case "$ARCH" in
    *)
      VERSION=$(get_latest_release zhangguanzhang/termshark)
      if [ "$ARCH" == "amd64" ]; then
        TERM_ARCH=x64
      else
        TERM_ARCH="$ARCH"
      fi

      file=$(get_latest_assets_list zhangguanzhang/termshark | grep linux_${TERM_ARCH}.tar.gz)
      LINK="https://github.com/zhangguanzhang/termshark/releases/download/${VERSION}/${file}"
      wget "$LINK" -O /tmp/termshark.tar.gz && \
      tar -zxvf /tmp/termshark.tar.gz --strip-components=1 -C ${bin_dir}
      chmod +x ${bin_dir}/termshark
      ${bin_dir}/termshark -h
      ;;
  esac
}

get_grpcurl() {
  local file TERM_ARCH VERSION LINK
  if [ "$ARCH" == "amd64" ]; then
    TERM_ARCH=x86_64
  else
    TERM_ARCH="$ARCH"
  fi
  VERSION=$(get_latest_release fullstorydev/grpcurl )
  file=$(get_latest_assets_list fullstorydev/grpcurl | grep linux_${TERM_ARCH}.tar.gz)
  LINK="https://github.com/fullstorydev/grpcurl/releases/download/${VERSION}/${file}"
  wget "$LINK" -O /tmp/grpcurl.tar.gz  && \
  tar --no-same-owner -zxvf /tmp/grpcurl.tar.gz grpcurl && \
  mv "grpcurl" ${bin_dir}/grpcurl && \
  chmod a+x ${bin_dir}/grpcurl
  ${bin_dir}/grpcurl -version
}

get_fortio() {
    local file TERM_ARCH VERSION LINK
  if [ "$ARCH" == "amd64" ]; then
    TERM_ARCH=x86_64
  else
    TERM_ARCH="$ARCH"
  fi
  VERSION=$(get_latest_release fortio/fortio)
  file=$(get_latest_assets_list fortio/fortio | grep -E "linux_${ARCH}-.+.tgz")
  LINK="https://github.com/fortio/fortio/releases/download/${VERSION}/${file}"
  wget "$LINK" -O /tmp/fortio.tgz  && \
  tar -zxvf /tmp/fortio.tgz usr/bin/fortio --strip-components=2 && \
  mv fortio ${bin_dir}/fortio && \
  chmod +x ${bin_dir}/fortio
  ${bin_dir}/fortio version
}


get_ctop
get_calicoctl
get_termshark
get_grpcurl
get_fortio

ls -l ${bin_dir}
