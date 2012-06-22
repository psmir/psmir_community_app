Factory.define :article do |article|
  article.sequence(:title) { |n| "title#{n}" }
  article.sequence(:content) { |n| "content#{n}" }
end
