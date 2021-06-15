# Puppet module for TranSMART.

[![Build Status](https://travis-ci.org/thehyve/puppet-transmart_core.svg?branch=master)](https://travis-ci.org/thehyve/puppet-transmart_core/branches)

This is the repository containing a puppet module for deploying the _TranSMART_ application.
TranSMART is an open source data sharing and analytics platform for translational biomedical research, which
is maintained by the [tranSMART Foundation](http://transmartfoundation.org). Official releases
can be found on the TranSMART Foundation website, and the TranSMART Foundation's development repositories
can be found at <https://github.com/transmart/>.

The module creates system user `transmart` (unless it is configured to a different name) and
installs and configures service `transmart-server`
(a `systemd` process run as user `transmart`).
The repository used to fetch the required TranSMART packages from is configurable and defaults to `repo.thehyve.nl`.

This module only supports the [17.x versions of TranSMART](https://github.com/thehyve/transmart-core).



## Dependencies and installation

The instructions are for installing 
- the [Keycloak] identity provider,
- the [TranSMART API server], and
- the [Glowing Bear] user interface for TranSMART.
- the [GB Backend] application for Glowing Bear.

### Install Puppet

```bash
# For Debian 9 and Ubuntu 18.04
sudo apt install puppet

# For Ubuntu 16.04
wget https://apt.puppetlabs.com/puppet5-release-xenial.deb
sudo dpkg -i puppet5-release-xenial.deb
sudo apt update
sudo apt install puppet5-release

# Check Puppet version, Puppet 5 should be fine.
puppet --version
```

### Operating system packages

The module expects certain packages to be available through the package manager of the operating system (e.g., `yum` or `apt`):
- For all components:
  - `java-1.8.0-openjdk`

### Puppet modules

The module depends on the [archive](https://forge.puppet.com/puppet/archive) and 
[java](https://forge.puppet.com/puppetlabs/java) puppet modules.
For creating the database, the [postgresql](https://forge.puppet.com/puppetlabs/postgresql) module is required.
We use the [keycloak](https://forge.puppet.com/treydock/keycloak) module for Keycloak and [nginx](https://forge.puppet.com/puppet/nginx) as a HTTP proxy, for
configuring SSL certificates. 

The most convenient way is to run `puppet module install` as `root`:
```bash
sudo puppet module install puppet-archive -v 3.0.0
sudo puppet module install puppetlabs-java -v 3.3.0
sudo puppet module install puppetlabs-postgresql
sudo puppet module install treydock-keycloak --version 3.0.0
sudo puppet module install puppet-nginx --version 0.13.0
```

Check the installed modules:
```bash
sudo puppet module list --tree
```

### Install the `transmart_core`, `glowing_bear` and `gb_backend` modules

Copy the `transmart_core`, `glowing_bear` and `gb_backend` module repositories to the `/etc/puppetlabs/code/modules` directory:
```bash
cd /etc/puppetlabs/code/modules
git clone https://github.com/thehyve/puppet-transmart_core.git transmart_core
git clone https://github.com/thehyve/puppet-glowing_bear.git glowing_bear
git clone https://github.com/thehyve/puppet-gb_backend.git gb_backend
```



## Configuration

This tutorial assumes that you want to install Keycloak, TranSMART and Glowing Bear on one server `test.example.com`
with aliases `keycloak.example.com`, `transmart.example.com`, `glowingbear.example.com`.

For configuring TranSMART using this module, the following steps are required:
1. Setting up a Hiera configuration file;
2. Setting up a node manifest;
3. Configure Keycloak;
4. Run Puppet to start the `transmart-server` service;

### 1. Configuring a node using Hiera

It is preferred to configure the module parameters using Hiera.
To get started with Hiera, 
see the documentation for [Puppet 5.5](https://puppet.com/docs/puppet/5.5/hiera_quick.html).
 
Defaults can be configured in a `common.yaml` file, e.g.:
```yaml
transmart_core::keycloak_server_url: https://keycloak.example.com/auth
```

Machine specific configuration can be placed in a machine specific file, e.g.,
`test.example.com.yaml`:
```yaml

# Transmart API server configuration
# transmart_core::disable_server: true
transmart_core::version: 17.2.4
transmart_core::number_of_workers: 2
transmart_core::db_user: db_admin
transmart_core::db_password: <password>
transmart_core::memory: 8g
transmart_core::keycloak_realm: transmart
transmart_core::keycloak_server_url: https://keycloak.example.com/auth
transmart_core::keycloak_client_id: transmart-client
transmart_core::liquibase_on: true

# Glowing Bear configuration
glowing_bear::hostname: glowingbear.example.com
glowing_bear::port: 8085
glowing_bear::transmart_url: https://transmart.example.com
glowing_bear::repository: releases
glowing_bear::version: 2.0.8
glowing_bear::authentication_service_type: oidc
glowing_bear::oidc_server_url: https://keycloak.example.com/auth/realms/transmart/protocol/openid-connect
glowing_bear::oidc_client_id: transmart-client
glowing_bear::gb_backend_url: https://gb-backend.example.com

# Glowing Bear backend configuration
gb_backend::repository: releases
gb_backend::version: 1.0.3
gb_backend::db_password: <password>
gb_backend::transmart_server_url: http://localhost:8080
gb_backend::keycloak_server_url: https://keycloak.example.com/auth
gb_backend::keycloak_realm: transmart
gb_backend::keycloak_client_id: transmart-client
gb_backend::keycloak_offline_token: PLACEHOLDER  # only required for subscribe and notify

# Keycloak configuration
keycloak::proxy_https: true
keycloak::datasource_driver: 'mysql'
keycloak::datasource_host: localhost
keycloak::datasource_port: 3306
keycloak::datasource_dbname: 'keycloak'
keycloak::datasource_username: 'keycloak'
keycloak::datasource_password: '<password>'
keycloak::admin_user: 'admin'
keycloak::admin_user_password: '<password>'
keycloak::http_port: 8081

# Optional PostgreSQL server configuration
postgresql::globals::version: '10'
postgresql::globals::manage_package_repo: true

postgres_config:
  random_page_cost:
    value: 1.1
```

Make sure the naming of the `.yaml` files matches the path patterns in the Hiera hierarchy.

### 2. The node manifest

For each node where you want to install TranSMART, the module needs to be included with
`include ::transmart_core::api_essentials`.

Here is an example manifest file `/etc/puppetlabs/code/environment/production/manifests/test.example.com.pp`:
```puppet
node 'test.example.com' {
  # Install the MySQL database server and Keycloak
  include mysql::server
  include keycloak

  class { 'nginx': }

  # Forward https://keycloak.example.com to port 8081
  nginx::resource::server { 'keycloak.example.com':
    ssl         => true,
    proxy       => 'http://localhost:8081',
    ssl_cert    => '/etc/ssl/certs/example.pem',
    ssl_key     => '/etc/ssl/private/example.key',
    location_cfg_append => {
       'proxy_set_header' => ['X-Forwarded-Proto https'],
    },
  }

  # pspp is required for export to SPSS format.
  ensure_packages(['pspp'], { ensure => 'present' })

  # Apply PostgreSQL configuration parameters, specified in Hiera
  $postgres_config_entries = hiera_hash('postgres_config', {})
  create_resources('postgresql::server::config_entry', $postgres_config_entries)

  include ::transmart_core::api_essentials
  include ::transmart_core::database

  # Forward https://transmart.example.com to port 8080
  nginx::resource::server { 'transmart.example.com':
    ssl         => true,
    proxy       => 'http://localhost:8080',
    ssl_cert    => '/etc/ssl/certs/example.pem',
    ssl_key     => '/etc/ssl/private/example.key',
  }

  include ::glowing_bear::complete

  # Forward https://glowingbear.example.com to port 8085
  nginx::resource::server { 'glowingbear.example.com':
    ssl         => true,
    proxy       => 'http://localhost:8085',
    ssl_cert    => '/etc/ssl/certs/example.pem',
    ssl_key     => '/etc/ssl/private/example.key',
  }

  include ::gb_backend

  # Forward https://gb-backend.example.com to port 8083
  nginx::resource::server { 'gb-backend.example.com':
    ssl         => true,
    proxy       => 'http://localhost:8083',
    ssl_cert    => '/etc/ssl/certs/example.pem',
    ssl_key     => '/etc/ssl/private/example.key',
  }
}
```

This installs `keycloak`, `transmart-api-server`, `glowing-bear` and `gb-backend`
and prepares PostgreSQL for creating a TranSMART database.

The node manifest can also be in another file, e.g., `site.pp`.

### 3. Configure Keycloak

Follow the steps in the [API server documentation](https://github.com/thehyve/transmart-core/tree/dev/transmart-api-server)
for setting up Keycloak with a realm and client for TranSMART.

### 4. Run Puppet to start the `transmart-server` service

```bash
sudo puppet apply test.example.com.pp
```

Check the boot messages of the TranSMART API service:
```bash
sudo journalctl -u transmart-server.service -f
```

> Transmart should now be available on https://transmart.example.com (serving OpenAPI documentation)
> Glowing Bear should now be available on https://glowingbear.example.com (redirecting to Keycloak)


## Module parameters
   
Overview of the parameters that can be used in Hiera to configure the module.
Alternatively, the parameters of the `::transmart_core::params` class can be used to configure these settings.

| Hiera key | Default value | Description |
|-----------|---------------|-------------|
| `transmart_core::version` | `17.2.4` | The version of the TranSMART artefacts to install. |
| `transmart_core::db_user` | | The database admin username. (Mandatory) |
| `transmart_core::db_password` | | The database admin password. (Mandatory) |
| `transmart_core::biomart_user_password` | | The password of the `biomart_user` database user. |
| `transmart_core::memory` | `2g` | The memory limit for the JVM. |
| `transmart_core::app_port` | `8080` | The port the `transmart-server` application runs on. |
| `transmart_core::disable_server` | `false` | (Temporarily) disable `transmart-server`. |
| `transmart_core::number_of_workers` | | Number of threads to use for parallel features. |
| `transmart_core::max_connections` | `50` | Maximum number of database connections used by the application. |
| `transmart_core::keycloak_server_url` |  | Identity provider server url, e.g., `https://oidc.example.com/auth`. |
| `transmart_core::keycloak_realm` |  | A realm is container with clients, users and permissions, e.g., `transmart`. |
| `transmart_core::keycloak_client_id` |  | OpenID Connect client id, e.g., `transmart-client`. |
| `transmart_core::liquibase_on` | `false` | Enables DB update on startup by liquibase. Requires `log2database` to be `false` and `::transmart_core::liquibase` to be included. |
| `transmart_core::install_pg_bitcount` | `false` | Install the [pg_bitcount] module for PostgreSQL. Only supported for Debian/Ubuntu based systems. |

The parameters for the `glowing_bear` module are documented in the [glowing_bear module repository](https://github.com/thehyve/puppet-glowing_bear),
for Keycloak, consult the [keycloak module repository](https://github.com/treydock/puppet-module-keycloak/blob/master/REFERENCE.md).

### Advanced parameters

These parameters usually do no have to be used for installations. If you want to install a development
snapshot version of TranSMART, you need to change the repository. 

| Hiera key | Default value | Description |
|-----------|---------------|-------------|
| `transmart_core::nexus_url` | `https://repo.thehyve.nl` | The Nexus/Maven repository server. |
| `transmart_core::repository` | `releases` | The repository to use. [`snapshots`, `releases`] |
| `transmart_core::user` | `transmart` | System user that runs the application. |
| `transmart_core::user_home` | `/home/${user}` | The user home directory |
| `transmart_core::db_type` | `postgresql` | The database type. [`postgresql`] |
| `transmart_core::db_host` | `localhost` | The database server host name. |
| `transmart_core::db_port` | `5432` / `1521` | The database server port. (`db_port_spec` in the `params` class.) |
| `transmart_core::db_name` | `transmart` / `ORCL` | The database name. (`db_name_spec` in the `params` class.) |



## Advanced options

### Configuring a node in the manifest file

Alternatively, the node specific configuration can also be done with class parameters in the node manifest.
Here is an example:
```puppet
node 'test.example.com' {
    # Site specific configuration for Transmart
    class { '::transmart_core::params':
        db_type      => 'oracle',
        db_user      => 'test as sysdba',
        db_password  => 'my secret',
        db_port_spec => 1521,
        db_name_spec => 'transmart',
    }

    include ::transmart_core::api-server
}
```
Node the use of `db_port_spec` and `db_name_spec` instead of `db_port` and `db_name` here.

### Configuring the use of a proxy
```puppet
node 'test.example.com' {
    # ...

    # Configure a proxy for fetching artefacts
    Archive::Nexus {
        proxy_server => 'http://proxyurl:80',
    }
    # Configure a proxy for fetching packages with yum
    Yumrepo {
        proxy => 'http://proxyurl:80',
    }
}
```



## Manage `systemd` services 

Start the `transmart-server` service:
```bash
sudo systemctl start transmart-server
```
Check the status of the service:
```bash
sudo systemctl status transmart-server
```
Stop the service:
```bash
sudo systemctl stop transmart-server
```
Check log of the service
```bash
sudo journalctl -u transmart-server.service
```

Same commands are applicable to `gb-backend.service`.


## Development

### Test

The module has been tested on Ubuntu 16.04 with Puppet version 5.5.22.
There are some automated tests, run using [rake](https://github.com/ruby/rake).

A version of `ruby` before `2.4` is required. [rvm](https://rvm.io/) can be used to install a specific version of `ruby`.
Use `rvm install 2.4` to use `ruby` version `2.4`.

#### Rake tests

Install rake using the system-wide `ruby`:
```bash
yum install ruby-devel
gem install bundler
export PUPPET_VERSION=5.5.22
bundle
```
or using `rvm`:
```bash
rvm install 2.4
gem install bundler
export PUPPET_VERSION=5.5.22
bundle
```
Run the test suite:
```bash
rake test
```

### Classes

Overview of the classes defined in this module.

| Class name | Description |
|------------|-------------|
| `::transmart_core` | Creates the system users. |
| `::transmart_core::config` | Generates the application configuration. |
| `::transmart_core::backend` | Installs the `transmart-server` service. |
| `::transmart_core::api_essentials` | Installs all of the above. |
| `::transmart_core::solr` | Installs the `transmart-solr` service. |
| `::transmart_core::rserve` | Installs the `transmart-rserve` service. |
| `::transmart_core::essentials` | Installs all of the above. |
| `::transmart_core::data` | Installs `transmart-data` in the `tsloader` home directory. |
| `::transmart_core::batch` | Installs `transmart-batch` in the `tsloader` home directory. |
| `::transmart_core::thehyve_repositories` | Configures The Hyve repositories for `apt` or `yum`. |
| `::transmart_core::complete` | Installs all of the above. |
| `::transmart_core::database` | Installs `postgresql` with the database admin credentials and required tablespace directories. |
| `::transmart_core::liquibase` | Installs `postgresql` and creates a database for use with `liquibase_on: true`. |



## License

Copyright &copy; 2017&ndash;2019 &nbsp; The Hyve.

The puppet module for TranSMART is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the [GNU General Public License](gpl-3.0.txt) along with this program. If not, see https://www.gnu.org/licenses/.

[Keycloak]: https://www.keycloak.org/
[Glowing Bear]: https://glowingbear.app/
[TranSMART API server]: https://github.com/thehyve/transmart-core/tree/dev/transmart-api-server
[GB Backend]: https://github.com/thehyve/gb-backend
[pg_bitcount]: https://github.com/thehyve/pg_bitcount
