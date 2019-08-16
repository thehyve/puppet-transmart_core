#!/usr/bin/env ruby

require 'net/https'
require 'sensu-plugin/metric/cli'
require 'socket'

class TransmartStatus < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to .$parent.$child',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.transmart"
  option :url,
         short: '-l URL',
         required: true,
         proc: ->(u) { URI(u) }

  def run
    status = create_session
    if status == 1
      status = try_fetch_status
    end
    timestamp = Time.now.to_i
    h = Time.now.hour
    output config[:scheme]+'.status', status, timestamp
    output config[:scheme]+'.hour', h, timestamp
    if h >= 9 and h < 17
      output config[:scheme]+'.office_hour', 1, timestamp
      output config[:scheme]+'.office_hour_status', status, timestamp
    else
      output config[:scheme]+'.office_hour', 0, timestamp
    end
    ok
  end

  private

  def create_session
    uri = config[:url]

    begin
        res = Net::HTTP.get_response(uri)
    rescue StandardError => e
        return 0
    end

    return 0 unless res.is_a?(Net::HTTPSuccess)
    set_cookie_header = res['Set-Cookie']
    return 0 unless set_cookie_header

    1
  end

  def try_fetch_status
    uri = config[:url] + '/health'

    res = Net::HTTP.get_response(uri)

    return 0 unless res.is_a?(Net::HTTPSuccess)

    1
  end

end

