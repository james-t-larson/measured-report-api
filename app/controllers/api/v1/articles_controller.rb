class Api::V1::ArticlesController < Api::BaseController
  before_action :set_article, only: %i[ show ]

  def show
    generic_render(data: @article)
  end

  def index
    @articles = Article.all
    puts @articles
    if params[:category_id].nil?
      generic_render(data: @articles)
    else
      @category = Category.find(params[:category_id])
      generic_render(data: @category.articles, category: @category.name)
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
