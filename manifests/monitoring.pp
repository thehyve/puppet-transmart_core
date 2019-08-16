class transmart_core::monitoring(
   $url         = lookup ('transmart_core::monitoring::url',String),
) inherits transmart_core::params {
    if $url != '' {
        @monitoring::checks::standalone_check { 'transmart_core':
            implementation  => '::transmart_core::health_check',
            parameters      => {
                url => $url,
            },
        }
    }
}
