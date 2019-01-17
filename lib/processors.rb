require 'rbconfig'
require 'yaml'

# Base and factory for processor probes
class SystemProcessors
  UNLIMITED = -1

  attr_accessor :speed               # [DONE] current speed in GigaHertz
  attr_accessor :count               # [DONE] number of processors
  attr_accessor :architecture        # [DONE] enum x86_64, ARM64
  attr_accessor :core_count          # [DONE] number of total cores enabled
  attr_accessor :thread_count        # [DONE] total number of threads
  attr_accessor :l2_cache            # [DONE] L2 cache in KB
  attr_accessor :l3_cache            # [DONE] L3 cache in KB
  attr_accessor :manufacturer        # [DONE] manufacturer descriptor: i.e. GenuineIntel
  attr_accessor :model               # [DONE] model/version number
  attr_accessor :model_name          # [DONE] model/version descriptor
  attr_accessor :family              # [DONE] family number

  def self.probe
    case RbConfig::CONFIG['host_os']
    when /linux/
      LinuxSystemProcessors.new
    when /darwin/
      MacSystemProcessors.new
    when /cygwin|mswin|mingw32|mingw|bccwin|wince|emx/
      WindowsSystemProcessors.new
    else
      RbConfig::CONFIG['host_os']
    end
  end
end

# Processor probe for Linux systems
# noinspection RubyTooManyInstanceVariablesInspection
class LinuxSystemProcessors < SystemProcessors
  require_relative 'linux_wrappers.rb'

  def initialize
    proc = lscpu
    @model = proc['Model']
    @model_name = proc['Model name']
    @speed = (@model_name.split[5][0..-4].to_f * 1000).to_i
    @family = proc['CPU family']
    @architecture = proc['Architecture']
    @count = proc['Socket(s)'].to_i
    @core_count = proc['Core(s) per socket'].to_i * @count
    @thread_count = proc['Thread(s) per core'].to_i * @core_count
    @l2_cache = proc['L2 cache'][0..-2].to_i * @core_count
    @l3_cache = proc['L3 cache'][0..-2].to_i
    @manufacturer = proc['Vendor ID']
  end
end

# Processor probe for Mac systems
# noinspection RubyTooManyInstanceVariablesInspection
class MacSystemProcessors < SystemProcessors
  require_relative 'mac_wrappers.rb'

  def initialize
    # noinspection RubyResolve
    proc = sysctl(HardwareCategory::PROCESSORS)
    @model = proc['model']
    @speed = proc['cpufrequency'].to_i / 1_000_000
    @family = proc['family']
    @architecture = 'x86_64' if proc['cpu64bit_capable'] == '1'
    @count = `system_profiler SPHardwareDataType | grep Processors: | sed -e 's/ *Number of Processors: //'`.to_i
    @core_count = proc['core_count'].to_i * @count
    @thread_count = proc['thread_count'].to_i * @count
    @l2_cache = `system_profiler SPHardwareDataType | grep 'L2 Cache' | sed -e 's/ *L2 Cache (per Core): //'`
    @l2_cache = @l2_cache.to_i * @core_count
    @l3_cache = `system_profiler SPHardwareDataType | grep 'L3 Cache' | sed -e 's/ *L3 Cache: //'`.to_i * 1024
    @manufacturer = proc['vendor']
    @model_name = proc['brand_string']
  end
end

# Processor probe for Windows systems
# noinspection RubyTooManyInstanceVariablesInspection
class WindowsSystemProcessors < SystemProcessors
  require_relative 'windows_wrappers.rb'

  def initialize
    # noinspection RubyResolve
    proc = wmic HardwareCategory::PROCESSORS
    @speed = proc['CurrentClockSpeed'].to_i.round(-1)
    @model_name = proc['Name']
    description = proc['Description'].split
    @family = description[2]
    @model = description[4]
    @count = proc['count']
    @core_count = proc['NumberOfCores'] * @count
    @thread_count = proc['ThreadCount'] * @count
    @l2_cache = proc['L2CacheSize'].to_i
    @l3_cache = proc['L3CacheSize'].to_i
    @manufacturer = proc['Manufacturer']
    @architecture = 'x86_64' if proc['AddressWidth'] == '64'
  end
end
