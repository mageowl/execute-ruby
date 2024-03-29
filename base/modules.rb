load "color.rb"

module ER_Parser
    def self.parseline(text)
        if text == "\n"
            return true
        end

        words = text.split(" ")

        chunk = self.formatWord words[0]
        case (chunk[:type])
            when "keyword"
                if ER_Program_Varibles.functionname != "none" && words[0] != "end" then
                    if (!ER_Program_Varibles::VARIBLES[ER_Program_Varibles.functionname])
                        ER_Program_Varibles.setVar(ER_Program_Varibles.functionname, "")
                    end
                    ER_Program_Varibles.setVar(ER_Program_Varibles.functionname, ER_Program_Varibles::VARIBLES[ER_Program_Varibles.functionname] + words.join(" ") + "#n")
                    return true
                end
                returnEvent = ER_Keyword_Compiler.compile words
                if returnEvent
                    outsideEvent = ER_Keyword_Compiler.handleReturnEvent returnEvent
                    if outsideEvent == "stopAll"
                        return false
                    end
                end
            else
                raise "First word in a line must be a keyword.".pink
        end

        return true
    end

    def self.formatWord(word) 
        if ER_Word_Type::KEYWORDS.include? word then
            return {type: "keyword", value: word}
        elsif ER_Word_Type::OPERATORS.include? word then
            return {type: "operator", value: word}
        elsif ER_Word_Type::VALUES[word] != nil then
            return {type: "value", value: ER_Word_Type::VALUES[word]}
        else
            return {type: "string", value: word}
        end
    end
end

module ER_Word_Type
    KEYWORDS = ["write", "writeColor", "kill", "set", "if", "#", "while", "function", "end", "run", "change"]
    OPERATORS = ["get", "color", "input", "add"]
    VALUES = {false: false, true: true, none: nil}
end

module ER_Keyword_Compiler
    def self.compile(words)
        keywordChunk = ER_Parser.formatWord words[0]
        case (keywordChunk[:value])
            when "write"
                puts self.handleOperator(words[1..words.length].join(" "))
            when "writeColor"
                case (words[1])
                    when "red"
                        puts self.handleOperator(words[2..words.length].join(" ")).red
                    when "blue"
                        puts self.handleOperator(words[2..words.length].join(" ")).blue
                    when "green"
                        puts self.handleOperator(words[2..words.length].join(" ")).green
                    when "yellow"
                        puts self.handleOperator(words[2..words.length].join(" ")).yellow
                    when "lightblue"
                        puts self.handleOperator(words[2..words.length].join(" ")).light_blue
                    else
                        raise "#{words[1]} is not a supported color".pink
                end
            when "kill"
                return "kill"
            when "set"
                ER_Program_Varibles.setVar(words[1], self.handleOperator(words[3..words.length].join(" ")))
            when "if"
                if self.handleCondition(words[1..3])
                    self.compile(words[5..words.length])
                end
            when "while"
                while true
                    self.compile(words[5..words.length])
                    if (!self.handleCondition(words[1..3]))
                        break
                    end
                end
            when "end"
                ER_Program_Varibles.setFunction("none")
            when "function"
                if ER_Parser.formatWord(words[1])[:type] != "string" then
                    raise "#{words[1]} is not a string, therfor cannont be used as a function name.".pink
                end
                ER_Program_Varibles.setFunction words[1]
            when "run"
                ER_Program_Varibles::VARIBLES[words[1]].split("#n").each do |line|
                    ER_Parser.parseline(line)
                end
            when "change"
                ER_Program_Varibles.setVar(words[1], ER_Program_Varibles::VARIBLES[words[1]].to_i + words[3].to_i)
        end
        false
    end

    def self.handleReturnEvent(event)
        case event
            when "kill"
                return "stopAll"
        end
    end

    def self.handleOperator(word)
        words = word.split(":")

        indexOfOperator = 0
        words.each_with_index do |w, index|
            c = ER_Parser.formatWord w
            if c[:type] == "operator"
                indexOfOperator = index
            end
        end

        chunk = ER_Parser.formatWord words[indexOfOperator]
        aguments = words[indexOfOperator..-1]
        if indexOfOperator - 1 == -1
            before = []
        else
            before = words[0..indexOfOperator - 1]
        end

        if chunk[:type] == "operator"
            case chunk[:value]
                when "get"
                    return ((before.push ER_Program_Varibles::VARIBLES[aguments[1]]).push aguments[2..-1]).join()
                when "color"
                    case aguments[2]
                        when "red"
                            return ((words[0..indexOfOperator - 1].push aguments[1].red).push aguments[3..-1]).join()
                        when "blue"
                            return ((words[0..indexOfOperator - 1].push aguments[1].blue).push aguments[3..-1]).join() 
                        when "green"
                            return ((words[0..indexOfOperator - 1].push aguments[1].green).push aguments[3..-1]).join()
                        when "yellow"
                            return ((words[0..indexOfOperator - 1].push aguments[1].yellow).push aguments[3..-1]).join()
                        when "lightblue"
                            return ((words[0..indexOfOperator - 1].push aguments[1].light_blue).push aguments[3 ..-1]).join()
                        else
                            raise "#{words[1]} is not a supported color".pink
                    end
                when "input"
                    return ((before.push gets.chomp).push aguments[1..-1]).join()
            end
        else
            return word
        end
    end

    def self.handleCondition(words)
        type = words[1]
        case type
            when "="
                return self.handleOperator(words[0]) == self.handleOperator(words[2])
            when ">"
                if self.handleOperator(words[0]).is_i? && self.handleOperator(words[2]).is_i? then
                    return self.handleOperator(words[0]).to_i > self.handleOperator(words[2]).to_i
                else
                    raise "The '>' condition must be used on two numbers. One or two inputs are not a integer.".pink
                end
            when "<"
                if self.handleOperator(words[0]).is_i? && self.handleOperator(words[2]).is_i? then
                    return self.handleOperator(words[0]).to_i < self.handleOperator(words[2]).to_i
                else
                    raise "The '<' condition must be used on two numbers. One or two inputs are not a integer.".pink
                end
        end
    end
end

module ER_Program_Varibles

    VARIBLES = {}
    @@functionname = "none"

    def self.setFunction(value)
        @@functionname = value
    end

    def self.setVar(id, value)
        VARIBLES[id] = value
    end

    def self.functionname
        @@functionname
    end

    def self.deleteVar(id)
        VARIBLES[id] = nil
    end
end
    