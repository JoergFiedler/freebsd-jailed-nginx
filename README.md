freebsd-jailed-nginx
=========

This role provides a jailed nginx server that listens on `localhost:{80,443}` for incoming requests. For that matter the role provides a decent SSL configuration.

To see this role in action, have a look at [this project of mine](https://github.com/JoergFiedler/freebsd-ansible-demo).

It may be used by other roles to serve Wordpress or Joomla installations. To access the webroot directory a SFTP server is also configured, which is secured by public key authentication.

This role can be used to create SSL terminating proxy that forwards traffic to domain specific jails.

Requirements
------------

This role is intent to be used with a fresh FreeBSD 10.2 installation. There is a Vagrant Box with providers for VirtualBox and EC2 you may use.

You will find a sample project which uses this role [here](https://github.com/JoergFiedler/freebsd-ansible-demo).

Role Variables
--------------
##### nginx_tarsnap_enabled
If this the webroot of this server should be backed up using tarsnap. Has to be enabled on the host itself (`tarsnap_enabled: true`). Default: `{{ tarsnap_enabled }}`.

##### nginx_pf_redirect
If set to `true` traffic to http(s) ports is forwarded to this jails nginx server. Default: `false`.

The default configuration will forward all traffic directed to port 80 and 443 of the hosts external interface to this jail. This configuration can be changed using the `nginx_pf_rdrs` variable.

##### nginx_pf_rdrs
This configures how traffic redirection works. The default configuration looks like this.

    nginx_pf_rdrs:
      - ports: ['http', 'https']
        ext_ip: '{{ host_net_ext_ip }}'
        ext_if: '{{ host_net_ext_if }}'

##### nginx_servers
This variable holds an array of nginx server instances for this jail. You might want to use this to configure different types of nginx jails, e.g. ssl terminating proxy, serve multiple static websides, or a php enable webside. See example section below.

#### nginx_servers
Holds on array of nginx server instances. The following properties for a single server instance.

##### default
If this server should handle all requests which are not handled by any of the other configured servers. Default `false`.

##### name
The domain name of this server, e.g. `example.com'. Default: `none`.

##### aliases
Alternative domain names for this server, e.g. `www.example.com`. Default: `none`.

##### webroot
The webroot directory of this server. Default: `/srv/{{ name }}/webroot`.

##### https.oscp
If set https is enabled for this server and all non-https request are redirected to their secure counterparts. Specifies the OCSP server to ask for caching. Default: `none`.

You have to provide a set of files which contain valid SSL certificates.
   - files/{{ name }}/-key.pem
   - files/{{ name }}/-certbundle.pem
   - files/{{ name }}/-dhparam.pem

##### php
Set to true to install and enable `php-fpm` package. If enabled the following php packages will be installed (php56, php56-ctype, php56-curl, php56-dom, php56-filter, php56-gd, php56-json, php56-mbstring, php56-mcrypt, php56-mysql, php56-mysqli, php56-opcache, php56-openssl, php56-tidy, php56-tokenizer, php56-simplexml, php56-session, php56-sqlite3, php56-zip, php56-zlib, php56-xml)

##### force_https
Set to `true` if the server should redirect all non-https request to their https counterparts. Default: `false`.

##### force_www
If the server should redirect to `www` domain names. If set to `true` all requests to `name` will be redirected to www subdomain. The www alias will be added automatically. Default: `true`.

##### sftp.user
The sftp user's  name. Default: `'sftp_{{ name | truncate(5, True, "") }}'`.

##### sftp.uuid
The sftp user's uuid. Default: `5000`.

##### sftp.home
The user's home directory. SSHD will change root to this diretory. Default: `'/srv/{{ name }}'`.

##### sftp.port
The external port which should be redirected to the jail using this role. Default: `10022`.

##### sftp.authorized_keys
The public key which should be used to authenticate the user. Default: `'{{ host_sshd_authorized_keys_file }}'`.

Dependencies
------------

- [JoergFiedler.freebsd-jailed](https://galaxy.ansible.com/JoergFiedler/freebsd-jailed/)

Example Playbook
----------------

Proxy host, that fowards traffic to other jails/hosts.

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

Configure nginx to serve multiple static websides.

      - { role: JoergFiedler.freebsd-jailed-nginx,
          tags: ['_staticpages'],
          jail_name: 'staticpages',
          nginx_pf_redirect: false,
          nginx_servers: [
            {
              name: 'example.com',
              aliases: 'www.example.com',
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

If you like it or do have ideas to improve this project, please open an issue on Github. Thanks.
