class AddPhotos < ActiveRecord::Migration
  def self.up
	create_table :photos do |t|
		t.column :title,		:string
		t.column :description,	:text
		t.column :tags,	:string
		t.column :data,	:binary
		t.column :is_public,	:boolean
		t.column :is_friend,	:boolean
		t.column :is_family,	:boolean
		t.column :created_at,	:datetime
	end
  end

  def self.down
	drop_table	:photos
  end
end
