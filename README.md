freebsd-jailed-nginx
=========

This role provides a jailed nginx server that listens on `localhost:{80,443}` for incoming requests. For that matter the role provides a decent SSL configuration.

To see this role in action, have a look at [this project of mine](https://github.com/JoergFiedler/freebsd-ansible-demo).

It may be used by other roles to server Wordpress or Joomla installations. To access the webroot directory a SFTP server is also configured, which is secured by public key authentication.

This role can be used to create SSL terminating proxy that forwards traffic to domain specific jails.

Requirements
------------

This role is intent to be used with a fresh FreeBSD 10.2 installation. There is a Vagrant Box with providers for VirtualBox and EC2 you may use.

You will find a sample project which uses this role [here](https://github.com/JoergFiedler/freebsd-ansible-demo).

Role Variables
--------------
##### nginx_tarsnap_enabled
If this servers nginx webroot should be backed up using tarsnap. Has to be enabled on te jail's host. Default: `false`.

##### default
If this server should handle all requests which are not meant for any of the configured servers. Default `false`.

##### name
The name domain name of this server. Default: `none`.

##### https.oscp
If set https is enabled for this server and all non-https request are redirected to their secure counterparts. Specifies the OCSP server to ask for caching. Default: `none`.

You have to provide a set of files which contain valid SSL certificates.
   - files/{{ name }}/-key.pem
   - files/{{ name }}/-cachain.pem
   - files/{{ name }}/-certbundle.pem
   - files/{{ name }}/-dhparam.pem

##### webroot
The webroot containing the files to serve for this server. Default: `'/srv/{{ name }}/webroot'`.

##### force_www
If the server should redirect to `www` domain names. Default: `false`.

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

    - { role: JoergFiedler.freebsd-jailed-nginx,
        tags: ['_nginx'],
        jail_name: 'nginx',
        jail_net_ip: '10.1.0.3',
        nginx_servers: [
        { default: true,
          name: 'localhost' } ] }

License
-------

BSD

Author Information
------------------

If you like it or do have ideas to improve this project, please open an issue on Github. Thanks.
