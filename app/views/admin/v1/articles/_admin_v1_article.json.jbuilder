json.extract! admin_v1_article, :id, :title, :summary, :content, :sources, :category_id, :image, :sentiment_score, :created_at, :updated_at
json.url admin_v1_article_url(admin_v1_article, format: :json)
