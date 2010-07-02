class AddMediaName < ActiveRecord::Migration
  def self.up
    add_column :upload_files, :media_name, :text
  end

  def self.down
    remove_column :upload_files, :media_name, :text
  end
end
