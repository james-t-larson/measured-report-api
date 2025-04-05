RSpec.describe 'api/v1/articles', type: :request do
  include_context "test_data"

  describe '/api/v1/articles' do
    it 'retrieves articles from today' do
      get '/api/v1/articles'
      expect(response).to have_http_status(:success)

      data = JSON.parse(response.body)['data']
      expect(data.length).to eq(@article_count)

      @articles.each_with_index do |article, index|
        article_data = data[index]

        expect(article_data).not_to be_nil

        expect(article_data).to include(
          'id' => article.id,
          'title' => article.title,
          'summary' => article.summary,
          'created_at' => article.created_at.as_json,
          'updated_at' => article.updated_at.as_json,
          'content' => article.content.as_json,
          'sources' => article.sources.as_json
        )
      end
    end
  end

  describe '/api/v1/article/:id' do
    it 'retrieves a specific article by id' do
      article = @articles.first

      get "/api/v1/articles/#{article.id}"

      expect(response).to have_http_status(:success)

      article_data = JSON.parse(response.body)['data']
      expect(article_data).not_to be_nil

      expect(article_data).to include(
        'id' => article.id,
        'title' => article.title,
        'summary' => article.summary,
        'created_at' => article.created_at.as_json,
        'updated_at' => article.updated_at.as_json,
        'content' => article.content.as_json,
        'sources' => article.sources.as_json
      )
    end
  end
end
