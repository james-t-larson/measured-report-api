module MetroVanServices
  class Ingest
    def meeting(meeting_payload)
      attributes = {
        external_id:    meeting_payload["ID"],
        title:          meeting_payload["Title"] || item["MeetingTitle"],
        start_datetime: meeting_payload["EventStartDate"],
        end_datetime:   meeting_payload["EventEndDate"],
        location:       meeting_payload["Location"]
      }

      meeting_record = Meeting.find_or_initialize_by(external_id: attributes[:external_id])
      meeting_record.assign_attributes(attributes)
      meeting_record.save!

      meeting_record
    end

    def videos(meeting_record, meeting_payload)
      external_ids = meeting_payload
        .select { |key, val| key.to_s.include?("SingleLine") && val.present? }
        .values
        .uniq

      videos = external_ids.map do |id|
        Video.new(
          external_id: id,
        )
      end

      return if videos.blank?
      meeting_record.videos << videos
    end

    def documents(meeting_record, meeting_payload)
      links = meeting_payload
        .select { |key, val| key.to_s.include?("Link") && val.is_a?(Hash) && val["Url"].present? }
        .values
        .uniq

      documents = links.map do |link|
        Document.new(
          title: link["Description"].to_s.strip.presence || "Unknown",
          link:  link["Url"].to_s.strip
        )
      end

      return if documents.blank?
      meeting_record.documents << documents
    end
  end
end
