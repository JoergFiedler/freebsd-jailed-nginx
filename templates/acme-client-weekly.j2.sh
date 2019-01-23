#!/bin/sh -e
{{ ansible_managed | comment }}

SSL_DIR="/usr/local/etc/nginx/ssl"
DOMAIN_LIST_FILE="{{ nginx_letsencrypt_domains_file }}"
CHALLENGE_DIR="/var/www/.well-known/acme-challenge"

cat "${DOMAIN_LIST_FILE}" | while read domain line ; do
   certs_dir="${SSL_DIR}/${domain}"
   [[ ! -d "${certs_dir}" ]] && mkdir -pm755 "${certs_dir}"
   set +e # RC=2 when time to expire > 30 days
   acme-client -C "${CHALLENGE_DIR}" \
               -k "${certs_dir}/priv-key.pem" \
               -c "${certs_dir}" \
               -bnNv \
               ${domain} ${line}
   RC=$?
   set -e
   [[ ${RC} -ne 0 && ${RC} -ne 2 ]] && exit ${RC}
done