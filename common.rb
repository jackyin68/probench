require 'typesafe_enum'

class HardwareCategory < TypesafeEnum::Base

  new :MEMORY
  new :NETWORK
  new :PROCESSORS
  new :STORAGE
end
