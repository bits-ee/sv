class TeamMemberOrderNumber < ActiveRecord::Migration
  def change
    add_column :users, :group_order_number, :decimal, :precision => 6, :scale => 2
  end

end
