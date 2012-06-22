module ApplicationHelper
  def snippet(text, wordcount, omission)
    if text
      text.split[0..(wordcount-1)].join(" ") + (text.split.size > wordcount ? " " + omission : "")
    end
  end

end
