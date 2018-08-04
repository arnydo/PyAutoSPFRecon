#!/bin/bash
set -e

ROOT_PASSWORD=${ROOT_PASSWORD:-password}

BIND_DATA_DIR=${DATA_DIR}/bind

create_bind_data_dir() {
  mkdir -p ${BIND_DATA_DIR}

  # populate default bind configuration if it does not exist
  if [ ! -d ${BIND_DATA_DIR}/etc ]; then
    mv /etc/bind ${BIND_DATA_DIR}/etc
  fi
  rm -rf /etc/bind
  ln -sf ${BIND_DATA_DIR}/etc /etc/bind
  chmod -R 0775 ${BIND_DATA_DIR}
  chown -R ${BIND_USER}:${BIND_USER} ${BIND_DATA_DIR}

  if [ ! -d ${BIND_DATA_DIR}/lib ]; then
    mkdir -p ${BIND_DATA_DIR}/lib
    chown ${BIND_USER}:${BIND_USER} ${BIND_DATA_DIR}/lib
  fi
  rm -rf /var/lib/bind
  ln -sf ${BIND_DATA_DIR}/lib /var/lib/bind
}

set_root_passwd() {
  echo "root:$ROOT_PASSWORD" | chpasswd
}

create_pid_dir() {
  mkdir -m 0775 -p /var/run/named
  chown root:${BIND_USER} /var/run/named
}

create_bind_cache_dir() {
  mkdir -m 0775 -p /var/cache/bind
  chown root:${BIND_USER} /var/cache/bind
}

create_zone_file() {
  touch ${BIND_DATA_DIR}/etc/${DOMAIN}
  echo "$TTL 3D" > ${BIND_DATA_DIR}/etc/${DOMAIN}
  echo "@   IN  SOA ${SOA}. ${SOA_EMAIL} (" >> ${BIND_DATA_DIR}/etc/${DOMAIN}
  echo "199802151   ; serial, todays date + todays serial #" >> ${BIND_DATA_DIR}/etc/${DOMAIN}
  echo "21600   ; refresh, seconds" >> ${BIND_DATA_DIR}/etc/${DOMAIN}
  echo "3600    ; retry, seconds" >> ${BIND_DATA_DIR}/etc/${DOMAIN}
  echo "604800  ; expire, seconds" >> ${BIND_DATA_DIR}/etc/${DOMAIN}
  echo "30 )    ; minimum, seconds" >> ${BIND_DATA_DIR}/etc/${DOMAIN}
  echo "    NS  ns  ; Inet Address of name server" >> ${BIND_DATA_DIR}/etc/${DOMAIN}
  echo "localhost   A   127.0.0.1" >> ${BIND_DATA_DIR}/etc/${DOMAIN}
  echo "ns  A   ${NS_IP}" >> ${BIND_DATA_DIR}/etc/${DOMAIN}
}

add_zone () {
  echo "zone \"${DOMAIN}\" {" >> ${BIND_DATA_DIR}/etc/named.conf.local
  echo "  type master;" >> ${BIND_DATA_DIR}/etc/named.conf.local
  echo "  file ${BIND_DATA_DIR}/etc/${DOMAIN}" >> ${BIND_DATA_DIR}/etc/named.conf.local
  echo "};" >> ${BIND_DATA_DIR}/etc/named.conf.local
}

create_pid_dir
create_bind_data_dir
create_bind_cache_dir
create_zone_file
add_zone

# allow arguments to be passed to named
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
elif [[ ${1} == named || ${1} == $(which named) ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

# default behaviour is to launch named
if [[ -z ${1} ]]; then
  echo "Starting named..."
  exec $(which named) -u ${BIND_USER} -g ${EXTRA_ARGS}
else
exec "$@"
fi
