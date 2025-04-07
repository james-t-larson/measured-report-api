require 'rails_helper'

RSpec.describe Article, type: :model do
  let(:category) { Category.create(name: "Test Category", position: 1) }

  describe "associations" do
    it { should belong_to(:category) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(255) }

    it { should validate_length_of(:summary).is_at_most(500) }
    it { should allow_value(nil).for(:summary) }
    it { should allow_value("").for(:summary) }

    it { should validate_presence_of(:content) }

    it { should validate_length_of(:sources).is_at_most(255) }
    it { should allow_value(nil).for(:sources) }
    it { should allow_value("").for(:sources) }

    it { should allow_value("http://example.com").for(:image) }
    it { should allow_value("https://example.com/image.jpg").for(:image) }
    it { should_not allow_value("not-a-url").for(:image) }
    it { should allow_value(nil).for(:image) }
    it { should allow_value("").for(:image) }

    it { should validate_numericality_of(:sentiment_score).is_greater_than_or_equal_to(-1.0).is_less_than_or_equal_to(1.0) }
    it { should allow_value(nil).for(:sentiment_score) }
  end

  describe "scopes" do
    describe ".positive_sentiment" do
      before do
        @category = Category.create(name: "News", position: 1)
        @positive_article = Article.create(
          title: "Good News",
          content: "Something wonderful happened",
          category: @category,
          sentiment_score: 0.8
        )
        @neutral_article = Article.create(
          title: "Neutral News",
          content: "Something happened",
          category: @category,
          sentiment_score: 0
        )
        @negative_article = Article.create(
          title: "Bad News",
          content: "Something terrible happened",
          category: @category,
          sentiment_score: -0.5
        )
        @no_sentiment_article = Article.create(
          title: "No Sentiment",
          content: "Something happened",
          category: @category
        )
      end

      it "returns only articles with positive sentiment scores" do
        expect(Article.positive_sentiment).to include(@positive_article)
        expect(Article.positive_sentiment).not_to include(@neutral_article)
        expect(Article.positive_sentiment).not_to include(@negative_article)
        expect(Article.positive_sentiment).not_to include(@no_sentiment_article)
      end
    end
  end
end
