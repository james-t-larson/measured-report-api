require "application_system_test_case"

class Admin::V1::ArticlesTest < ApplicationSystemTestCase
  setup do
    @admin_v1_article = admin_v1_articles(:one)
  end

  test "visiting the index" do
    visit admin_v1_articles_url
    assert_selector "h1", text: "Articles"
  end

  test "should create article" do
    visit admin_v1_articles_url
    click_on "New article"

    fill_in "Category", with: @admin_v1_article.category_id
    fill_in "Content", with: @admin_v1_article.content
    fill_in "Image", with: @admin_v1_article.image
    fill_in "Sentiment score", with: @admin_v1_article.sentiment_score
    fill_in "Sources", with: @admin_v1_article.sources
    fill_in "Summary", with: @admin_v1_article.summary
    fill_in "Title", with: @admin_v1_article.title
    click_on "Create Article"

    assert_text "Article was successfully created"
    click_on "Back"
  end

  test "should update Article" do
    visit admin_v1_article_url(@admin_v1_article)
    click_on "Edit this article", match: :first

    fill_in "Category", with: @admin_v1_article.category_id
    fill_in "Content", with: @admin_v1_article.content
    fill_in "Image", with: @admin_v1_article.image
    fill_in "Sentiment score", with: @admin_v1_article.sentiment_score
    fill_in "Sources", with: @admin_v1_article.sources
    fill_in "Summary", with: @admin_v1_article.summary
    fill_in "Title", with: @admin_v1_article.title
    click_on "Update Article"

    assert_text "Article was successfully updated"
    click_on "Back"
  end

  test "should destroy Article" do
    visit admin_v1_article_url(@admin_v1_article)
    click_on "Destroy this article", match: :first

    assert_text "Article was successfully destroyed"
  end
end
