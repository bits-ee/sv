class AllOtherFields < ActiveRecord::Migration
  def change

    add_column :users, :skype, :string
    add_column :projects, :url          , :string
    add_column :projects, :synopsys     , :text
    add_column :projects, :market       , :text
    add_column :projects, :competitors  , :text
    add_column :projects, :advantages   , :text
    add_column :projects, :technology   , :text
    add_column :projects, :finance      , :text
    add_column :projects, :current_stage, :text
    add_column :projects, :team         , :text

  end

end
