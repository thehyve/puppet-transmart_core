node 'api1.example.com' {
    include ::transmart_core::api_essentials
}

node 'api2.example.com' {
    include ::transmart_core::api_essentials
}

node 'db-update.example.com' {
    include ::transmart_core::api_essentials
    include ::transmart_core::liquibase
}
