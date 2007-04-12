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
    
    @format   = params[:format]    
    @real_filename = "%s.%s" % [@filename, @format]
    
    data = IO.read(File.join(RAILS_ROOT, "example_photos", "example_thumbnail.jpg"))
    
    send_data(data, :type => 'image/jpeg; charset=utf-8; header=present', :filename => @real_filename, :disposition => "inline")
  end
end
