# coding: utf-8
require "bundler/setup"
require "ruby-progressbar"
require "selenium-webdriver"

class Translator
  MAX_LENGTH = 3000

  def initialize
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    @driver = Selenium::WebDriver.for :chrome, options: options
    @driver.navigate.to 'https://translate.google.com/?hl=ja'
    @source = @driver.find_element(:class,'text-dummy')
    @input_box = @driver.find_element(:id, 'source')
    @result_box = @driver.find_element(:class,'tlid-results-container')
    @wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  end

  def translate(sentences, is_japanese, is_english, file)
    count = 0
    pb = ProgressBar.create(:total => sentences.length, :length => 100)

    sentences.each do |sentence|
      pb.increment
      count += sentence.length
      my_send_keys(sentence)
      if count > MAX_LENGTH
        write_to_file(file, is_japanese, is_english)
        count = 0
      end
    end
    write_to_file(file, is_japanese, is_english)
    @driver.quit
  end

  private
  def write_to_file(file, is_japanese, is_english)
    @wait.until {@driver.find_element(:class, 'tlid-translation').displayed?}
    result = @driver.find_element(:class,'tlid-translation').text
    en_s = @source.attribute('innerHTML').strip.split("\n")
    jp_s = result.strip.split("\n").map {|s| s + "\n"}
    if is_japanese && !is_english
      file.puts jp_s.join("")
    else
      en_s.zip(jp_s) do |s|
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
