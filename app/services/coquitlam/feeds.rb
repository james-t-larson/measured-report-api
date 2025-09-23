module Coquitlam
  class Feeds
    def self.retrieve
      Settings.feeds.coquitlam.map do |feed|
        url = feed[:url]
        name = feed[:name]
        category = feed[:category]
        slug = feed[:category].parameterize
        filters = feed[:filters]

        category_record = ::Category.find_or_create_by(slug: slug, name: category) do |record|
          record.position = ::Category.count + 1
        end

        feed_record = ::Feed.find_or_create_by(url: url, name: name) do |record|
          record.category = category_record
        end

        filters.each do |filter|
          function, pattern = filter.to_h.first

          ::FeedFilter.find_or_create_by(
            feed_id: feed_record.id,
            function: function,
            pattern: pattern
          )
        end if filters.present?

        feed_record
      end.compact
    end
  end
end
