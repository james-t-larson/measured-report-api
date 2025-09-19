module Coquitlam
  class Feeds
    def self.retrieve
      Settings.feeds.coquitlam.map do |feed|
        url = feed[:url]
        name = feed[:name]
        category = feed[:category]
        slug = feed[:category].parameterize

        category_record = ::Category.find_or_create_by(slug: slug, name: category) do |record|
          record.position = ::Category.count + 1
        end

        feed = ::Feed.find_or_create_by(
          url: url,
          name: name,
          category_id: category_record.id
        )

        feed
      end.compact
    end
  end
end
