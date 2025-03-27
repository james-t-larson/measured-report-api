require 'swagger_helper'

RSpec.describe 'api/v1/articles', type: :request do
  before do
    @article = create(:article)
  end

  path '/articles' do
    get 'Retrieves articles from today' do
      tags 'Articles'
      produces 'application/json'

      response '200', 'articles found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   title: { type: :string },
                   summary: { type: :string },
                   content: { type: :string },
                   sources: { type: :string },
                   category_id: { type: :integer },
                   image: { type: :string },
                   sentiment_score: { type: :integer },
                   created_at: { type: :string, format: 'date-time' },
                   updated_at: { type: :string, format: 'date-time' }
                 },
                 required: [ 'id', 'title', 'summary', 'created_at', 'updated_at', 'content', 'sources' ]
               }

        run_test! do |response|
          json_response = JSON.parse(response.body.data)

          expect(response).to have_http_status(:success)
          expect(json_response.length).to eq(1)

          article_data = json_response.first
          expect(article_data['id']).to eq(@article.id)
          expect(article_data['title']).to eq(@article.title)
          expect(article_data['summary']).to eq(@article.summary)
          expect(article_data['created_at']).to eq(@article.created_at.as_json)
          expect(article_data['updated_at']).to eq(@article.updated_at.as_json)
          expect(article_data['content']).to eq(@article.content.as_json)
          expect(article_data['sources']).to eq(@article.sources.as_json)
        end
      end
    end
  end

  # path '/api/v1/articles/{id}' do
  #   parameter name: 'id', in: :path, type: :string, description: 'id'
  #
  #   get('show article') do
  #     response(200, 'successful') do
  #       let(:id) { '123' }
  #
  #       after do |example|
  #         example.metadata[:response][:content] = {
  #           'application/json' => {
  #             example: JSON.parse(response.body, symbolize_names: true)
  #           }
  #         }
  #       end
  #       run_test!
  #     end
  #   end
  # end

  # path '/api/v1/categories/{category_id}/articles' do
  #   parameter name: 'category_id', in: :path, type: :string, description: 'category_id'
  #
  #   get('list articles') do
  #     response(200, 'successful') do
  #       let(:category_id) { '123' }
  #
  #       after do |example|
  #         example.metadata[:response][:content] = {
  #           'application/json' => {
  #             example: JSON.parse(response.body, symbolize_names: true)
  #           }
  #         }
  #       end
  #       run_test!
  #     end
  #   end
  # end
end
