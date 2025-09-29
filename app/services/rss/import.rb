module Rss
  class Import
    def initialize(entry, feed)
      # TODO: Pass an option to filter anything out that wasn't posted today
      Rails.logger.debug "[RSS::Import] Importing entry: #{entry.title}"

      entry_text = [
        entry&.title,
        entry&.summary,
        entry&.content
      ].compact.join(" ")

      unless feed.passes_filters?(entry_text)
        Rails.logger.info "[RSS::Import] Skipped entry due to filters: feed=#{feed.name} entry=#{entry.title}"
        return
      end

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
