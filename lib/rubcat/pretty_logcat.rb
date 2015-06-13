module Rubcat
  class PrettyLogcat
    attr_reader :opt, :last_tag

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
        type: m[1],
        tag: m[2].strip,
        pid: m[3],
        message: m[4]
      }
    end

    def colorize_type(type)
      case type
      when "V"
        " #{type} ".bold.bg_gray.black
      when "D"
        " #{type} ".bold.bg_blue
      when "I"
        " #{type} ".bold.bg_green
      when "W"
        " #{type} ".bold.bg_brown
      else
        " #{type} ".bold.bg_red
      end
    end

    KNOWN_TAGS = %w{dalvikvm art dex2oat}

    def format_tag(tag)
      unless tag == @last_tag
        @last_tag = tag
        puts if @opt[:split_tags]
        if KNOWN_TAGS.include? tag
          tag.trim_and_rjust(@opt[:tag_length]).bold.black.bg_gray
        else
          tag.trim_and_rjust(@opt[:tag_length]).randomize_color.bold
        end
      else
        " " * @opt[:tag_length]
      end
    end

    def prettify(mes)
      buf = format_tag mes[:tag]

      buf += " "
      buf += colorize_type mes[:type]
      buf += " "
      buf += mes[:message]
      buf
    end

    def echo(mes)
      puts prettify parse_message mes
    end
  end
end
