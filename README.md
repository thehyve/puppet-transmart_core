# Puppet module for TranSMART.

This is the repository containing a puppet module for deploying the _TranSMART_ application.
TranSMART is an open source data sharing and analytics platform for translational biomedical research, which
is maintained by the [tranSMART Foundation](http://transmartfoundation.org). Official releases
can be found on the TranSMART Foundation website, and the TranSMART Foundation's development repositories
can be found at <https://github.com/transmart/>.

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


## Usage

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

The module expects at least the `java::package` to be configured (&geq; JDK 1.8.0), e.g.:
```hiera
---
java::package: java-1.8.0-openjdk
```


## Test
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

