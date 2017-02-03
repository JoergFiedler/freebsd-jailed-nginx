#!/bin/sh -e

SSLDIR="/usr/local/etc/nginx/ssl"
DOMAINSFILE="{{ nginx_letsencrypt_domains_file }}"
CHALLENGEDIR="/var/www/.well-known/acme-challenge"

cat "${DOMAINSFILE}" | while read domain line ; do
   CERTSDIR="${SSLDIR}/${domain}"
   [ ! -d "${CERTSDIR}" ] && mkdir -pm755 "${CERTSDIR}"
   set +e # RC=2 when time to expire > 30 days
   acme-client -C "${CHALLENGEDIR}" \
               -k "${CERTSDIR}/priv-key.pem" \
               -c "${CERTSDIR}" \
               -bnNv \
               ${domain} ${line}
   RC=$?
   set -e
   [ $RC -ne 0 -a $RC -ne 2 ] && exit $RC
done