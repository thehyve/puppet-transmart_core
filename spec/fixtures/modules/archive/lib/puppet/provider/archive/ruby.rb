# This provider implements a simple state-machine. The following attempts to #
# document it. In general, `def adjective?` implements a [state], while `def
# verb` implements an {action}.
# Some states are more complex, as they might depend on other states, or trigger
# actions. Since this implements an ad-hoc state-machine, many actions or states
# have to guard themselves against being called out of order.
#
# [exists?]
#   |
#   v
# [extracted?] -> no -> [checksum?]
#    |
#    v
#   yes
#    |
#    v
# [path.exists?] -> no -> {cleanup}
#    |                    |    |
#    v                    v    v
# [checksum?]            yes. [extracted?] && [cleanup?]
#                              |
#                              v
#                            {destroy}
#
# Now, with [exists?] defined, we can define [ensure]
# But that's just part of the standard puppet provider state-machine:
#
# [ensure] -> absent -> [exists?] -> no.
#   |                     |
#   v                     v
#  present               yes
#   |                     |
#   v                     v
# [exists?]            {destroy}
#   |
#   v
# {create}
#
# Here's how we would extend archive for an `ensure => latest`:
#
#  [exists?] -> no -> {create}
#    |
#    v
#   yes
#    |
#    v
#  [ttl?] -> expired -> {destroy} -> {create}
#    |
#    v
#  valid.
#

Puppet::Type.type(:archive).provide(:ruby) do
  optional_commands aws: 'aws'
  defaultfor feature: :microsoft_windows
  attr_reader :archive_checksum

  def exists?
    return checksum? unless extracted?
    return checksum? if File.exist? archive_filepath
    cleanup
    true
  end

  def create
  end

  def destroy
  end

  def archive_filepath
    resource[:path]
  end

  def tempfile_name
    "#{resource[:filename]}_#{resource[:checksum]}"
  end

  def creates
    if resource[:extract] == :true
      extracted? ? resource[:creates] : 'archive not extracted'
    else
      resource[:creates]
    end
  end

  def creates=(_value)
    extract
  end

  def checksum
    resource[:checksum] || (resource[:checksum] = remote_checksum if resource[:checksum_url])
  end

  def remote_checksum
  end

  # Private: See if local archive checksum matches.
  # returns boolean
  def checksum?(store_checksum = true)
    return false unless File.exist? archive_filepath
    return true  if resource[:checksum_type] == :none
  end

  def cleanup
    return unless extracted? && resource[:cleanup] == :true
    Puppet.debug("Cleanup archive #{archive_filepath}")
    destroy
  end

  def extract
    return unless resource[:extract] == :true
    raise(ArgumentError, 'missing archive extract_path') unless resource[:extract_path]
  end

  def extracted?
    resource[:creates] && File.exist?(resource[:creates])
  end

  def transfer_download(archive_filepath)
    if resource[:temp_dir] && !File.directory?(resource[:temp_dir])
      raise Puppet::Error, "Temporary directory #{resource[:temp_dir]} doesn't exist"
    end
  end

  def move_file_in_place(from, to)
  end

  def download(filepath)
  end

  def puppet_download(filepath)
  end

  def s3_download(path)
  end

  def optional_switch(value, option)
    if value
      option.map { |flags| flags % value }
    else
      []
    end
  end
end
