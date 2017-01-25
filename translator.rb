# coding: utf-8
require "ruby-progressbar"
require "selenium-webdriver"

class Translator
  MAX_LENGTH = 4000

  def initialize
    @driver = Selenium::WebDriver.for :phantomjs
    @driver.navigate.to 'https://translate.google.com/?hl=ja'
    @source = @driver.find_element(:id,'source')
    @result_box = @driver.find_element(:id,'result_box')
    @gt_submit = @driver.find_element(:id,'gt-submit')
    @driver.find_element(:id, 'gt-otf-switch').click #off real time translate
  end

  def translate(sentences, is_japanese, is_english)
    result = ""
    count = 0
    pb = ProgressBar.create(:total => sentences.length, :length => 100)

    sentences.each do |sentence|
      pb.increment
      count += sentence.length
      my_send_keys(sentence)
      @source.send_keys("\n")
      if count > MAX_LENGTH
        @gt_submit.click
        sleep 3
        en_s = @source.attribute("value").strip.split("\n")
        jp_s = @result_box.text.strip.split("\n").map {|s| s + "\n"}
        if is_japanese && !is_english
          result << jp_s.join("\n")
        else
          en_s.zip(jp_s) do |s|
            result << s.join("\n")
          end
        end
        @source.clear
        count = 0
      end
    end
    @driver.quit
    return result
  end

  private
  def my_send_keys(sentence) # avoid error of sendkeys
    chunks = sentence.scan(/.{1,80}/)
    chunks.each do |c|
      @source.send_keys(c)
    end
  end
end
