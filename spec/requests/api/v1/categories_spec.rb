RSpec.describe 'api/v1/categories', type: :request do
  include_context "test_data"

  describe '/api/v1/categories' do
    it 'retrieves all categories' do
      get '/api/v1/categories'
      expect(response).to have_http_status(:success)

      data = JSON.parse(response.body)['data']

      expect(data.length).to eq(@categories.length)

      @categories.each_with_index do |category, index|
        category_data = data[index]

        expect(category_data).not_to be_nil
        expect(category_data).to include(
          'id' => category.id,
          'name' => category.name,
          'slug' => category.slug,
          'created_at' => category.created_at.as_json,
          'updated_at' => category.updated_at.as_json
        )
      end
    end
  end

  describe '/api/v1/categories/:id' do
    it 'retrieves a specific category' do
      category = @categories.first

      get "/api/v1/categories/#{category.id}"
      expect(response).to have_http_status(:success)

      data = JSON.parse(response.body)['data']
      expect(data).to include(
        'id' => category.id,
        'name' => category.name,
        'slug' => category.slug,
        'created_at' => category.created_at.as_json,
        'updated_at' => category.updated_at.as_json
      )
    end

    it 'returns 404 for non-existent category' do
      non_existant_category = @categories.last.id + 1
      get "/api/v1/categories/#{non_existant_category}/articles"
      expect(response).to have_http_status(:not_found)

      error = JSON.parse(response.body)
      expect(error).to include('message' => 'Record not found')
    end
  end

  describe '/api/v1/categories/:category_id/articles' do
    it 'retrieves all articles for a specific category' do
      category = @categories.first
      articles = category.articles

      get "/api/v1/categories/#{category.id}/articles"
      expect(response).to have_http_status(:success)

      data = JSON.parse(response.body)['data']
      expect(data.length).to eq(articles.length)

      articles.each_with_index do |article, index|
        article_data = data[index]

        expect(article_data).not_to be_nil
        expect(article_data).to include(
          'id' => article.id,
          'title' => article.title,
          'created_at' => article.created_at.as_json,
          'updated_at' => article.updated_at.as_json
        )
      end
    end
  end
end
