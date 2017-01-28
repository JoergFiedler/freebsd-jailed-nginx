freebsd-jailed-nginx
====================

This role provides a jailed nginx server that listens on `localhost:{80,443}` 
for incoming requests. The role also provides a working SSL configuration. You
can choose between own certificate and Let's Encrypt.`

To see this role in action, have a look at 
[this project of mine](https://github.com/JoergFiedler/freebsd-ansible-demo).

It may be used by other roles to serve WordPress or Joomla installations. To 
access the webroot directory a SFTP server is also configured, which is 
secured by public key authentication.

This role may be used to create SSL terminating proxy that forwards traffic 
to domain specific jails.

Requirements
------------

This role is intent to be used with a fresh FreeBSD installation. There is 
a Vagrant Box with providers for VirtualBox and EC2 you may use.

You will find a sample project which uses this role 
[here](https://github.com/JoergFiedler/freebsd-ansible-demo).

Role Variables
--------------

##### nginx_letsencrypt_enabled
Set to `true` the enabled automatic certificate management with Lets Encrypt
for all nginx servers. Default: `false`.

##### nginx_tarsnap_enabled
Wether the webroot of all nginx servers should be backed up using tarsnap. Has
to be enabled on the host itself (`tarsnap_enabled: true`). Default: 
`{{ tarsnap_enabled }}`.

##### nginx_pf_redirect
If set to `true` traffic to http(s) ports is forwarded to this jails nginx 
server. Default: `false`.

If enabled, the default configuration will forward traffic directed to port 80 
and 443 of the hosts external interface to this jail. This configuration can be 
changed using the `nginx_pf_rdrs` variable.

##### nginx_pf_rdrs
This configures how traffic redirection works. The default configuration 
looks like this.

    nginx_pf_rdrs:
      - ports: ['http', 'https']
        ext_ip: '{{ host_net_ext_ip }}'
        ext_if: '{{ host_net_ext_if }}'

##### nginx_servers
This variable holds an array of nginx server instances for this jail. You 
might want to use this to configure different types of nginx jails, e.g. 
ssl terminating proxy, serve multiple static websites, or a php enable website. 
See example section below.

##### name
The domain name of this server, e.g. `example.com`. Default: `localhost`.

###### aliases
If the server should handle other request then those directed to `server_name`.
Provide a space separated list of domain names. Default: `''`.

###### default
If this server should handle all requests which are not handled by any of the
other configured servers. Default `false`.

##### https.letsencrypt_enabled
If set https is enabled for this server and certificates will be created by
Lets Encrypt and `acme-client`. Default: `false`.

##### php_fpm_enabled
Set to true to install and enable `php-fpm` package. If enabled the following
php packages will be installed: 
  - php56
  - php56-ctype
  - php56-curl
  - php56-dom
  - php56-filter
  - php56-gd
  - php56-iconv
  - php56-json
  - php56-mbstring
  - php56-mcrypt
  - php56-mysql
  - php56-mysqli
  - php56-opcache
  - php56-openssl
  - php56-tidy
  - php56-tokenizer
  - php56-simplexml
  - php56-session
  - php56-sqlite3
  - php56-zip
  - php56-zlib
  - php56-xml
  
##### force_https
Set to `true` if the server should redirect all non-https request to their
https counterparts. Default: `false`.

##### force_www
If the server should redirect to `www` domain names. If set to `true` all 
requests to `name` will be redirected to www subdomain. Add `www.domain.tld`
to `aliases` property. Default: `false`.

##### php_fpm_enabled
Enable `sftp` for this server. Creates an user and adjusts settings as
described below. Default: `false`.

##### sftp.user
The sftp user's  name. Default: `'sftp_{{ name | truncate(5, True, "") }}'`.

##### sftp.uuid
The sftp user's uuid. Default: `5000`.

##### sftp.home
The user's home directory. `sshd` will change root to thisdiretory. 
Default: `'/srv/{{ name }}'`.

##### sftp.port
The external port which should be redirected to the jail using this role. 
Default: `10022`.

##### sftp.authorized_keys
The public key which should be used to authenticate the user. 
Default: `'{{ host_sshd_authorized_keys_file }}'`.

Dependencies
------------

- [JoergFiedler.freebsd-jailed](https://galaxy.ansible.com/JoergFiedler/freebsd-jailed/)

Example Playbook
----------------

Proxy host, that forwards traffic to other jails/hosts.

    - { role: JoergFiedler.freebsd-jailed-nginx,¬
        tags: ['_proxy'],
        nginx_servers: [
          {
            name: 'example.com',
            aliases: 'www.example.com',
            proxy: { host: '10.1.0.200' }
          },
          {
            name: 'external.example.com',
            proxy: { host: 'external.example.com' }
          }
        ],
        jail_name: 'proxy',
        jail_net_ip: '10.1.0.100' }
      }

Configure nginx to serve multiple static websites.

      - { role: JoergFiedler.freebsd-jailed-nginx,
          tags: ['_staticpages'],
          jail_name: 'staticpages',
          nginx_servers: [
            {
              name: 'example.com',
              aliases: 'www.example.com',
              sftp_enabled: true,
              sftp: {
                uuid: 20400,
                authorized_keys: 'file/key.pub',
                port: 20400
              }
            }
          ]
        }

Run a php enable website inside a jail.

    - { role: phpside,
          tags: ['_phpside'],
          jail_name: 'phpside',
          nginx_servers: [{
              name: 'example.com',
              php_fpm_enabled: true,
              sftp_enabled: true,
              sftp: {
                authorized_keys: 'file/key.pub',
                port: 40206
              }
          }],
          jail_net_ip: '10.1.0.206' }


License
-------

BSD

Author Information
------------------

If you like it or do have ideas to improve this project, please open an issue
on GitHub. Thanks.
