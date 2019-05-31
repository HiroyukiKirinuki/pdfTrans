# coding: utf-8
require "bundler/setup"
require "ruby-progressbar"
require "selenium-webdriver"

class Translator
  GOOGLE_PROPS = {
    :url => 'https://translate.google.com/?hl=ja',
    :source => [:class, 'text-dummy'],
    :input_box => [:id, 'source'],
    :result_box => [:class, 'tlid-translation'],
    :max_length => 3000
  }
  MIRAI_PROPS = {
    :url => 'https://miraitranslate.com/trial/',
    :source => [:id, 'translateSourceInput'],
    :input_box => [:id, 'translateSourceInput'],
    :result_box => [:id, 'translate-text'],
    :max_length => 1300,
    :past_result => ""
  }

  def initialize(args)
    options = Selenium::WebDriver::Chrome::Options.new
    @args = args
    if !@args[:head]
      options.add_argument('--headless')
    end
    @driver = Selenium::WebDriver.for :chrome, options: options
    @wait = Selenium::WebDriver::Wait.new(:timeout => 60)
    @props = if @args[:google]
               GOOGLE_PROPS
             else
               MIRAI_PROPS
             end

    @driver.navigate.to @props[:url]

    if !@args[:google]
      #source
      @driver.find_element(:id, 'select2-sourceButtonUrlTranslation-container').click
      @wait.until {@driver.find_elements(:class,'select2-results__option')[1].displayed?}
      @driver.find_elements(:class, 'select2-results__option')[1].click
      #target
      sleep 1
      @driver.find_element(:id, 'select2-targetButtonTextTranslation-container').click
      @wait.until {@driver.find_elements(:class,'select2-results__option')[0].displayed?}
      @driver.find_elements(:class, 'select2-results__option')[0].click
    end

    @source = @driver.find_element(*@props[:source])
    @input_box = @driver.find_element(*@props[:input_box])
  end

  def translate(sentences, file)
    count = 0
    pb = ProgressBar.create(:format => '%a |%b>>%i| %p%% %t', :total => sentences.length, :length => 100)

    sentences.each do |sentence|
      pb.increment
      count += sentence.length
      my_send_keys(sentence)
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
    if @args[:google]
      @wait.until {@driver.find_element(*@props[:result_box]).displayed?}
      result = @driver.find_element(*@props[:result_box]).text
      source_texts = @source.attribute('innerHTML').strip.split("\n")
    else
      @driver.find_element(:id, 'translateButtonTextTranslation').click
      @wait.until {@driver.find_element(*@props[:result_box]).attribute('innerText') != @props[:past_result]}
      result = @driver.find_element(*@props[:result_box]).attribute('innerText')
      @props[:past_result] = result
      source_texts = @source['value'].strip.split("\n")
    end
    result_texts = result.strip.split("\n").map {|s| s + "\n"}
    source_texts << "\n"
    result_texts << "\n"
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
  def my_send_keys(sentence) # avoid error of sendkeys
    chunks = sentence.scan(/.{1,80}/)
    chunks.each do |c|
      @input_box.send_keys(c)
    end
    @input_box.send_keys("\n")
  end
end
