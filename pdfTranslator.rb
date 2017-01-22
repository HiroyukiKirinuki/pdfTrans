#! ruby -Ku
#coding: utf-8

require "poppler"
require "selenium-webdriver"
require "ruby-progressbar"

def read_pdf
  document = Poppler::Document.new(ARGV[0])
  str = ""
  document.each do |page|
    str << page.get_text.gsub("\n"," ")
  end
  sentences = str.split(/((?<=[a-z0-9)][.?!])|(?<=[a-z0-9][.?!]"))\s+(?="?[A-Z])/)
  return sentences
end

def init_driver
  driver = Selenium::WebDriver.for :phantomjs
  driver.navigate.to 'https://translate.google.com/?hl=ja'
  return driver
end

def my_send_keys(source,sentence) #sendkeysのエラー回避
  chunks = sentence.scan(/.{1,80}/)
  chunks.each do |c|
    source.send_keys(c)
  end
end

def translate(sentences,driver)
  source = driver.find_element(:id,'source')
  result_box = driver.find_element(:id,'result_box')
  gt_submit = driver.find_element(:id,'gt-submit')
  driver.find_element(:id, 'gt-otf-switch').click #リアルタイム翻訳しない

  pb = ProgressBar.create(:total => sentences.length, :length => 100)
  result = ""
  count = 0
  progress = 0
  sentences.each do |sentence|
    pb.increment
    count += sentence.length
    my_send_keys(source,sentence)
    source.send_keys("\n")
    if count > 4000 then
      gt_submit.click
      sleep 3
      jp_s = source.attribute("value").strip.split("\n")
      en_s = result_box.text.strip.split("\n")
      jp_s.zip(en_s) do |s|
        result << s.join("\n")
        result << "\n"
      end
      source.clear
      count = 0
      # break # 仮
    end
  end
  driver.quit
  return result
end

def write_file(result)
  File.open(ARGV[1],"w") do |f|
    f.puts(result)
  end
end

eng = read_pdf
driver = init_driver
result = translate(eng,driver)
write_file(result)
