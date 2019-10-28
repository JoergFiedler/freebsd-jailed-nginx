#!/bin/sh -e
{{ ansible_managed | comment }}

SSL_DIR="/usr/local/etc/ssl"
DOMAIN_LIST_FILE="{{ nginx_letsencrypt_domains_file }}"

cat "${DOMAIN_LIST_FILE}" | while read domain line ; do
  certs_dir="${SSL_DIR}/${domain}"
  acme.sh --install-cert \
          --domain ${domain} \
          --cert-file ${certs_dir}/cert.pem \
          --key-file ${certs_dir}/key.pem \
          --ca-file ${certs_dir}/chain.pem \
          --fullchain-file ${certs_dir}/fullchain.pem
done

/usr/sbin/service nginx reload
