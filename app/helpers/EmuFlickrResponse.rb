
require 'rubygems'
require 'json'
require 'active_support'

# class Hash
  # def to_rest
    # result = '<?xml version="1.0" encoding="UTF8" ?><rsp stat="ok">'
    # self.each{ |pair|
      # result += "<#{pair[0]}"
      # pair[1].each{ |i| result += " #{i[0]}=\"#{i[1]}\"" unless i[0] == :_content }
      # if pair[1][:_content]
        # result += ">#{pair[1][:_content]}</#{pair[0]}>"
      # else
        # result += ' />'
      # end
    # }
    # result += '</rsp>'
  # end
# end

class EmuFlickrResponse
  def initialize
    @data = {}
    @key = ''
  end
  def method_missing msg, *arg
    item = msg.to_s
    if item =~ /=$/
      @key += item.chop!
      keys = @key.split(/\./)
      case keys.size
        when 1: add(lambda{|to_add| @data[keys[0]] = to_add}, @data[keys[0]], arg[0])
        when 2: add(lambda{|to_add| (@data[keys[0]] ||= {})[keys[1]] = to_add}, (@data[keys[0]] ||= {})[keys[1]], arg[0])
        when 3: hash_step = @data[keys[0]] ||= {}
                keys[1...keys.size-1].each{ |i|
                  hash_step[i] ||= {}
                  hash_step = hash_step[i]
                }
                add(lambda{|to_add| hash_step[keys[-1]] = to_add}, hash_step[keys[-1]], arg[0])
      end
      refresh
    else
      @key += item + '.'
    end
    self
  end

  def to_json
    @data.to_json
  end
  # def to_xml
    # result = '<?xml version="1.0" encoding="UTF8" ?><rsp stat="ok">'
    # @data.each{ |i|
      # result += "<#{i}"
      # if i[1].class.kind_of? Hash
        # i[1].each{ |ii|
          # result += " #{ii[0]}=\"#{ii[1]}\""
        # }
      # else
        # result += " #{i[0]}=\"#{i[1]}\""
        # ;
      # end
    # }
    # result += '</rsp>'
    # puts
    # puts @data.inspect
    # puts
    # @data.to_rest
  # end
  def to_xml
    # snip <hash> ... </hash>
    result = @data.to_xml.sub(/<hash>/, '<rsp stat="ok">').sub(/<\/hash>/, '</rsp>')
    result = @data.to_xml.sub(%r{(.+)<hash>(.+)</hash>}m){ $1 + '<rsp stat="ok">' + $2 + '</rsp>' }
      # .split(/\s\s+/).join(' ') # to compact

    # transform single element into attribute, and leave out element started with -
    result.gsub!(%r{<([^-].+)>(.*)</\1>}){ $1 + '="' + $2 + '"' }
    result.gsub!(%r{<(\w.+)>\s+((\w.*=".*"\s*)+)(.*)</\1>}m){
      m1 = $1
      if (m4 = $4) == "\n"
        "<%s "%m1 + $2.split(/\s\s+/).join(' ') + ">#{m4}</#{m1}>"
      else
        "<%s "%$1 + $2.split(/\s\s+/).join(' ') + ' />'
      end
    }
    result.gsub!(%r{<(\w.+)>\s+((.*/.*\s*)*)((\w.*=".*"\s*)+).*</\1>}){
      m1, m2 = $1, $2 # $ would be overwrite by split
      "<%s "%m1 + "%s>"%$4.split(/\s\s+/).join(' ') + (m2||'') + "</#{m1}>"
    }

    # transform _content to real content
    result.gsub!(%r{\s*<-content>(.*)</-content>\s*(<.+>)}){ $1 + $2}

    result
  end
  
  def to_xml_element_from_hash(hash)
    
    puts hash.to_json
    
    attr = []
    text = nil
    tail = ""
    
    hash.each_key do |k|
      v = hash[k]
      
      nodename = k
      
      puts "key = #{k}, value class =#{v.class}"
      if (v.class == String)
        puts "attr #{k}=\"#{v}\""
        attr << "#{k}=\"#{v}\""
      elsif (v.class == Hash && v[:_content])
        text = v[:_content].to_s
      elsif (v.class == Hash)
        
        attr_only = true
        v.each_key do |vv|
          if vv.class == Hash
            attr_only = false
          end
        end
        puts "attr only? #{attr_only}"
        
        if attr_only
          puts "emtting hash as attr node"
          v.each_key do |vv|
            puts "#{vv}=\"#{v[vv]}\""
            attr << "#{vv}=\"#{v[vv]}\""
          end
          puts "finished emtting"
        else
          text = to_xml_element_from_hash(v)
        end
      elsif (v.class == Array)
        text = ""
        v.each do |element|
          h = {}
          h[k] = element
          text += to_xml_element_from_hash(h)
        end
        return text
      end
      
      if attr.empty?
        head = "<#{k.to_s}"
      else
        head = "<#{k.to_s} #{attr.join " "}"
      end
      puts "head = #{head}"
      
      if text
        head += ">"
        tail = "</#{k.to_s}>"
      else
        head += "/>"
      end
      puts "head = #{head}, text=#{text}, tail = #{tail}"
      
      rsp = "#{head}#{text}#{tail}"
      puts "return = #{rsp}"
      rsp
    end
  end
  
  def to_xml_ours
    xmldoc = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    xmldoc += to_xml_element_from_hash(@data)
    xmldoc
  end
  
  def to_xml_original
    @data.to_xml
  end

  # for debug
  def debug_key
    @key
  end
  def debug_data
    @data
  end
  def debug_get
    result = @data[@key.chop]
    refresh
    result
  end

  private
  def refresh
    @key = ''
    self
  end
  def add func, item, to_add
    if item == nil
      func.call to_add
    else
      if item.kind_of? Array
        item << to_add
        func.call item
      else
        item = [] << item << to_add
        func.call item
      end
    end
  end
end

require 'test/unit'

class EFRTest < Test::Unit::TestCase
# '<auth>
	# <token>976598454353455</token>
	# <perms>read</perms>
	# <user nsid="12037949754@N01" username="Bees" fullname="Cal H" />
# </auth>'
  def test_01
    efr = EmuFlickrResponse.new
    efr.auth.token = {:_content=>'976598454353455'}
    efr.auth.perms = {:_content=>'read'}
    efr.auth.user = {:nsid=>'12037949754@N01', :username=>'Bees', :fullname=>'Cal H'}
    # puts efr.to_json
    # puts efr.to_xml
  end
# <frob>746563215463214621</frob>
  def test_02
    efr = EmuFlickrResponse.new
    efr.frob = {:_content=>'746563215463214621'}
    # puts efr.to_json
    # puts efr.to_xml
  end
# <photoid secret="abcdef" originalsecret="abcdef">1234</photoid>
  def test_03
    efr = EmuFlickrResponse.new
    efr.photoid = {:_content=>'1234', :secret=>'abcdef', :originalsecret=>"abcdef"}
    # puts efr.to_json
    # puts efr.to_xml
  end
# <foo bar="baz">
	# <woo yay="hoopla" />
# </foo>
  def test_04
    efr = EmuFlickrResponse.new
    efr.foo = {:bar=>'baz'}
    efr.foo.woo = {:yay=>'hoopla'}
    # puts efr.to_json
    # puts efr.to_xml
  end
# <outer>
	# <photo id="1" />
	# <photo id="2" />
# </outer>
  def test_05
    efr = EmuFlickrResponse.new
    efr.outer.photo = {:id=>'1'}
    efr.outer.photo = {:id=>'2'}
    puts efr.to_json
    puts efr.to_xml_original
    puts efr.to_xml
    puts efr.to_xml_ours
  end
end

# efr.data => {'auth.token'=>{:_content=>'976598454353455'}, 'auth.perm'=>{:_content=>'read'},
#             'auth.user'=>{:nsid=>'12037949754@N01', :username='Bees', :fullname=>'Cal H'}}

# <auth>
	# <token>976598454353455</token>
	# <perms>write</perms>
	# <user nsid="12037949754@N01" username="Bees" fullname="Cal H" />
# </auth>

# <auth>
	# <token>9765984553455</token>
	# <perms>write</perms>
	# <user nsid="12037949754@N01" username="Bees" fullname="Cal H" />
# </auth>

# <photoid>1234</photoid>

