class WordsController < ApplicationController
  def index
    matching_words = Word.where(:user_id => @current_user.id)

    @list_of_words = matching_words.order({ :created_at => :desc })

    render({ :template => "words/index.html.erb" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_words = Word.where({ :id => the_id })

    @the_word = matching_words.where(:user_id => @current_user.id).at(0)

    render({ :template => "words/show.html.erb" })
  end

  def create
    the_word = params.fetch("query_word")

    #==========================

    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_TOKEN"))

    response_1 = client.chat(
      parameters: {
          model: ENV.fetch("OPENAI_MODEL"),
          messages: [
            { role: "system", content: "Consicely answer the questions regarding the word provided by the user. Say only the meaning." },
            { role: "user", content: "Can you consicely tell me the meaning of the word '#{the_word}'?"}
            ],
          temperature: 1.0,
      }
    )

    #==========================

    response_2 = client.chat(
      parameters: {
          model: ENV.fetch("OPENAI_MODEL"),
          messages: [
            { role: "system", content: "Consicely answer the questions regarding the word provided by the user." },
            { role: "user", content: "Can you consicely give me one example sentence using the word '#{the_word}'? Say only the sentence."}
            ],
          temperature: 1.0,
      }
    )

    #==========================

    response_3 = client.chat(
      parameters: {
          model: ENV.fetch("OPENAI_MODEL"),
          messages: [
            { role: "system", content: "Consicely answer the questions regarding the word provided by the user." },
            { role: "user", content: "Can you consicely tell me the top three collocation for the word '#{the_word}'?  Say only the words with numbering."}
            ],
          temperature: 1.0,
      }
    )

    #==========================

    response_4 = client.chat(
      parameters: {
          model: ENV.fetch("OPENAI_MODEL"),
          messages: [
            { role: "system", content: "Consicely answer the questions regarding the word provided by the user." },
            { role: "user", content: "Can you roughly estimate the frequency of the use of the word '#{the_word}' in modern English on a scale of 20? Say only the number." }
            ],
          temperature: 1.0,
      }
    )

    assistant_message = Word.new
    assistant_message.word = the_word
    assistant_message.meaning = response_1.fetch("choices").at(0).fetch("message").fetch("content")
    assistant_message.ex_sentence = response_2.fetch("choices").at(0).fetch("message").fetch("content")
    assistant_message.top_collocations = response_3.fetch("choices").at(0).fetch("message").fetch("content")
    assistant_message.frequency_of_use = response_4.fetch("choices").at(0).fetch("message").fetch("content")
    assistant_message.user_id = @current_user.id

    assistant_message.save    
    
    redirect_to("/words", { :notice => "Word created successfully." })
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
