require_relative 'common.rb'

def wmic(category)
  raise ArgumentError unless category.is_a?(HardwareCategory)

  cmd = 'wmic '
  # noinspection RubyResolve
  case category
  when HardwareCategory::PROCESSORS
    cmd += 'cpu'
  when HardwareCategory::MEMORY
    cmd += 'memory'
  else
    raise ArgumentError 'Bad category'
  end

  lines = []
  IO.popen(cmd) do |io|
    while (line = io.gets)
      lines << line
    end
  end

  keys_str = lines[0]
  vals_str = lines[2]

  hash = {}
  index = -1
  key = nil
  val = nil
  while index < keys_str.size - 1
    index += 1
    lookahead = index < keys_str.size - 2 ? keys_str[index + 1] : nil

    # transiting to inside when space turns into nonspace
    if keys_str[index] == ' ' && lookahead != ' '
      # noinspection RubyNilAnalysis
      key = key.strip
      # noinspection RubyNilAnalysis
      val = val.strip
      hash[key] = val unless val.nil? || val.size.zero?
      key = nil
      val = nil
    elsif key.nil? && val.nil?
      key = keys_str[index]
      val = vals_str[index]
    elsif !key.nil? && !val.nil?
      key << keys_str[index]
      val << vals_str[index]
    end
  end

  # presuming multiple processors add extra lines
  hash['count'] = lines.size - 5
  hash
end
