class Api::V1::ArticlesController < Api::BaseController
  before_action :set_article, only: %i[ show ]

  def show
    generic_render(data: @article)
  end

  def index
    @articles = Article.all
    if params[:category_id].nil?
      @articles = Article.order(created_at: :desc).limit(10)
      generic_render(data: @articles)
    else
      @category = Category.find(params[:category_id])
      @articles = @category.articles.order(created_at: :desc).limit(10)
      generic_render(data: @articles, category: @category.name)
    end
  end

  private

  # def article_params
  #   params.permit(:category_id)
  # end

  def set_article
    @article = Article.find(params[:id])
  end
end
