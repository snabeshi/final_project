# == Schema Information
#
# Table name: words
#
#  id               :integer          not null, primary key
#  ex_sentence      :text
#  frequency_of_use :string
#  meaning          :string
#  top_collocations :string
#  word             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :integer
#
class Word < ApplicationRecord
  belongs_to :users

end
