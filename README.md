# Puppet module for TranSMART.

This is the repository containing a puppet module for deploying the _TranSMART_ application.
TranSMART is an open source data sharing and analytics platform for translational biomedical research, which
is maintained by the [tranSMART Foundation](http://transmartfoundation.org). Official releases
can be found on the TranSMART Foundation website, and the TranSMART Foundation's development repositories
can be found at <https://github.com/transmart/>.

The module creates system users `transmart` and `tsloader` (unless they are configured to different names),
installs and configures services `transmart-server`, `transmart-solr` and `transmart-rserve`
(`systemd` processes run as user `transmart`),
and downloads and configures dataloading tools `transmart-data` and `transmart-batch` in the home directory of
user `tsloader`.
The repository used to fetch the required TranSMART packages from is configurable and defaults to `repo.thehyve.nl`.

This module only supports the [development version of TranSMART](https://github.com/thehyve/transmart-core),
which is expected to be released later this year.


## Dependencies and installation

### Operating system packages
The module expects certain packages to be available through the package manager of the operating system (e.g., `yum` or `apt`):
- For all components:
  - `java-1.8.0-openjdk`
- For `transmart-rserve`:
  - `libpng12`
  - `cairo`
  - `dejavu-sans-fonts`
  - `dejavu-sans-mono-fonts`
  - `dejavu-serif-fonts`
  - `libgfortran`
  - `libgomp`
  - `pango`
  - `readline`
  - `urw-fonts`
  - `xorg-x11-fonts-Type1`
  - `xorg-x11-fonts-misc`
- For `transmart-data`:
  - `php`
  - `groovy`
  - `make`

### Puppet modules
The module depends on the `archive` and `java` puppet modules.

The most convenient way is to run `puppet module install` as `root`:
```bash
sudo puppet module install puppet-archive
sudo puppet module install puppetlabs-java
```
Alternatively, the modules and their dependencies can be cloned from `github.com`
and copied into `/etc/puppet/modules`:
```bash
git clone https://github.com/voxpupuli/puppet-archive.git archive
pushd archive; git checkout v0.5.1; popd
git clone https://github.com/puppetlabs/puppetlabs-java.git java
pushd java; git checkout 1.6.0; popd
git clone https://github.com/puppetlabs/puppetlabs-stdlib stdlib
pushd stdlib; git checkout 4.17.0; popd
cp -r archive java stdlib /etc/puppet/modules/
```

If you want to let the module install PostgreSQL as well, install the `postgresql` module:
```bash
sudo puppet module install puppetlabs-postgresql
```

### Install the `transmart_core` module
Copy the `transmart_core` module repository to the `/etc/puppet/modules` directory:
```bash
cd /etc/puppet/modules
git clone https://github.com/thehyve/puppet-transmart_core.git transmart_core
```

## Configuration

### The node manifest

For each node where you want to install TranSMART, the module needs to be included with
`include ::transmart_core::complete`.

Here is an example manifest file `manifests/test.example.com.pp`:
```puppet
node 'test.example.com' {
    include ::transmart_core::complete
}
```
This installs `transmart-server`, `solr`, `rserve`, `transmart-data`, and `transmart-batch`.
The node manifest can also be in another file, e.g., `site.pp`.

### Configuring a node using Hiera

It is preferred to configure the module parameters using Hiera.

To activate the use of Hiera, configure `/etc/puppet/hiera.yaml`. Example:
```yaml
---
:backends:
  - yaml
:yaml:
  :datadir: '/etc/puppet/hieradata'
:hierarchy:
  - '%{::clientcert}'
  - 'default'
```
Defaults can then be configured in `/etc/puppet/hieradata/default.yaml`, e.g.:
```yaml
---
transmart_core::db_type: postgresql
```

Machine specific configuration should be in `/etc/puppet/hieradata/${hostname}.yaml`, e.g.,
`/etc/puppet/hieradata/test.example.com.yaml`:
```yaml
---
transmart_core::db_user: test as sysdba
transmart_core::db_type: oracle
transmart_core::db_password: my secret
transmart_core::db_host: 10.0.2.2
transmart_core::db_name: transmart
transmart_core::db_port: 1521
transmart_core::memory: 4g
transmart_core::transmart_url: https://test.example.com
```

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
        db_name_spec => 'transmart,
    }

    include ::transmart_core::complete
}
```
Node the use of `db_port_spec` and `db_name_spec` instead of `db_port` and `db_name` here.

### Configuring the use of a proxy
```puppet
node 'test.example.com' {
    ...

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


## Masterless installation
It is also possible to use the module without a Puppet master by applying a manifest directly using `puppet apply`.

There is an example manifest in `examples/complete.pp` for generating the required configuration files and installing
`transmart-server`, `solr`, `rserve`, `transmart-data`, and `transmart-batch`.

```bash
sudo puppet apply --modulepath=${modulepath} examples/complete.pp
```
where `modulepath` is a list of directories where Puppet can find modules in, separated by the system path-separator character (on Ubuntu/CentOS it is `:`).
Example:
```bash
sudo puppet apply --modulepath=${HOME}/puppet/:/etc/puppet/modules examples/complete.pp
```

## Database installation and preparation

### Create a PostgreSQL database
To install `postgresql` with the database admin credentials and required tablespace directories, run:
```bash
sudo puppet apply --modulepath=${modulepath} examples/postgres.pp
```

### Prepare the database for TranSMART
Source the `vars` file (as user `tsloader`):
```bash
sudo -iu tsloader
cd ~/transmart-data-17.1-*
source ./vars
```
Create the database and load essential data:
```bash
# For PostgreSQL
make -j4 postgres

# For Oracle
make -j4 oracle
```
Create the database and load test data:
```bash
# For PostgreSQL
make -j4 postgres_test

# For Oracle
make -j4 oracle_test
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
Check a full log of service build
```bash
journalctl -u transmart-server - build log
```


## Test
The module has been tested on Ubuntu 16.04 and CentOS 7 with Puppet version 3.8.7.
There are some automated tests, run using [rake](https://github.com/ruby/rake).

A version of `ruby` before `2.3` is required. [rvm](https://rvm.io/) can be used to install a specific version of `ruby`.
Use `rvm install 2.1` to use `ruby` version `2.1`.

The tests are automatically run on our Bamboo server: [PUPPET-PUPPETTS](https://ci.ctmmtrait.nl/browse/PUPPET-PUPPETTS).

### Rake tests
Install rake using the system-wide `ruby`:
```bash
yum install ruby-devel
gem install bundler
export PUPPET_VERSION=3.8.7
bundle
```
or using `rvm`:
```bash
rvm install 2.1
gem install bundler
export PUPPET_VERSION=3.8.7
bundle
```
Run the test suite:
```bash
rake test
```

## Classes

Overview of the classes defined in this module.

| Class name | Description |
|------------|-------------|
| `::transmart_core` | Creates the system users. |
| `::transmart_core::config` | Generates the application configuration. |
| `::transmart_core::backend` | Installs the `transmart-server` service. |
| `::transmart_core::solr` | Installs the `transmart-solr` service. |
| `::transmart_core::rserve` | Installs the `transmart-rserve` service. |
| `::transmart_core::essentials` | Installs all of the above. |
| `::transmart_core::data` | Installs `transmart-data` in the `tsloader` home directory. |
| `::transmart_core::batch` | Installs `transmart-batch` in the `tsloader` home directory. |
| `::transmart_core::thehyve_repositories` | Configures The Hyve repositories for `apt` or `yum`. |
| `::transmart_core::complete` | Installs all of the above. |
| `::transmart_core::database` | Installs `postgresql` with the database admin credentials and required tablespace directories. |


## Module parameters

Overview of the parameters that can be used in Hiera to configure the module.
Alternatively, the parameters of the `::transmart_core::params` class can be used to configure these settings.

| Hiera key | Default value | Description |
|-----------|---------------|-------------|
| `transmart_core::version` | `17.1-RC1` | The version of the TranSMART artefacts to install. |
| `transmart_core::nexus_url` | `https://repo.thehyve.nl` | The Nexus/Maven repository server. |
| `transmart_core::repository` | `releases` | The repository to use. [`snapshots`, `releases`] |
| `transmart_core::user` | `transmart` | System user that runs the application. |
| `transmart_core::user_home` | `/home/${user}` | The user home directory |
| `transmart_core::tsloader_user` | `tsloader` | System user for loading data. |
| `transmart_core::db_user` | | The database admin username. (Mandatory) |
| `transmart_core::db_password` | | The database admin password. (Mandatory) |
| `transmart_core::db_type` | | The database type. [`postgresql`, `oracle`] |
| `transmart_core::db_host` | `localhost` | The database server host name. |
| `transmart_core::db_port` | `5432` / `1521` | The database server port. (`db_port_spec` in the `params` class.) |
| `transmart_core::db_name` | `transmart` / `ORCL` | The database name. (`db_name_spec` in the `params` class.) |
| `transmart_core::biomart_user_password` | | The password of the `biomart_user` database user. |
| `transmart_core::tm_cz_user_password` | | The password of the `tm_cz_user` database user. |
| `transmart_core::memory` | `2g` | The memory limit for the JVM. |
| `transmart_core::app_port` | `8080` | The port the `transmart-server` application runs on. |
| `transmart_core::transmart_url` | | The external address of the application. |
| `transmart_core::disable_server` | `false` | (Temporarily) disable `transmart-server`. |


## License

Copyright &copy; 2017&ndash;2018 &nbsp; The Hyve.

The puppet module for TranSMART is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the [GNU General Public License](gpl-3.0.txt) along with this program. If not, see https://www.gnu.org/licenses/.

