
require 'rubygems'
require 'json'
require 'active_support'

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
  def to_xml
    @data.to_xml
    # modify here
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
    # puts efr.to_json
    # puts efr.to_xml
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

