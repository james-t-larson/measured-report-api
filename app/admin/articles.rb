ActiveAdmin.register Article do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :title, :summary, :content, :sources, :category_id, :image, :sentiment_score
  #
  # or
  #
  permit_params do
    permitted = [ :title, :summary, :content, :sources, :category_id, :image, :sentiment_score ]
    # permitted << :other if params[:action] == "create" && current_user.admin?
    permitted << :other if params[:action] == "create"
    permitted
  end
end
