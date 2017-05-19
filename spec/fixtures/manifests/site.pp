node 'test.example.com' {
    class { '::transmart_core::params':
        db_user     => 'test',
        db_password => 'Passw0rd',
    }
    include ::transmart_core
}

