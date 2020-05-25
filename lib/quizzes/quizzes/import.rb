class Quizzes::Import
  def self.process(file_or_text, options = {})
    converter = case options[:format]
    when :dkt
      Quizzes::Converter::Dkt.new
    when nil
      raise "No format specified. "
    else
      raise "No converter specified for #{options[:format]} format. "
    end
    source = file_or_text.respond_to?(:read) ? file_or_text.read : file_or_text
    converter.convert(source)
  end
end
