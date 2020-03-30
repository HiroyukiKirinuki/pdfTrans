# coding: utf-8
require "bundler/setup"
require "ruby-progressbar"
require "selenium-webdriver"

class Translator
  def initialize(args)
    raise NotImplementedError.new("#{self.class}##{__method__} is not implemented")
  end

  def translate(sentences, file)
    count = 0
    pb = ProgressBar.create(:format => '%a |%b>>%i| %p%% %t', :total => sentences.length, :length => 100)

    sentences.each do |sentence|
      pb.increment
      count += sentence.length
      @input_box.send_keys("\n")
      sentence.gsub!("'", "\\\\'")
      @driver.execute_script("arguments[0].value +='#{sentence}'", @input_box)

      if count > @props[:max_length]
        write_to_file(file)
        count = 0
      end
    end
    write_to_file(file)
    @driver.quit
  end

  private
  def write_to_file(file)
    result_texts = get_result_texts()
    source_texts = get_source_texts()
    result_texts << "\n"
    source_texts << "\n"
    if @args[:jp] && !@args[:en]
      file.puts result_texts.join("")
    else
      source_texts.zip(result_texts) do |s|
        file.puts s.join("\n")
      end
    end
    @input_box.clear
  end

  private
  def get_source_texts
    raise NotImplementedError.new("#{self.class}##{__method__} is not implemented")
  end

  private
  def get_result_texts
    raise NotImplementedError.new("#{self.class}##{__method__} is not implemented")
  end
end
