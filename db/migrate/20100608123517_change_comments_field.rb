class ChangeCommentsField < ActiveRecord::Migration
  def self.up
    change_column :comments, :comments, :text
  end

  def self.down
    change_column :comments, :comments, :string
  end
end
