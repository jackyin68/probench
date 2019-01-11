require 'rbconfig'
require 'yaml'
require 'highline/import'

# Base and factory for memory probes
class SystemMemory
  UNLIMITED = -1

  attr_accessor :speed               # int in MegaHertz
  attr_accessor :size                # int in GigaBytes
  attr_accessor :type                # string DDR type
  attr_accessor :is_ecc              # boolean true if ECC memory and enabled
  attr_accessor :swap_size           # size of the swap if any in GigaBytes

  def self.probe
    case RbConfig::CONFIG['host_os']
    when /linux/
      LinuxSystemMemory.new
    when /darwin/
      MacSystemMemory.new
    when /cygwin|mswin|mingw32|mingw|bccwin|wince|emx/
      WindowsSystemMemory.new
    else
      RbConfig::CONFIG['host_os']
    end
  end
end

# Memory probe for Linux
class LinuxSystemMemory < SystemMemory
  def initialize
    if `which lshw | wc -l | tr -d '[:space:]'` == '0'
      input = ask 'lshw is not installed, would you like to install it (y/n)?'
      if input == 'y'
        puts `sudo apt-get install -y lshw`
      else
        puts 'Cannot proceed without lshw executable, aborting.'
        exit 1
      end
    end

    cmd = "sudo lshw -c memory -short | grep 'System Memory' | " \
          "sed -e 's/.*memory *//' -e 's/GiB//' | awk '{print $1}'"
    @size = `#{cmd}`.to_i

    cmd = 'sudo lshw -c memory -short | grep MHz | '  \
          "sed -e 's/.*memory *//' -e 's/(//' | uniq | cut -f3,5 -d' '"
    @type, @speed, = `#{cmd}`.split ' ', 3
    @speed = @speed.to_i

    cmd = "grep SwapTotal /proc/meminfo | awk '{print $2}'"
    @swap_size = `#{cmd}`.to_i
    @swap_size /= 1_048_576

    cmd = "sudo dmidecode -t memory | grep '[Data|Total] Width' | " \
          "sort |  uniq | cut -d' ' -f 3 | uniq | wc -l"
    @is_ecc = `#{cmd}`.to_i != 1
  end
end

# Memory probe for Mac OS
class MacSystemMemory < SystemMemory
  def initialize
    `system_profiler SPMemoryDataType > /tmp/memdata.tmp`
    cmd = 'grep ECC /tmp/memdata.tmp | sed -e \'s/.*ECC: //\' | tr -d \'[:space:]\''
    @is_ecc = `#{cmd}` != 'Disabled'

    cmd = "grep Type /tmp/memdata.tmp | uniq | sed -e 's/.*Type: //' | tr -d '[:space:]'"
    @type = `#{cmd}`

    cmd = "grep Speed /tmp/memdata.tmp | uniq | sed -e 's/.*Speed: //' | cut -f1 -d' '"
    @speed = `#{cmd}`.to_i

    cmd = "grep Size /tmp/memdata.tmp | uniq | sed -e 's/.*Size: //' | cut -f1 -d' '"
    slot_size = `#{cmd}`.to_i
    cmd = "grep Size /tmp/memdata.tmp | wc -l | tr -d '[:space:]'"
    slots = `#{cmd}`.to_i

    @size = slots * slot_size
    @swap_size = UNLIMITED
  end
end

# Memory probe for Windows
class WindowsSystemMemory < SystemMemory
  # rubocop:disable Style/ClassVars
  # noinspection RubyClassVariableUsageInspection
  @@mem_type = ['Unknown', 'Other', 'DRAM', 'Synchronous DRAM',
                'Cache DRAM', 'EDO', 'EDRAM', 'VRAM', 'SRAM', 'RAM',
                'ROM', 'Flash', 'EEPROM', 'FEPROM', 'EPROM', 'CDRAM',
                '3DRAM', 'SDRAM', 'SGRAM', 'RDRAM', 'DDR', 'DDR2',
                'DDR2 FB-DIMM', 'Undefined', 'DDR3', 'FBD2']
  # rubocop:enable Style/ClassVars

  def initialize
    count = 0
    data_width = 0
    total_width = 0
    IO.popen('wmic MEMORYCHIP get Capacity,Speed,MemoryType,TotalWidth,DataWidth') do |io|
      while (line = io.gets)
        line = line.gsub(/\s+/m, ' ')
        values = line.split(' ')
        next if line.start_with?('Capacity') || values.empty?

        @size = values[0].to_i / 1_048_576
        data_width = values[1].to_i

        # noinspection RubyClassVariableUsageInspection
        @type = @@mem_type[values[2].to_i]
        @speed = values[3].to_i
        total_width = values[4].to_i
        count += 1
      end
    end

    @size = @size * count / 1024
    cmd = `systeminfo | find "Virtual Memory: Max Size:"`
    cmd = cmd.gsub(/\s+/m, ' ')
    @swap_size = cmd.split(' ')[4].to_i
    @is_ecc = data_width != total_width
  end
end

memprobe = SystemMemory.probe
puts memprobe.to_yaml
