class PhotosController < ApplicationController
  yullio_page_width :doc
  yullio_column_template :yui_t2
  
  def index
  end
  
  def fetch
    @server   = params[:server]
    @filename = params[:filename]
    @size     = :medium
    
    if @filename =~ /_o$/ 
      @size = :original
    elsif @filename =~ /_t$/
      @size = :thumbnail
    elsif @filename =~ /_m$/
      @size = :small
    elsif @filename =~ /_b$/
      @size = :large
    elsif @filename =~ /_s$/
      @size = :square
    end
    
    rfn = @filename.split("_")
    
    logger.info "fetching photo id = #{rfn[1]}"
    realid = rfn[0]
    
    
    @format   = params[:format]    
    @real_filename = "%s.%s" % [@filename, @format]
    
    photo = Photo.find(realid)
#    photo = Photo.find(1)
    
	#f= File.open( File.join(RAILS_ROOT, "example_photos", "example_thumbnail.jpg") )
	#f.binmode	
	#data = f.read
	#f.close
	
    send_data( Base64.decode64(photo.data) , :type => 'image/jpeg; charset=utf-8; header=present', :filename => @real_filename, :disposition => "inline")
  end
end
