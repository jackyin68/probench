require 'rbconfig'
require 'yaml'
require 'highline/import'

# Base and factory for memory probes
class SystemStorage
  UNLIMITED = -1

  attr_accessor :model               # int in MegaHertz
  attr_accessor :size                # int in GigaBytes
  attr_accessor :type                # string DDR type
  attr_accessor :physical_block_size # size of the swap if any in GigaBytes
  attr_accessor :logical_block_size  #

  def self.probe
    case RbConfig::CONFIG['host_os']
    when /linux/
      LinuxSystemStorage.new
    when /darwin/
      MacSystemStorage.new
    when /cygwin|mswin|mingw32|mingw|bccwin|wince|emx/
      WindowsSystemStorage.new
    else
      RbConfig::CONFIG['host_os']
    end
  end
end

# Memory probe for Linux
class LinuxSystemStorage < SystemStorage
  def initialize
    if `which lsscsi | wc -l | tr -d '[:space:]'` == '0'
      input = ask 'lsscsi is not installed, would you like to install it (y/n)?'
      if input == 'y'
        puts `sudo apt-get install -y lsscsi`
      else
        puts 'Cannot proceed without lsscsi executable, aborting.'
        exit 1
      end
    end

    cmd = "sudo lshw -class disk -class storage | awk '/product:/{name=$2} /size: /{size=$2; print name}'"
    @model = `#{cmd}`

    cmd = "sudo lshw -class disk -class storage | awk '/product:/{name=$2} /size: /{size=$2; print size}'"
    @size = `#{cmd}`

  end
end

# Memory probe for Mac OS
class MacSystemStorage < SystemStorage
  def initialize
    puts 'Implement me'
  end
end

# Memory probe for Windows
class WindowsSystemStorage < SystemStorage
  def initialize
    puts 'Implement me'
  end
end

