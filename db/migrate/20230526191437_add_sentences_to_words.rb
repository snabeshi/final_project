class AddSentencesToWords < ActiveRecord::Migration[6.0]
  def change
    add_column :words, :ex_sentence, :text
  end
end
