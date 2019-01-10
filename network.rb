require 'rbconfig'
require 'yaml'
require 'highline/import'

# Base and factory for processor probes
class SystemNetwork
  UNLIMITED = -1

  attr_accessor :upload_speed        # upload speed in Mbps
  attr_accessor :download_speed      # download speed in Mbps
  attr_accessor :default_gateway     # the default gateway
  attr_accessor :default_device      # the default gateway device used
  attr_accessor :dev_id
  attr_accessor :dev_type
  attr_accessor :dev_link_speed      # device link speed in Mbps

  def self.probe
    case RbConfig::CONFIG['host_os']
    when /linux/
      LinuxSystemNetwork.new
    when /darwin/
      MacSystemNetwork.new
    when /cygwin|mswin|mingw32|mingw|bccwin|wince|emx/
      WindowsSystemNetwork.new
    else
      RbConfig::CONFIG['host_os']
    end
  end
end

# Processor probe for Linux systems
class LinuxSystemNetwork < SystemNetwork
  lshw_xml = ``
  def initialize
    puts 'Implement me'
  end
end

# Processor probe for Mac systems
class MacSystemNetwork < SystemNetwork
  def initialize
    puts 'Implement me'
  end
end

# Processor probe for Windows systems
class WindowsSystemNetwork < SystemNetwork
  def initialize
    puts 'Implement me'
  end
end

netprobe = SystemNetwork.probe
puts netprobe.to_yaml
