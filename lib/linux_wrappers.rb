require_relative 'common.rb'

# converts lscpu output into hash
def lscpu
  hash = {}
  IO.popen('lscpu') do |io|
    while (line = io.gets)
      key = line.split(':')[0]
      key = key.strip unless key.nil?
      val = line.split(':')[1]
      val = val.strip unless val.nil?
      hash[key] = val unless key.nil? || val.nil?
    end
  end
  hash
end

# converts /proc/cpuinfo into a hash
def cpuinfo
  hash = {}
  IO.popen('cat /proc/cpuinfo') do |io|
    while (line = io.gets)
      key = line.split(':')[0]
      key = key.strip unless key.nil?
      val = line.split(':')[1]
      val = val.strip unless val.nil?
      hash[key] = val unless key.nil? || val.nil?
    end
  end
  hash
end
