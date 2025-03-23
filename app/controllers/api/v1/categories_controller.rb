class Api::V1::CategoriesController < Api::BaseController
  before_action :set_category, only: %i[ show ]

  def index
    @categories = Category.all
    generic_render(data: @categories)
  end

  def show
    generic_render(data: @category)
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end
end
