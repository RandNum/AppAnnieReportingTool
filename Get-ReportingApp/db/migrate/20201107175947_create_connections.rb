class CreateConnections < ActiveRecord::Migration[6.0]
  def change
    create_table :connections do |t|
      t.string :name
      t.string :connection
      t.string :app
      t.string :platform
      t.string :country
      t.date :date
      t.decimal :impressions
      t.decimal :ad_revenue
      t.decimal :cpm
      t.belongs_to :report, null: false, foreign_key: true

      t.timestamps
    end
  end
end
