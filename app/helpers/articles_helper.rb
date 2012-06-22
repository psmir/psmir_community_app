module ArticlesHelper
  include ActsAsTaggableOn::TagsHelper

  def print_tags(article)
    if !params[:tags] && article.tag_list
      article.tag_list.join(", ") 
    else
      params[:tags]
    end
  end

 
  
end
