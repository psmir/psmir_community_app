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
      @user = create(:user)
      @article1 = create(:article, user: @user, created_at: 1.day.ago)
      @article2 = create(:article, user: @user, created_at: 2.days.ago)
    end

    it 'returns articles ordered from new to old' do
      Article.default_list.should == [@article1, @article2]
    end
  end


  describe '.in_blogs_selected_by' do
    before do
      @john = create(:user)
      @bob  = create(:user)
      @tom  = create(:user)
      @john.bloggers << @bob

      @article1 = create(:article, user: @bob)
      @article2 = create(:article, user: @tom)
    end

    it 'returns articles from selected blogs only' do
      Article.in_blogs_selected_by(@john).should == [@article1]
    end
  end
end
