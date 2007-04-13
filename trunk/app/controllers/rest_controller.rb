class RestController < ApplicationController
  
  def index
    method = params[:method]
    api_key = params[:api_key]
    case method
      when 'flickr.people.findByUsername' then
        @username = params[:username]      
        @user_id = "12340000"

        render :template => "rest/flickr_people_findByUsername", :layout => false
        
          
      when 'flickr.people.getPublicPhotos' then
          @user_id  = params[:user_id]
          @extras   = params[:extras]
          @per_page = params[:per_page].to_i
          @page     = params[:page].to_i
          @total    = Photo.count
          @photos   = Photo.find(:all, :order=>"id desc")            
          
          render :template => "rest/flickr_people_getPublicPhotos", :layout => false          
          # render :xml => "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n<rsp stat=\"ok\"><photos page=\"1\" pages=\"311\" perpage=\"2\" total=\"621\">	<photo id=\"434528712\" owner=\"68545471@N00\" secret=\"b7811b6475\" server=\"182\" farm=\"1\" title=\"Mt. Fuji from Plane\" ispublic=\"1\" isfriend=\"0\" isfamily=\"0\" />	<photo id=\"434523374\" owner=\"68545471@N00\" secret=\"f84f2b4ce4\" server=\"185\" farm=\"1\" title=\"Mt. Fuji from Plane\" ispublic=\"1\" isfriend=\"0\" isfamily=\"0\" /></photos></rsp>", :layout=>false
    end
  end
  
  
end


