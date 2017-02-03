#!/bin/sh -e

SSLDIR="/usr/local/etc/nginx/ssl"
DOMAINSFILE="{{ nginx_letsencrypt_domains_file }}"

cat "${DOMAINSFILE}" | while read domain line ; do
  CERTSDIR="${SSLDIR}/${domain}"
  cp ${CERTSDIR}/priv-key.pem ${CERTSDIR}/key.pem
done

/usr/sbin/service nginx reload
