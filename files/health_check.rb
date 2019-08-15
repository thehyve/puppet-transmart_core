#!/usr/bin/env ruby

require 'net/https'

require 'sensu-plugin/check/cli'

# Check that first requests the login page to create a session and then fetches
# status information from the application.
class TransmartHealthCheck < Sensu::Plugin::Check::CLI
  option :url,
         short: '-l URL',
         required: true,
         proc: ->(u) { URI(u) }

  def run
    session_cookie = create_session
    puts "Got cookie: #{session_cookie}"

    status = try_fetch_status session_cookie

    ok 'Connection and status OK'
  end

  private

  def create_session
    uri = config[:url]

    begin
        res = Net::HTTP.get_response(uri)
    rescue StandardError => e
        critical "Unable to connect to #{uri}: #{e}"
    end

    critical "Unexpected code #{res.code} for #{uri}" unless res.is_a?(Net::HTTPSuccess)
    set_cookie_header = res['Set-Cookie']
    critical "No cookie found for #{uri}" unless set_cookie_header

    set_cookie_header.split('; ')[0]
  end

  def try_fetch_status(cookie)
    uri = config[:url] + '/health'

    res = Net::HTTP.get_response(uri)
    puts "status: #{res.body}"

    critical "Unexpected code #{res.code} for #{uri}" unless res.is_a?(Net::HTTPSuccess)

    res.body
  end
end

