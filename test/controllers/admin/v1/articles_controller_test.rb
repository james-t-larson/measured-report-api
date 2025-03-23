require "test_helper"

class Admin::V1::ArticlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_v1_article = admin_v1_articles(:one)
  end

  test "should get index" do
    get admin_v1_articles_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_v1_article_url
    assert_response :success
  end

  test "should create admin_v1_article" do
    assert_difference("Admin::V1::Article.count") do
      post admin_v1_articles_url, params: { admin_v1_article: { category_id: @admin_v1_article.category_id, content: @admin_v1_article.content, image: @admin_v1_article.image, sentiment_score: @admin_v1_article.sentiment_score, sources: @admin_v1_article.sources, summary: @admin_v1_article.summary, title: @admin_v1_article.title } }
    end

    assert_redirected_to admin_v1_article_url(Admin::V1::Article.last)
  end

  test "should show admin_v1_article" do
    get admin_v1_article_url(@admin_v1_article)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_v1_article_url(@admin_v1_article)
    assert_response :success
  end

  test "should update admin_v1_article" do
    patch admin_v1_article_url(@admin_v1_article), params: { admin_v1_article: { category_id: @admin_v1_article.category_id, content: @admin_v1_article.content, image: @admin_v1_article.image, sentiment_score: @admin_v1_article.sentiment_score, sources: @admin_v1_article.sources, summary: @admin_v1_article.summary, title: @admin_v1_article.title } }
    assert_redirected_to admin_v1_article_url(@admin_v1_article)
  end

  test "should destroy admin_v1_article" do
    assert_difference("Admin::V1::Article.count", -1) do
      delete admin_v1_article_url(@admin_v1_article)
    end

    assert_redirected_to admin_v1_articles_url
  end
end
