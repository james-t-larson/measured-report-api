module VimeoServices
  module IngestContent
    def self.transcript(video_record)
      res  = VimeoServices::ApiClient.fetch_texttracks(video_record.external_id)
      data = Array(res&.dig("data"))
      active = data.find { |t| t["active"] }
      return unless active && active["id"].present?

      Transcript.find_or_create_by!(external_id: active["id"].to_s) do |t|
        t.video   = video_record
      end
    rescue => e
      Rails.logger.error("VimeoServices::IngestContent.transcripts ingest failed: #{e.message}")
      nil
    end

    def self.video(video_record)
      data = VimeoServices::ApiClient.fetch_video(video_record.external_id)
      return unless data.present?

      Rails.logger.info("[VimeoServices::IngestContent]: Injesting Video #{video_record.id} (#{video_record.title}).")

      video_record.update(
        title: data["name"],
        link:  data["link"]
      )
    rescue => e
      Rails.logger.error("[VimeoServices::IngestContent] Video ingestion failed: #{e.message}")
      nil
    end
  end
end
