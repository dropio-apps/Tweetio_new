class CommentsTable < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :users_id
      t.integer :upload_file_id
      t.string :comments
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end

  def self.down
    drop_table :comments
  end
end
