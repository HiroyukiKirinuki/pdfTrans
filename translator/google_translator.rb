class Google_Translator < Translator

  def initialize(args)
    @props = {
      :url => 'https://translate.google.com/?hl=ja',
      :source => [:class, 'text-dummy'],
      :input_box => [:id, 'source'],
      :result_box => [:class, 'tlid-translation'],
      :max_length => 3000
    }
    options = Selenium::WebDriver::Chrome::Options.new
    @args = args
    if !@args[:head]
      options.add_argument('--headless')
    end
    @driver = Selenium::WebDriver.for :chrome, options: options
    @wait = Selenium::WebDriver::Wait.new(:timeout => 180)
    @driver.navigate.to @props[:url]
    @source = @driver.find_element(*@props[:source])
    @input_box = @driver.find_element(*@props[:input_box])
  end

  private
  def get_source_texts
    @wait.until {@driver.find_element(*@props[:result_box]).displayed?}
    return @source.attribute('innerHTML').strip.split("\n")
  end

  private
  def get_result_texts
    @wait.until {@driver.find_element(*@props[:result_box]).displayed?}
    return @driver.find_element(*@props[:result_box]).text.strip.split("\n")
  end
end
