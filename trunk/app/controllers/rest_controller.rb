class RestController < ApplicationController
  
  def index
    method = params[:method]
    api_key = params[:api_key]
  case method
  when 'flickr.people.findByUsername' then
      username =params[:username]
      
       render :text => '<?xml version=\"1.0\" encoding=\"utf-8\" ?><user nsid="12037949632@N01">
       	<username>'+ username +'</username> </user>'
      
          
  when 'flickr.people.getPublicPhotos' then
      user_id  = params[:user_id]
      extras   = params[:extras]
      per_page = params[:per_page]
      page     = params[:page] 
      photos   = Photo.find(:all, :order=>"id desc")
      
      for photo in photos do
         test_title = photo.title
      end
        
      
      render :text =>'<photos page="2" pages="89" perpage="10" total="881">
      	<photo id="2636" owner='+user_id+'
      		secret="a123456" server="2" title="test_04"
      		ispublic="1" isfriend="0" isfamily="0" />
      	<photo id="2635" owner='+user_id+'
      		secret="b123456" server="2" title="test_03"
      		ispublic="0" isfriend="1" isfamily="1" />
      	<photo id="2633" owner='+user_id+'
      		secret="c123456" server="2" title="test_01"
      		ispublic="1" isfriend="0" isfamily="0" />
      	<photo id="2610" owner='+user_id+'
      		secret="d123456" server="2" title="00_tall"
      		ispublic="1" isfriend="0" isfamily="0" />
      </photos>'+test_title.to_s
    
  end
  end
  
  
end


