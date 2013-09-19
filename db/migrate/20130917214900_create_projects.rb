class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :url
      t.text :summary
      t.string :git_url
      t.string :title
      t.string :picture_url
      t.string :slug

      t.timestamps
    end
  end
end
