freebsd-jailed-nginx
=========

This role provides a jailed nginx server that listens on `localhost:{80,443}` for incoming requests. For that matter the role provides a decent SSL configuration.

To see this role in action, have a look at [this project of mine](https://github.com/JoergFiedler/freebsd-ansible-demo).

Requirements
------------

This role is intent to be used with a fresh FreeBSD 10.2 installation. There is a Vagrant Box with providers for VirtualBox and EC2 you may use.

You will find a sample project which uses this role [here](https://github.com/JoergFiedler/freebsd-ansible-demo).

Role Variables
--------------

##### nginx

    nginx: {
      pf_rdrs: [
        { ports: ['http', 'https'],
          ext_ip: '{{ host_net_ext_ip }}',
          ext_if: '{{ host_net_ext_if }}' }
      ],
      servers: [{
        default: true,
        name: "localhost",
        aliases: "127.0.0.1",
        https: {
          oscp_server: "localhost",
        },
        webroot: '/usr/local/www/nginx'
      ]
    }


Dependencies
------------

- [JoergFiedler.freebsd-jailed](https://galaxy.ansible.com/detail#/role/6599)

Example Playbook
----------------

    - { role: JoergFiedler.freebsd-jailed-nginx,
        tags: ['nginx'],
        use_ssmtp: true,
        use_syslogd_server: true,
        jail_name: 'nginx',
        jail_net_ip: '10.1.0.5' }

License
-------

BSD

Author Information
------------------

If you like it or do have ideas to improve this project, please open an issue on Github. Thanks.
