class ContestLocalized < ActiveRecord::Migration
  def up
    add_column :contests, :deadline, :date, :null => false, :default => Date.today
    add_column :contests, :name_en, :string
    add_column :contests, :name_es, :string
    execute("update contests set deadline = DATE('2012.02.15'), name_en = 'Spring 2012', name_es = 'Primavera 2012';")
  end

  def down
    remove_column :contests, :name_en
    remove_column :contests, :name_es
    remove_column :contests, :deadline
  end
end
