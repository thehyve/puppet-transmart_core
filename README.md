# Puppet module for TranSMART.

This is the repository containing a puppet module for deploying the _TranSMART_ application.
TranSMART is an open source data sharing and analytics platform for translational biomedical research, which
is maintained by the [tranSMART Foundation](http://transmartfoundation.org). Official releases
can be found on the TranSMART Foundation website, and the TranSMART Foundation's development repositories
can be found at <https://github.com/transmart/>.

The module creates system users `transmart` and `tsloader` (unless they are configured to different names),
installs and configures services `transmart-app`, `transmart-solr` and `transmart-rserve`
(`systemd` processes run as user `transmart`),
and downloads and configures dataloading tools `transmart-data` and `transmart-batch` in the home directory of
user `tsloader`.
The repository used to fetch the required TranSMART packages from is configurable and defaults to `repo.thehyve.nl`.

This module only supports the [development version of TranSMART](https://github.com/thehyve/transmart-core),
which is expected to be released later this year.


## Dependencies and installation

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

Copy the `transmart_core` module repository to the `/etc/puppet/modules` directory:
```bash
cd /etc/puppet/modules
git clone https://github.com/thehyve/puppet-transmart_core.git transmart_core
```


## Example

Example `manifests/transmart-test.pp`:
```puppet
node 'transmart-test.example.com' {
    include ::transmart_core::complete
}
```

Configuring the installation can be done with:
```puppet
class { '::transmart_core::params':
    db_type     => 'oracle',
    db_password => 'my secret',
    version     => '17.1-PRERELEASE',
}
```
If you are using `hiera` for configuration, you can do this with:
```hiera
---
java::package: java-1.8.0-openjdk

transmart_core:db_type: oracle
transmart_core::db_password: my secret
transmart_core::version: 17.1-PRERELEASE
```

The module expects at least the `java::package` to be configured (&geq; jdk 1.8.0), e.g.:
```hiera
---
java::package: java-1.8.0-openjdk
```


## Classes

Overview of the classes defined in this module.

| Class name | Description |
|------------|-------------|
| `::transmart_core` | Creates the system users. |
| `::transmart_core::config` | Generates the application configuration. |
| `::transmart_core::backend` | Installs the `transmart-app` service. |
| `::transmart_core::solr` | Installs the `transmart-solr` service. |
| `::transmart_core::rserve` | Installs the `transmart-rserve` service. |
| `::transmart_core::data` | Installs `transmart-data` in the `tsloader` home directory. |
| `::transmart_core::batch` | Installs `transmart-batch` in the `tsloader` home directory. |
| `::transmart_core::database` | Installs `postgresql` with the database admin credentials and required tablespace directories. |
| `::transmart_core::complete` | Installs all of the above. |



## Hiera parameters

Overview of the parameters that can be used in Hiera to configure the module.
Alternatively, the parameters of the `::transmart_core::params` class can be used to configure these settings.

| Hiera key | Default value | Description |
|-----------|---------------|-------------|
| `transmart_core::version` | `17.1-SNAPSHOT` | The version of the TranSMART artefacts to install. |
| `transmart_core::nexus_url` | `https://repo.thehyve.nl` | The Nexus/Maven repository server. |
| `transmart_core::repository` | `snapshots` | The repository to use. [`snapshots`, `releases`] |
| `transmart_core::user` | `transmart` | System user that runs the application. |
| `transmart_core::tsloader_user` | `tsloader` | System user for loading data. |
| `transmart_core::db_user` | | The database admin username. (Mandatory) |
| `transmart_core::db_password` | | The database admin password. (Mandatory) |
| `transmart_core::db_user` | | The database user. (Mandatory) |
| `transmart_core::db_type` | | The database type. [`postgresql`, `oracle`] |
| `transmart_core::db_host` | `localhost` | The database server host name. |
| `transmart_core::db_post` | `5432` / `1521` | The database server port. |
| `transmart_core::biomart_user_password` | | The password of the `biomart_user` database user. |
| `transmart_core::memory` | `2g` | The memory limit for the JVM. |
| `transmart_core::app_port` | `8080` | The port the `transmart-app` application runs on. |
| `transmart_core::transmart_url` | | The external address of the application. |



## Test
The module has been tested on CentOS 7 with Puppet version 3.7.8.
There are some automated tests, run using [rake](https://github.com/ruby/rake).

### Rake tests
Install rake:
```bash
yum install ruby-devel
gem install bundler
export PUPPET_VERSION=$(puppet --version)
bundle
```
Run the test suite:
```bash
rake test
```


## License

Copyright &copy; 2017  The Hyve.

The puppet module for TranSMART is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the [GNU General Public License](gpl-3.0.txt) along with this program. If not, see https://www.gnu.org/licenses/.

