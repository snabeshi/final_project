class WordsController < ApplicationController
  def index
    matching_words = Word.all

    @list_of_words = matching_words.order({ :created_at => :desc })

    render({ :template => "words/index.html.erb" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_words = Word.where({ :id => the_id })

    @the_word = matching_words.at(0)

    render({ :template => "words/show.html.erb" })
  end

  def create
    the_word = Word.new
    the_word.word = params.fetch("query_word")

    #==========================

    user_message = Message.new
    user_message.word_id = the_word.id
    user_message.role = "user"
    user_message.content = "Can you tell me the meaning of the word '#{the_word.word}'?"
    user_message.save

    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_TOKEN"))

    api_messages_array = Array.new

    word_messages = Message.where({ :user_id => @current_user.id, :word_id => the_word.id }).order(:created_at)

    word_messages.each do |the_message|
      message_hash = { :role => the_message.role, :content => the_message.content }

      api_messages_array.push(message_hash)
    end

    response = client.chat(
      parameters: {
          model: ENV.fetch("OPENAI_MODEL"),
          messages: api_messages_array,
          temperature: 1.0,
      }
    )

    assistant_message = Message.new
    assistant_message.word_id = the_word.id
    assistant_message.role = "assistant"
    assistant_message.content = response.fetch("choices").at(0).fetch("message").fetch("content")
    assistant_message.save    

    the_word.meaning = assistant_message.where({:user_id => @current_user.id, :word_id => the_word.id}).order(:created_at).at(0)

    #==========================

    user_message = Message.new
    user_message.word_id = the_word.id
    user_message.role = "user"
    user_message.content = "Can you give me an example sentence using the word '#{the_word.word}'?"
    user_message.save

    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_TOKEN"))

    api_messages_array = Array.new

    word_messages = Message.where({ :user_id => @current_user.id, :word_id => the_word.id }).order(:created_at)

    word_messages.each do |the_message|
      message_hash = { :role => the_message.role, :content => the_message.content }

      api_messages_array.push(message_hash)
    end

    response = client.chat(
      parameters: {
          model: ENV.fetch("OPENAI_MODEL"),
          messages: api_messages_array,
          temperature: 1.0,
      }
    )

    assistant_message = Message.new
    assistant_message.word_id = the_word.id
    assistant_message.role = "assistant"
    assistant_message.content = response.fetch("choices").at(0).fetch("message").fetch("content")
    assistant_message.save    

    the_word.ex_sentence = assistant_message.where({:user_id => @current_user.id, :word_id => the_word.id}).order(:created_at).at(0)

    #==========================

    user_message = Message.new
    user_message.word_id = the_word.id
    user_message.role = "user"
    user_message.content = "Can you give me top three collocations for the word '#{the_word.word}'? Give me only the words."
    user_message.save

    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_TOKEN"))

    api_messages_array = Array.new

    word_messages = Message.where({ :user_id => @current_user.id, :word_id => the_word.id }).order(:created_at)

    word_messages.each do |the_message|
      message_hash = { :role => the_message.role, :content => the_message.content }

      api_messages_array.push(message_hash)
    end

    response = client.chat(
      parameters: {
          model: ENV.fetch("OPENAI_MODEL"),
          messages: api_messages_array,
          temperature: 1.0,
      }
    )

    assistant_message = Message.new
    assistant_message.word_id = the_word.id
    assistant_message.role = "assistant"
    assistant_message.content = response.fetch("choices").at(0).fetch("message").fetch("content")
    assistant_message.save    

    the_word.top_collocations = assistant_message.where({:user_id => @current_user.id, :word_id => the_word.id}).order(:created_at).at(0)

    #==========================

    user_message = Message.new
    user_message.word_id = the_word.id
    user_message.role = "user"
    user_message.content = "If you express the frequency of use of the the word '#{the_word.word}' on a scale of 20, how much is it?"
    user_message.save

    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_TOKEN"))

    api_messages_array = Array.new

    word_messages = Message.where({ :user_id => @current_user.id, :word_id => the_word.id }).order(:created_at)

    word_messages.each do |the_message|
      message_hash = { :role => the_message.role, :content => the_message.content }

      api_messages_array.push(message_hash)
    end

    response = client.chat(
      parameters: {
          model: ENV.fetch("OPENAI_MODEL"),
          messages: api_messages_array,
          temperature: 1.0,
      }
    )

    assistant_message = Message.new
    assistant_message.word_id = the_word.id
    assistant_message.role = "assistant"
    assistant_message.content = response.fetch("choices").at(0).fetch("message").fetch("content")
    assistant_message.save    

    the_word.frequency_of_use = assistant_message.where({:user_id => @current_user.id, :word_id => the_word.id}).order(:created_at).at(0)

    #==========================

    if the_word.valid?
      the_word.save
      redirect_to("/words", { :notice => "Word created successfully." })
    else
      redirect_to("/words", { :alert => the_word.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_word = Word.where({ :id => the_id }).at(0)

    the_word.word = params.fetch("query_word")
    the_word.meaning = params.fetch("query_meaning")
    the_word.ex_sentence = params.fetch("query_ex_sentence")
    the_word.top_collocations = params.fetch("query_top_collocations")
    the_word.frequency_of_use = params.fetch("query_frequency_of_use")
    the_word.user_id = params.fetch("query_user_id")

    if the_word.valid?
      the_word.save
      redirect_to("/words/#{the_word.id}", { :notice => "Word updated successfully."} )
    else
      redirect_to("/words/#{the_word.id}", { :alert => the_word.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_word = Word.where({ :id => the_id }).at(0)

    the_word.destroy

    redirect_to("/words", { :notice => "Word deleted successfully."} )
  end
end
