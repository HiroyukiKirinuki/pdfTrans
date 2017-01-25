require "poppler"
require "open-uri"

class PDFReader
  def read(input, url)
    if input != nil
      document = Poppler::Document.new(input)
    elsif url != nil
      document = read_from_url(url)
    else
      STDERR.puts "error: specify input file or url"
      exit
    end
    str = ""
    document.each do |page|
      str << page.get_text.gsub("\n"," ")
    end
    sentences = str.split(/((?<=[a-z0-9)][.?!])|(?<=[a-z0-9][.?!]"))\s+(?="?[A-Z])/)
    return sentences
  end

  private
  def read_from_url(url)
    fileName = File.basename(url)
    open(fileName, 'wb') do |output|
      open(url) do |data|
        output.write(data.read)
      end
    end
    document = Poppler::Document.new(fileName)
    File.delete(fileName)
    return document
  end
end
