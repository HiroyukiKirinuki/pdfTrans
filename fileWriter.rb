class FileWriter
  def write(result, input, output)
    if output.nil?
      filename = input.split('.')[0] + "_translated.txt"
    else
      filename = output
    end
    File.open(filename,"w") do |f|
      f.puts(result)
    end
  end
end
