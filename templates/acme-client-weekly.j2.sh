#!/bin/sh -e
{{ ansible_managed | comment }}

SSL_DIR="/usr/local/etc/ssl"
DOMAIN_LIST_FILE="{{ nginx_letsencrypt_domains_file }}"
CHALLENGE_DIR="/var/www"

cat "${DOMAIN_LIST_FILE}" | while read domain line ; do
  multi_domains="--domain ${domain}"
  certs_dir="${SSL_DIR}/${domain}"
  test ! -d "${certs_dir}" && mkdir -p 755 "${certs_dir}"
  for d in $line; do
    multi_domains="${multi_domains} --domain ${d}"
  done
  acme.sh --issue \
          --webroot ${CHALLENGE_DIR} \
          --keylength 2048 \
          ${multi_domains}
  RC=$?
  set -e
  test "${RC}" != "0" -a "${RC}" != "2" && exit "${RC}"
done