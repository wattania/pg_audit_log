require 'optparse'
require 'pathname'

DOCKER_USER  = "angstroms"

pwd = Pathname.new File.expand_path(File.dirname __FILE__)
CURRENT_DIR   = pwd.to_s
PROJECT_NAME  = pwd.basename.to_s

##############################################################################################################
class String
def black;          "\e[30m#{self}\e[0m" end
def red;            "\e[31m#{self}\e[0m" end
def green;          "\e[32m#{self}\e[0m" end
def brown;          "\e[33m#{self}\e[0m" end
def blue;           "\e[34m#{self}\e[0m" end
def magenta;        "\e[35m#{self}\e[0m" end
def cyan;           "\e[36m#{self}\e[0m" end
def gray;           "\e[37m#{self}\e[0m" end

def bg_black;       "\e[40m#{self}\e[0m" end
def bg_red;         "\e[41m#{self}\e[0m" end
def bg_green;       "\e[42m#{self}\e[0m" end
def bg_brown;       "\e[43m#{self}\e[0m" end
def bg_blue;        "\e[44m#{self}\e[0m" end
def bg_magenta;     "\e[45m#{self}\e[0m" end
def bg_cyan;        "\e[46m#{self}\e[0m" end
def bg_gray;        "\e[47m#{self}\e[0m" end

def bold;           "\e[1m#{self}\e[22m" end
def italic;         "\e[3m#{self}\e[23m" end
def underline;      "\e[4m#{self}\e[24m" end
def blink;          "\e[5m#{self}\e[25m" end
def reverse_color;  "\e[7m#{self}\e[27m" end
end
##############################################################################################################
def do_cmd cmd
  ret = true
  puts "==== COMMAND ============================================".bg_blue
  puts " : #{cmd}"
  puts 
  ret = system cmd if (cmd.is_a? String and cmd.size > 0)
  puts 
  ret
end

def docker_path a_tag_name = 'latest'
 "docker.io/#{DOCKER_USER}/#{PROJECT_NAME}:#{a_tag_name}" 
end

def build_docker_by_order
  success = true
  builded = []
  get_all_tags.each{|tag_info|
    build_req_tag tag_info[:req], builded if all_tags.include? tag_info[:req]
    
    unless builded.include? tag_info[:tag]
      success = do_cmd build_docker tag_info[:tag]
      raise "Build By Order Failed: #{tag_info[:fullpath]}" if not success
      builded << tag_info[:tag] if success
    end
  }
end

def build_req_tag a_tagname, builded
  build_orders = [] 

  tag_info = get_all_tags.select{|e| e[:tag] == a_tagname}.first
  if tag_info
    build_req_tag tag_info[:req], builded if all_tags.include? tag_info[:req]

    unless builded.include? tag_info[:tag]
      success = do_cmd build_docker tag_info[:tag]
      raise "Build By Order Failed: #{tag_info[:fullpath]}" if not success
      builded << tag_info[:tag] if success
    end
  end
end

def get_all_tags
  if @__all_tags.nil?
    @__all_tags = []
    Dir.glob(File.join CURRENT_DIR, "**/*").sort.each{|pp|
      path = pp.split(__dir__).last

      if ((path.start_with? '/docker') or (path.start_with? "/Dockerfile")) and path.end_with? 'Dockerfile'
        tag_name = path.split('/').select{|e| (e != 'docker') and (e != 'Dockerfile') and e.is_a? String and e.length > 0 }.join '_' 
        tag_name = "latest" if (tag_name.nil? or tag_name.to_s.strip == "")
        
        tag_info = {fullpath: pp, tag: tag_name}

        File.open(pp, 'r'){|f|
          tag_info[:data] = f.read
          from_cmd = tag_info[:data].split("\n").select{|e| e.start_with? 'FROM'}.first
          if from_cmd
            if from_cmd.split(":").size == 2
              req = from_cmd.split(":").last
              tag_info[:req] = req if req
            end
          end 
        }
        @__all_tags << tag_info
      end
    }
  end
  @__all_tags
end

def all_tags dir = CURRENT_DIR
  ret = []
  get_all_tags.each{|tags|
    ret.push tags[:tag]
  }
  ret.sort
end

def build_docker tag = "latest"
  puts "build_docker: #{tag}"
  cmd = nil
  tag_info = get_all_tags.select{|e| e[:tag] == tag }.first
  if tag_info
    pathname = Pathname.new tag_info[:fullpath]
    cmd = "docker build -t #{docker_path tag_info[:tag]} -f #{tag_info[:fullpath]} #{pathname.dirname}"
  end
  cmd
end

def main mode, opts 
  case mode
  when 'build'
    case opts[:tag]
    when 'all'
      build_docker_by_order
    else
      if all_tags.include? opts[:tag]
        do_cmd build_docker opts[:tag]
      else
        do_cmd build_docker "latest"
      end
    end  

  when 'tags'
    p all_tags

  else
    puts "Invalid Mode [build, tags]".red

  end
end

if __FILE__ == $0
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: [options]"

    opts.on('-t', '--tag name',           'build with tag name'){ |v| options[:tag] = v }
    
    #opts.on('-n', '--sourcename NAME',  'Source name') { |v| options[:source_name] = v }
    #opts.on('-h', '--sourcehost HOST',  'Source host') { |v| options[:source_host] = v }
    #opts.on('-p', '--sourceport PORT',  'Source port') { |v| options[:source_port] = v }

  end.parse!
  
  main ARGV.first, options
end