class CreateWords < ActiveRecord::Migration[6.0]
  def change
    create_table :words do |t|
      t.string :word
      t.string :meaning
      t.string :top_collocations
      t.string :frequency_of_use
      t.integer :user_id

      t.timestamps
    end
  end
end
