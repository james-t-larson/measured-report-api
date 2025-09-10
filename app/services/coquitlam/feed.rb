module Coquitlam
  class Feed
    def self.retrieve
      url = "https://www.coquitlam.ca/RSSFeed.aspx?ModID=1&CID=Road-Work-and-Construction-5"

      feed = ::Feed.find_by(url: url)
      return feed if feed.present?

      position = ::Category.count + 1
      category = ::Category.find_or_create_by!(slug: "traffic", name: "Traffic", position: position)

      ::Feed.create!(
        url: url,
        name: "Coquitlam Construction",
        category: category
      )
    end
  end
end
