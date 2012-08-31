class TwoMoreFields < ActiveRecord::Migration
  def change
    add_column :projects, :business_model, :text
    add_column :projects, :status, :string
  end

end
