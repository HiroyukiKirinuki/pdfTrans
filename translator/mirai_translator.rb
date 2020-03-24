require "selenium-webdriver"

class Mirai_Translator < Translator

  def initialize(args)
    @props = {
      :url => 'https://miraitranslate.com/trial/',
      :source => [:id, 'translateSourceInput'],
      :input_box => [:id, 'translateSourceInput'],
      :result_box => [:id, 'translate-text'],
      :max_length => 1300,
      :past_result => ""
    }
    options = Selenium::WebDriver::Chrome::Options.new
    @args = args
    if !@args[:head]
      options.add_argument('--headless')
    end
    @driver = Selenium::WebDriver.for :chrome, options: options
    @wait = Selenium::WebDriver::Wait.new(:timeout => 180)
    @driver.navigate.to @props[:url]

    #source
    @driver.find_element(:id, 'select2-sourceButtonUrlTranslation-container').click
    @wait.until {@driver.find_elements(:class,'select2-results__option')[1].displayed?}
    @driver.find_elements(:class, 'select2-results__option')[1].click
    #target
    sleep 1
    @driver.find_element(:id, 'select2-targetButtonTextTranslation-container').click
    @wait.until {@driver.find_elements(:class,'select2-results__option')[0].displayed?}
    @driver.find_elements(:class, 'select2-results__option')[0].click

    @source = @driver.find_element(*@props[:source])
    @input_box = @driver.find_element(*@props[:input_box])
  end

  private
  def get_source_texts
    return @source['value'].strip.split("\n")
  end

  private
  def get_result_texts
    @driver.find_element(:id, 'translateButtonTextTranslation').click
    sleep 3
    @wait.until {@driver.find_element(*@props[:result_box]).attribute('innerText') != @props[:past_result]}
    result = @driver.find_element(*@props[:result_box]).attribute('innerText')
    @props[:past_result] = result
    return result.strip.split("\n")
  end
end
