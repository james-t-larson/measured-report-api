module Vimeo
  module IngestContent
    def self.transcript(video_record)
      res  = VimeoServices::ApiClient.fetch_texttracks(video_record.external_id)
      data = Array(res&.dig("data"))
      active = data.find { |t| t.dig("active") }
      id = active.dig("id").to_s
      vtt_link = active.dig("link")
      return if active.blank? || id.blank?

      Transcript.find_or_create_by!(external_id: id) do |t|
        t.video   = video_record
        t.vtt_link = vtt_link
      end
    rescue => e
      Rails.logger.error("[VimeoServices::IngestContent] ingest transcropt failed: #{e.message}")
      nil
    end

    def self.vtt(transcript_record)
      data = VimeoServices::ApiClient.fetch_vtt(transcript_record.vtt_link)
      return unless data.present?

      Transcript.update!(vtt: data)
    rescue => e
      Rails.logger.error("[VimeoServices::IngestContent] ingest transcript content failed: #{e.message}")
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
