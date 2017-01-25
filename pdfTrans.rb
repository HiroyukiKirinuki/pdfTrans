#! ruby -Ku
#coding: utf-8

# need amend
require "optparse"
require "./pdfReader.rb"
require "./fileWriter.rb"
require "./translator.rb"

@params = ARGV.getopts('', 'output:', 'input:', 'japanese', 'english', 'url:')
input = @params['input']
url = @params['url']
output = @params['output']
is_japanese = @params['japanese']
is_english = @params['english']

sentences = PDFReader.new.read(input, url)
result = if is_english && !is_japanese
           sentences.join("\n")
         else
           Translator.new.translate(sentences, is_japanese, is_english)
         end
FileWriter.new.write(result, input, output)
