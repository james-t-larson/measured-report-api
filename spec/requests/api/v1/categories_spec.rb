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
          'created_at' => category.created_at.as_json,
          'updated_at' => category.updated_at.as_json
        )
      end
    end
  end
end
