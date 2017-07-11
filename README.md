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

### Puppet modules
Install the `maven`, `archive` and `java` modules as `root`:
```bash
sudo puppet module install maestrodev-maven
sudo puppet module install puppet-archive
sudo puppet module install puppetlabs-java
```
If you want to let the module install PostgreSQL as well, install the `postgresql` module:
```bash
sudo puppet module install puppetlabs-postgresql
```

### The `transmart_core` module
Copy the `transmart_core` module repository to the `/etc/puppet/modules` directory:
```bash
cd /etc/puppet/modules
git clone https://github.com/thehyve/puppet-transmart_core.git transmart_core
```

### Hiera
Configure `/etc/puppet/hiera.yaml`. Example:
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
Defaults can then be configured in `/etc/puppet/hieradata/default.yaml`:
```yaml
---
java::package: java-1.8.0-openjdk

transmart_core::db_type: postgresql
```
Machine specific configuration should be in `/etc/puppet/hieradata/${hostname}.yaml`, e.g.,
`/etc/puppet/hieradata/example.thehyve.net.yaml`:
```yaml
---
transmart_core::db_user: test
transmart_core::memory: 4g
transmart_core::transmart_url: https://example.thehyve.net
```


## Example

Example manifest file `manifests/transmart-test.example.com.pp`:
```puppet
node 'transmart-test.example.com' {
    include ::transmart_core::complete
}
```
This installs `transmart-server`, `solr`, `rserve` and `transmart-data`.

Configuring the installation can be done in `/etc/puppet/hieradata/transmart-test.example.com.yaml` with:
```yaml
---
java::package: java-1.8.0-openjdk

transmart_core:db_type: oracle
transmart_core::db_password: my secret
transmart_core::db_host: 10.0.2.2
transmart_core::db_port: 1521
```

Alternatively, the host specific configuration can also be done with class parameters in `manifests/transmart-test.example.com.pp`:
```puppet
class { '::transmart_core::params':
    db_type     => 'oracle',
    db_password => 'my secret',
}
```

The module expects at least the `java::package` to be configured (&geq; jdk 1.8.0), e.g.:
```yaml
---
java::package: java-1.8.0-openjdk
```
It is a good idea to put this in the `default.yaml`.


## Masterless installation
Instructions on installing the `examples/complete.pp` manifest without a puppet master (using `puppet apply`).
This generates the required configuration files and installs: 
- `transmart-server`
- `solr`
- `rserve`
- `transmart-data` (the database provisioning repository, in the home directory of user `tsloader`)

```bash
sudo puppet apply --modulepath=$modulepath examples/complete.pp
```
`modulepath` - is a list of directories puppet will find modules in, separated by the system path-separator character (on Ubuntu/CentOS it is ":").
Example:
```bash
sudo puppet apply --modulepath=/home/$user/puppet/:/etc/puppet/modules examples/complete.pp
```

### Database installation
To install `postgresql` with the database admin credentials and required tablespace directories, run:
```bash
sudo puppet apply --modulepath=$modulepath examples/postgres.pp
```

Source the `vars` file (as user `tsloader`):
```bash
cd /home/tsloader/transmart-data-17.1-RC1
. ./vars
```
Create the database and load everything:
```bash
make -j4 postgres

make -j4 oracle
```
Create the database and load test data:
```bash
make -j4 postgres_test

make -j4 oracle_test
```


## Manage `systemd` services 

Start `transmart-server` service:
```bash
sudo systemctl start transmart-server
```
Check a status of the service:
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
| `::transmart_core::data` | Installs `transmart-data` in the `tsloader` home directory. |
| `::transmart_core::batch` | Installs `transmart-batch` in the `tsloader` home directory. |
| `::transmart_core::complete` | Installs all of the above. |
| `::transmart_core::database` | Installs `postgresql` with the database admin credentials and required tablespace directories. |


## Hiera parameters

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
| `transmart_core::db_port` | `5432` / `1521` | The database server port. |
| `transmart_core::db_name` | `transmart` / `ORCL` | The database name. |
| `transmart_core::biomart_user_password` | | The password of the `biomart_user` database user. |
| `transmart_core::tm_cz_user_password` | | The password of the `tm_cz_user` database user. |
| `transmart_core::memory` | `2g` | The memory limit for the JVM. |
| `transmart_core::app_port` | `8080` | The port the `transmart-server` application runs on. |
| `transmart_core::transmart_url` | | The external address of the application. |


## License

Copyright &copy; 2017  The Hyve.

Use of the puppet module for TranSMART by Institut de Recherches Servier (IDRS) is subject to the terms in the Puppet Scripts License Agreement between 
The Hyve B.V. and IDRS.

