require 'spec_helper'

describe PagesController do
  describe 'GET #about' do
    it 'renders the :about template' do
      get :about
      response.should render_template :about
    end
  end
end
