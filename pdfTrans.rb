#! ruby -Ku
#coding: utf-8

# need amend
require "optparse"
require "./pdfReader.rb"
require "./translator/translator.rb"
require "./translator/mirai_translator.rb"
require "./translator/google_translator.rb"
require "./translator/deepl_translator.rb"

@params = ARGV.getopts('', 'output:', 'input:', 'jp', 'en', 'url:', 'google', 'mirai', 'head')
input = @params['input']
url = @params['url']
output = @params['output']
is_japanese = @params['jp']
is_english = @params['en']
is_google = @params['google']
is_mirai = @params['mirai']
is_head = @params['head']
args = {:jp => is_japanese, :en => is_english, :google => is_google, :mirai => is_mirai, :head => is_head}

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
  if is_google
    Google_Translator.new(args).translate(sentences, file)
  elsif is_mirai
    Mirai_Translator.new(args).translate(sentences, file)
  else
    Deepl_Translator.new(args).translate(sentences, file)
  end
end

file.close
