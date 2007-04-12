
class EmuFlickrResponse
  def initialize
    @data = {}
    @key = ''
  end
  def method_missing msg, *arg, &block
    item = msg.to_s
    if item =~ /=$/
      @key += item.chop!
      # array = @key.split(/\./)
      # array[0...array.size-1].each{ |i|
        
        # if @data[i] == nil
          # @data[i] = {}
        # end
      # }
      @data[item] = arg
      refresh
    else
      @key += item + '.'
    end
    self
  end
  def get
    result = @data[@key.chop]
    refresh
    result
  end

# <foo bar="baz" />

# {
	# "foo": {
		# "bar": "baz"
	# }
# }

  def to_json
    # result = '{'
    # array = @data.to_a.sort
    # now = ''
    # array.each{ |i|
      # if now == ''
        # i.split(/./).each{ |ii|
          # if now != ii
            # now += ii
            # result +=
          # end
        # }
      # end
    # }
  end

  # for debug
  def debug_key
    @key
  end
  def debug_data
    @data
  end

  private
  def refresh
    @key = ''
  end
end

# '<auth>
	# <token>976598454353455</token>
	# <perms>read</perms>
	# <user nsid="12037949754@N01" username="Bees" fullname="Cal H" />
# </auth>'

# Efr = EmuFlickrResponse.new
# Efr.auth.token = {:_content=>'976598454353455'}
# Efr.auth.perms = {:_content=>'read'}
# Efr.auth.user = {:nsid=>'12037949754@N01', :username=>'Bees', :fullname=>'Cal H'}




# efr.data => {'auth.token'=>{:_content=>'976598454353455'}, 'auth.perm'=>{:_content=>'read'},
#             'auth.user'=>{:nsid=>'12037949754@N01', :username='Bees', :fullname=>'Cal H'}


# <frob>746563215463214621</frob>

# <auth>
	# <token>976598454353455</token>
	# <perms>write</perms>
	# <user nsid="12037949754@N01" username="Bees" fullname="Cal H" />
# </auth>

# <auth>
	# <token>976598454353455</token>
	# <perms>write</perms>
	# <user nsid="12037949754@N01" username="Bees" fullname="Cal H" />
# </auth>

# <photoid>1234</photoid>

# <photoid secret="abcdef" originalsecret="abcdef">1234</photoid>

# <ticketid>1234</ticketid>

