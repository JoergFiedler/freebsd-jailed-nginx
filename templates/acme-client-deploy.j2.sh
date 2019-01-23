#!/bin/sh -e
{{ ansible_managed | comment }}

SSL_DIR="/usr/local/etc/nginx/ssl"
DOMAIN_LIST_FILE="{{ nginx_letsencrypt_domains_file }}"

cat "${DOMAIN_LIST_FILE}" | while read domain line ; do
  certs_dir="${SSL_DIR}/${domain}"
  cp ${certs_dir}/priv-key.pem ${certs_dir}/key.pem
done

/usr/sbin/service nginx reload
