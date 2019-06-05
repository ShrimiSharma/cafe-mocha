class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :asin
      t.string :name
      t.string :rank
      t.string :product_dimensions

      t.timestamps
    end
  end
end
