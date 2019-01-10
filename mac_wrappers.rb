require_relative 'common.rb'

# convert output of sysctl to a hash
# noprefix to false to not remove key prefixes i.e. machdep.cpu etc
def sysctl(category, noprefix = true)
  raise ArgumentError unless category.is_a?(HardwareCategory)

  cmd = 'sysctl -a'
  prefixes = []
  # noinspection RubyResolve
  case category
  when HardwareCategory::PROCESSORS
    cmd += " | egrep '(hw|cpu)'"
    prefixes = %w[machdep.cpu. hw.]
  when HardwareCategory::MEMORY
    cmd += ' | grep machdep.mem'
    prefixes = ['machdep.mem.']
  else
    puts 'none of the above'
  end

  hash = {}
  IO.popen(cmd) do |io|
    while (line = io.gets)
      key = line.split(':')[0]
      key = key.strip unless key.nil?
      next if key.nil?

      if noprefix && !key.nil?
        prefixes.each do |prefix|
          # noinspection RubyNilAnalysis
          key = key[prefix.length..-1] if key.start_with?(prefix) && noprefix
        end
      end

      val = line.split(':')[1]
      val = val.strip unless val.nil?
      hash[key] = val unless key.nil? || val.nil?
    end
  end
  hash
end
