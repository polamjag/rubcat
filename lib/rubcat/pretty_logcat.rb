require 'io/console'

module Rubcat
  class PrettyLogcat
    attr_reader :opt, :last_tag
    LOG_LEVELS = [:V, :D, :I, :W, :E, :F]

    def initialize(options)
      @opt = {
        min_level: :V,
        tag_length: 25,
        split_tags: false
      }.merge options
    end

    def parse_message(message)
      m = message.match(/^([VDIWEFS])\/(.*)\((\s*[0-9]+)\):\s(.*)$/)
      {
        type: m[1].to_sym,
        tag: m[2].strip,
        pid: m[3],
        message: m[4]
      }
    end

    def colorize_type(type)
      case type
      when :V
        " #{type} ".bold.bg_gray.black
      when :D
        " #{type} ".bold.bg_blue
      when :I
        " #{type} ".bold.bg_green
      when :W
        " #{type} ".bold.bg_brown
      else
        " #{type} ".bold.bg_red
      end
    end

    KNOWN_TAGS = %w{dalvikvm art dex2oat}

    def format_tag(type, tag)
      if type == :normal
        unless tag == @last_tag
          @last_tag = tag
          puts if @opt[:split_tags]
          if KNOWN_TAGS.include? tag
            tag.trim_and_rjust(@opt[:tag_length]).bold.black.bg_gray
          elsif tag == "ActivityManager"
            tag.trim_and_rjust(@opt[:tag_length]).bold
          else
            tag.trim_and_rjust(@opt[:tag_length]).randomize_color.bold
          end
        else
          " " * @opt[:tag_length]
        end
      elsif type == :activity_kill
        tag.trim_and_rjust(@opt[:tag_length]).bold.bg_red
      elsif type == :activity_start
        tag.trim_and_rjust(@opt[:tag_length]).bold.bg_green
      end
    end


    def wrap_message(mes, type)
      mes.scan(/.{1,#{IO.console.winsize[1] - @opt[:tag_length] - 5}}/).join("\n#{' ' * @opt[:tag_length]} #{type} ")
    end

    def pretty_print(mes)
      return if (LOG_LEVELS.find_index @opt[:min_level]) > (LOG_LEVELS.find_index mes[:type])

      type = colorize_type mes[:type]

      if mes[:tag] == "ActivityManager"
        if mes[:message] =~ /^Killing/
          m = mes[:message].match(/^Killing ([0-9]+):([^\s\/]+)/)
          puts
          puts "#{format_tag :activity_kill, "Killing process"} #{wrap_message(m[2] + " (pid " + m[1], "")})"
          puts
        elsif mes[:message] =~ /^Start proc/
          m = mes[:message].match(/^Start proc (.*)$/)
          puts
          puts "#{format_tag :activity_start, "Start process"} #{wrap_message(m[1], "")}"
          puts
        else
          puts "#{format_tag :normal, mes[:tag]} #{type} #{wrap_message mes[:message], type}"
        end
      else
        puts "#{format_tag :normal, mes[:tag]} #{type} #{wrap_message mes[:message], type}"
      end
    end

    def echo(mes)
      pretty_print parse_message mes
    end
  end
end
