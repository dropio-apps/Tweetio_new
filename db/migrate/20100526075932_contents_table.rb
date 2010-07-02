class ContentsTable < ActiveRecord::Migration
  def self.up
    create_table :contents do |t|
      t.string :content_type
      t.string :content_name
    end
    content_array = ["image","video","audio","other"]

    for i in 0..content_array.size-1
      content = Content.new
      content.content_type = content_array[i]
      content.save
    end
  end

  def self.down
     drop_table :contents
  end
end
