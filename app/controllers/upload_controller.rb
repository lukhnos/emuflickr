require "base64"

class UploadController < ApplicationController
	
  	verify :method => :post, :only => [ :index ],
         :render => { :text => 'post only!' }
		
	def index
	
		@photo = Photo.new
		
		@photo.title = params[:title] || '' 
		@photo.description = params[:description] || '' 
		@photo.tags = params[:tags] || '' 
		@photo.is_public = params[:public] || true
		@photo.is_friend = params[:friend]
		@photo.is_family = params[:family]		
		params[:photo].binmode		
		
		@photo.data = Base64.encode64 ( params[:photo].read )
		
		logger.debug( request.raw_post.to_yaml )
			
		if @photo.save
		 render :text => '<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n<rsp stat=\"ok\"><photoid>1234</photoid></rsp>'
		else
		 render :text => 'error'
		end
		
	end
end
