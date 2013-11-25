require 'spec_helper'

describe Article do
  describe 'mass assinment' do
    it { should_not allow_mass_assignment_of(:user_id) }
  end

  describe 'validation' do
    it { should validate_presence_of :title }
    it { should validate_presence_of :content }
  end

  describe '#threaded_comments' do
    it 'returns threaded comments' do
      article = stub_model Article
      article.stub_chain(:comment_threads, :order).with('lft').and_return comments = stub('comments')
      article.threaded_comments.should == comments
    end
  end

  describe '.default_list' do
    before do
      @user = create_user!
      @article1 = Factory(:article, :user_id => @user.id, :created_at => 1.day.ago)
      @article2 = Factory(:article, :user_id => @user.id, :created_at => 2.days.ago)
    end

    it 'returns articles ordered from new to old' do
      Article.default_list.should == [@article1, @article2]
    end
  end 

  describe '.search_by_tag' do
    before do
      @user = create_user!
      @article1 = Factory(
        :article, 
        :user_id => @user.id, 
        :created_at => 1.day.ago, 
        :tag_list => 'important')
      
      @article2 = Factory(
        :article, 
        :user_id => @user.id, 
        :created_at => 2.day.ago, 
        :tag_list => 'important')
      
      @article3 = Factory(
        :article, 
        :user_id => @user.id, 
        :created_at => 3.day.ago, 
        :tag_list => 'unimportant')
    end
  
    it 'returns articles ordered from new to old that have the tag' do
      Article.search_by_tag('important').should == [@article1, @article2]
    end
  end

  describe '.in_blogs_selected_by' do
    before do
      @john = create_user!
      @bob  = create_user!
      @tom  = create_user!
      @john.bloggers << @bob

      @article1 = Factory(:article, :user_id => @bob.id)
      @article2 = Factory(:article, :user_id => @tom.id) 
    end
   
    it 'returns articles from selected blogs only' do
      Article.in_blogs_selected_by(@john).should == [@article1]
    end
  end
end