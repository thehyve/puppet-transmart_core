# Puppet module for TranSMART.

This is the repository containing a puppet module for deploying the _TranSMART_ application.
TranSMART is an open source data sharing and analytics platform for translational biomedical research, which
is maintained by the [tranSMART Foundation](http://transmartfoundation.org). Official releases
can be found on the TranSMART Foundation website, and the TranSMART Foundation's development repositories
can be found at <https://github.com/transmart/>.

This module only supports the [development version of TranSMART](https://github.com/thehyve/transmart-core),
which is expected to be released later this year.

## Usage
Example `manifests/transmart-test.pp`:
```puppet
node 'transmart-test.example.com' {
    include ::transmart_core::complete
}
```
Setting up a different Nexus repository for fetching TranSMART artefacts can be done with:
```puppet
Transmart_Core {
    nexus_repository => 'https://repo.thehyve.nl',
}
```
If you are using `hiera` for configuration, you can configure the repository with:
```hiera
---
transmart_core::nexus_repository: https://repo.thehyve.nl
```

## Test
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

