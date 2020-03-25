# coding: utf-8
class Deepl_Translator < Translator

  def initialize(args)
    @props = {
      :url => 'https://www.deepl.com/translator',
      :source => [:xpath, '//*[@id="dl_translator"]/div[1]/div[3]/div[2]/div/textarea'],
      :input_box => [:xpath, '//*[@id="dl_translator"]/div[1]/div[3]/div[2]/div/textarea'],
      :result_box => [:xpath, '//*[@id="dl_translator"]/div[1]/div[4]/div[3]/div[1]/textarea'],
      :max_length => 3000
    }
    options = Selenium::WebDriver::Chrome::Options.new
    @args = args
    if !@args[:head]
      options.add_argument('--headless')
      options.add_argument("--lang=ja");
    end
    @driver = Selenium::WebDriver.for :chrome, options: options
    @wait = Selenium::WebDriver::Wait.new(:timeout => 180)
    @driver.navigate.to @props[:url]

    @source = @driver.find_element(*@props[:source])
    @input_box = @driver.find_element(*@props[:input_box])
  end

  private
  def get_source_texts
    return @source['value'].strip.split("\n")
  end

  private
  def get_result_texts
    sleep 15
    @wait.until {!@driver.find_element(:xpath, '//*[@id="dl_translator"]/div[5]/div').attribute('innerText').include?('翻訳済み')}
    result = @driver.find_element(*@props[:result_box]).attribute('value')
    if result.include?('[...]')
      sleep 10
    end
    return result.strip.split("\n")
  end
end
