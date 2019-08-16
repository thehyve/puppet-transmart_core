define transmart_core::health_check(
    String $url         = lookup('dntp::monitoring::health_check::url', String, first, "http://${::fqdn}"),
    Hash $subdue        = { 'days' => { 'all' => [ { 'begin' => '7:00', 'end' => '7:10' } ] } },
    Integer $occurrences = 3,
) {
    $health_check_script = '/usr/local/bin/transmart_health_check.rb'
    ensure_resource('file', $health_check_script, {
        mode    => '0755',
        owner   => 'root',
        source  => 'puppet:///modules/transmart_core/health_check.rb',
    })

    $stats_script = '/usr/local/bin/transmart_stats.rb'
    ensure_resource('file', $stats_script, {
        mode    => '0755',
        owner   => 'root',
        source  => 'puppet:///modules/transmart_core/stats.rb',
    })

    sensu::check { 'check_transmart_health':
        command     => "$health_check_script -l ':::transmart_core.url:::'",
        occurrences => $occurrences,
        subdue      => $subdue,
        standalone  => true,
        timeout     => 30,
    }

    sensu::check { 'transmart-status':
        command     => "$stats_script -l ':::transmart_core.url:::' --scheme 'stats.:::name:::.transmart'",
        type        => 'metric',
        standalone  => true,
        handlers    => 'graphite',
    }

    monitoring::client_data_fragment { 'transmart_core':
        values => {
            url      => $url,
        },
    }
}

