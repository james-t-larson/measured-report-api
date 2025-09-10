module Rss
  class Import
    def initialize(entry, feed)
      Rails.logger.debug "[RSS::Import] Importing entry: #{entry.title}"

      processed_entry = {
        title:           entry&.title,
        url:             entry&.url,
        summary:         entry&.summary,
        content:         entry&.content,
        image:           entry&.image,
        published_at:    entry&.published
      }

      internal_entry = FeedEntry.find_or_initialize_by(
        feed_id:     feed.id,
        category_id: feed.category_id,
        guid:        entry.entry_id
      )

      if internal_entry.new_record?
        internal_entry.assign_attributes(processed_entry)
        internal_entry.save!
      end
    end
  end
end
