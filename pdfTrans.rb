#! ruby -Ku
#coding: utf-8

# need amend
require "optparse"
require "./pdfReader.rb"
require "./translator.rb"

start_time = Time.now

@params = ARGV.getopts('', 'output:', 'input:', 'japanese', 'english', 'url:')
input = @params['input']
url = @params['url']
output = @params['output']
is_japanese = @params['japanese']
is_english = @params['english']

if input == nil && output == nil
  STDERR.puts "error: specify output file name"
  exit
end

sentences = PDFReader.new.read(input, url)

if output.nil?
  filename = input.split('.')[0] + "_translated.txt"
else
  filename = output
end
File.open(filename,'w'){|file| file = nil}
file = File.open(filename,"a")
if is_english && !is_japanese
  file.puts sentences.join("\n")
else
  Translator.new.translate(sentences, is_japanese, is_english, file)
end

file.close

p "処理時間 #{Time.now - start_time}s"
