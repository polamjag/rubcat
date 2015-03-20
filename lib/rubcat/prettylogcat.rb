module Rubcat
  class PrettyLogcat
    attr_reader :last_tag, :tag_length

    def initialize(tag_length=25)
      @tag_length = tag_length
    end

    def parse_message(mes)
      {
        type: mes.match(/^[VDIWEFS]/).to_s,
        tag: mes.match(/^.\/(.*)\(\s*[0-9]+\):/)[1].strip,
        pid: mes.match(/\(\s*([0-9]+)\):/)[1],
        message: mes.match(/\(\s*[0-9]+\):\s(.*)/)[1]
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
        # puts # separate messages
        if KNOWN_TAGS.include? tag
          tag.trim_and_rjust(@tag_length).bold.black.bg_gray
        else
          tag.trim_and_rjust(@tag_length).randomize_color.bold
        end
      else
        " " * @tag_length
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
