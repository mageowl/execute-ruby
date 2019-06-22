load "modules.rb"

print "File name: "
fileName = gets.chomp

def runFile fileName
    puts "RUNNING...".pink
    puts ""
    fileContents = File.open("../scripts/#{fileName}.exr").read
    fileContents.each_line do |line|
        shouldKill = ER_Parser.parseline(line)
        if !shouldKill
            return
        end
    end
end

runFile fileName