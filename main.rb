class Game
    attr_reader :secret_word, :output, :guesses_left, :used_letters
    @@dictionary = File.readlines "5desk.txt" 
    @@commands = ['save','load'] 
    ("a".."z").each do |letter|
      @@commands << letter
    end

    def play
      puts''
      puts "New game has been started!\r"
      
      pick_a_word
      @guesses_left = @secret_word.length + 1
      @used_letters=[]

      @output=[]
      until @output.length == @secret_word.length do 
        @output << "_ "
      end
      puts @output.join("")
      puts "Wrong guesses left: #{@guesses_left}"
      puts "Used letters are: #{@used_letters.join(',')}"

      until @guesses_left == 0 || @secret_word == @output
        puts "Guess a letter"
        turn(to_command)
      end

      puts @secret_word == @output ? "You've won!" : "You've lost!\rThe word was '#{@secret_word.join('')}'"

      puts "\rWanna play again?"
      play_again = gets.chomp.downcase
      play_again_answers_y = ['y','yes']
      play_again_answers_n = ['n','no']

      until play_again_answers_y.include?(play_again) || play_again_answers_n.include?(play_again) || play_again == "load"
        puts "Invalid choise. Please enter 'yes' or 'no'."
        play_again = gets.chomp.downcase
      end
      Game.new.play if play_again_answers_y.include?(play_again)
    end

    private 
    def pick_a_word
      @@dictionary.each do |l|
        until (l.slice! "\n") == nil && (l.slice! "\r") == nil
        end 
      end
      @@dictionary.delete_if { |i| i.length <=5 || i.length >=12 } 
      @secret_word = @@dictionary.sample.split('')
    end

    def turn(command)
      if command.length == 1
        is_right = false
        @secret_word.each_with_index do |letter, index|
          if @secret_word[index] == command
            @output[index] = @secret_word[index] 
            is_right = true 
          end
        end
        @guesses_left -= 1 unless is_right || @used_letters.include?(command)
        @used_letters << command unless @used_letters.include?(command)
        
      end
      if command == "save"
        save
      end
      if command == "load"
        load
      end
      puts ""
      puts @output.join("")
      puts "Wrong guesses left: #{@guesses_left}"
      puts "Used letters are: #{@used_letters.join(',')}"
    end

    def save
      Dir.mkdir('saves') unless Dir.exists? 'saves'
      save_name = Dir.entries('saves').length - 1
      File.open("saves/#{save_name.to_s}", 'w+') do |f|  
        Marshal.dump(self, f)  
      end 
      puts"\rCurrent session has been saved"
    end

    def load
      puts ''
      puts "Avalible saves\r"
      saves = Dir.new('saves')
      saves.each do |filename|
        unless filename == '.' || filename == '..' 
          file = File.new("saves/#{filename}",'r')
          file = Marshal.load(file)
          puts "(#{filename})|#{file.output.join('')}| guesses left: #{file.guesses_left}"
        end
      end
      puts ''
      puts "Pick the save file by its number. You can continue current game by 'continue'or 'c' command "
      file_to_load ="saves/" + gets.chomp
      return if file_to_load == "saves/continue" || file_to_load == "saves/c"
      until File.exists?(file_to_load)
        puts "There is no such save file. Pick another file."
        file_to_load = "saves/" + gets.chomp
      end
      renew(file_to_load)
      
    end

    def renew(load_file)
      file_to_load = File.new(load_file,'r')
      file_to_load = Marshal.load(file_to_load)
      
      @secret_word = file_to_load.secret_word
      @output = file_to_load.output
      @guesses_left = file_to_load.guesses_left
      @used_letters = file_to_load.used_letters
      

      puts "\nThe file has been successfully loaded!\r"
    end


    def to_command
      command = gets.chomp.downcase
      until @@commands.include?(command) do
        puts "Invalid command!"
        puts "Write a letter, 'save' or 'load'"
        command = gets.chomp.downcase
      end
      command
    end
end

a=Game.new
a.play
