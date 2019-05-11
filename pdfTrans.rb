#! ruby -Ku
#coding: utf-8

# need amend
require "optparse"
require "./pdfReader.rb"
require "./translator.rb"

@params = ARGV.getopts('', 'output:', 'input:', 'jp', 'en', 'url:', 'google', 'head')
input = @params['input']
url = @params['url']
output = @params['output']
is_japanese = @params['jp']
is_english = @params['en']
is_google = @params['google']
is_head = @params['head']
args = {:jp => is_japanese, :en => is_english, :google => is_google, :head => is_head}

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
  Translator.new(args).translate(sentences, file)
end

file.close
