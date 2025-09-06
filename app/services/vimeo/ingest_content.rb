module Vimeo
  module IngestContent
    def self.transcript(video, raw_texttracks)
      data = Array(raw_texttracks&.dig("data"))
      active = data.find { |t| t.dig("active") }
      id = active.dig("id").to_s
      vtt_link = active.dig("link")
      return if active.blank? || id.blank?

      Transcript.find_or_create_by!({
        external_id: id,
        video: video,
        vtt_link: vtt_link
      }).reload
    rescue => e
      Rails.logger.error("[VimeoServices::IngestContent] ingest transcropt failed: #{e.message}")
      nil
    end

    def self.vtt(transcript, raw_vtt)
      return unless raw_vtt.present?

      transcript.update!(vtt: raw_vtt)

      transcript.reload
    rescue => e
      Rails.logger.error("[VimeoServices::IngestContent] ingest transcript content failed: #{e.message}")
      nil
    end

    def self.video(video, data)
      return unless data.present? && video.present?

      Rails.logger.info("[VimeoServices::IngestContent]: Injesting Video #{video.id} (#{video.title}).")

      video.update!(
        title: data["name"],
        link:  data["link"]
      )

      video.reload
    rescue => e
      Rails.logger.error("[VimeoServices::IngestContent] Video ingestion failed: #{e.message}")
      nil
    end
  end
end
