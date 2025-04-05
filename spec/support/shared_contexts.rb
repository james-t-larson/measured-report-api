RSpec.shared_context "test_data" do
  before(:all) do
    @category_count = 5
    @article_count = 10
    @categories = create_list(:category, @category_count)
    @articles = create_list(:article, @article_count) do |article, i|
      article.save!
    end
  end

  after(:all) do
    Article.destroy_all
    Category.destroy_all
  end
end
