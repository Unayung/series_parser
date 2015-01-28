class AddLinkStructure < ActiveRecord::Migration
  def change
    create_table :links
    add_column :links, :url, :string, :unique => true
    add_column :links, :title, :string
    add_column :links, :parse_result, :text
    add_column :links, :created_at, :datetime
    add_column :links, :updated_at, :datetime
  end
end
