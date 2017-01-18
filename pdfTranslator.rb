#! ruby -Ku
#coding: utf-8

require "poppler"
require "selenium-webdriver"

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
  driver = Selenium::WebDriver.for :chrome
  driver.navigate.to 'https://translate.google.com/?hl=ja'
  return driver
end

def my_send_keys(source,sentence) #sendkeysのエラー回避
  chunks = sentence.scan(/.{1,50}/)
  chunks.each do |c|
    source.send_keys(c)
  end
end

def translate(sentences,driver)
  source = driver.find_element(:id,'source')
  result_box = driver.find_element(:id,'result_box')
  gt_submit = driver.find_element(:id,'gt-submit')
  driver.find_element(:id, 'gt-otf-switch').click #リアルタイム翻訳しない

  prev = ""
  result = ""
  count = 0
  sentences.each do |sentence|
    count+=1
    my_send_keys(source,sentence)
    source.send_keys("\n")
    if count > 10 then
      gt_submit.click
      sleep 3
      jp_s = source.attribute("value").strip.split("\n")
      en_s = result_box.text.strip.split("\n")
      en_s.zip(jp_s) do |s|
        puts s.join("\n")
      end
      prev = result_box.text
      source.clear
      count = 0
     # break # 仮
    end
  end
  driver.quit
  return result
end

eng = read_pdf
driver = init_driver
result = translate(eng,driver)
write_file(result)
