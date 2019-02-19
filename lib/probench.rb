require_relative '../lib/memory'
require_relative '../lib/processors'
require_relative '../lib/storage'
require_relative '../lib/network'


class Probench
  def self.probe_hardware
    puts "============== CPU =============="
    cpuprobe = SystemProcessors.probe
    puts cpuprobe.to_yaml

    puts "============= Memory ============"
    memprobe = SystemMemory.probe
    puts memprobe.to_yaml

    puts "============= Storage ============"
    storageprobe = SystemStorage.probe
    puts storageprobe.to_yaml

    puts "============= Network ============"
    netprobe = SystemNetwork.probe
    puts netprobe.to_yaml
  end
end