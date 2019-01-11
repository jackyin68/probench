require_relative '../lib/memory'

class Probench
  def self.cli
    puts 'Probench welcome!'
    SystemMemory.probe
  end
end