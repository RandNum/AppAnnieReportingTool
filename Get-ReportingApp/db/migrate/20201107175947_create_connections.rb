class CreateConnections < ActiveRecord::Migration[6.0]
  def change
    create_table :connections do |t|
      t.string :name
      t.string :connection
      t.string :app
      t.string :platform
      t.string :country
      t.date :date
      t.integer :impressions
      t.decimal :ad_revenue, :precision => 10, :scale => 2
      t.decimal :cpm, :precision => 10, :scale => 2
      t.belongs_to :report, null: false, foreign_key: true

      t.timestamps
    end
  end
end
