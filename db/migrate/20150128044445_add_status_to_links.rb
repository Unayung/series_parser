class AddStatusToLinks < ActiveRecord::Migration
  def change
    add_column :links, :update_status, :string
  end
end
