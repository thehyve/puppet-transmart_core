node 'test.example.com' {
    include ::transmart_core
}

node 'test2.example.com' {
    include ::transmart_core
}

node 'api1.example.com' {
    include ::transmart_core::api_essentials
}

node 'api2.example.com' {
    include ::transmart_core::api_essentials
}

node 'email.example.com' {
    include ::transmart_core
}
