class UploadFileTable < ActiveRecord::Migration
  def self.up
    create_table :upload_files do |t|
      t.integer :user_id
      t.integer :content_id
      t.text :title
      t.text :name
      t.text :description
      t.string :original_file_name
      t.string :file_size
      t.string :height
      t.string :width
      t.string :status
      t.string :converted_file_name
      t.text :thumbnail
      t.text :large_thumb
      t.string :drop_name
      t.text :hidden_url
      t.text :url
      t.integer :view_count
      t.text :embed_code
      t.integer :upload_player_type
      t.string :encrypt_id
      t.timestamp :created_at
      t.timestamp :updated_at      
    end
  end

  def self.down
    drop_table :upload_files
  end
end
