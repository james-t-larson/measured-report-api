class Api::V1::ArticlesController < Api::BaseController
  before_action :set_article, only: %i[ show ]

  def show
    generic_render(data: @article)
  end

  def index
    @articles = Article.all
    @category = Category.find(params[:category_id])
    puts params
    puts @category.articles
    if @category.nil?
      generic_render(data: @articles)
    else
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
