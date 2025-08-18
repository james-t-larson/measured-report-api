module MetroVan
  class IngestContent
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

      return if external_ids.blank?

      ApplicationRecord.transaction do
        external_ids.map do |id|
          Video.find_or_create_by(external_id: id) do |video|
            meeting_record.videos << video
          end
        end
      end
    end

    def documents(meeting_record, meeting_payload)
      links = meeting_payload
        .select { |key, val| key.to_s.include?("Link") && val.is_a?(Hash) && val["Url"].present? }
        .values
        .uniq

      return if links.blank?
      ApplicationRecord.transaction do
        links.each do |item|
          attrs = {
            link: item["Url"],
            title: item["Description"]
          }

          Document.find_or_create_by(attrs) do |doc|
            meeting_record.documents << doc
          end
        end
      end
    end
  end
end
