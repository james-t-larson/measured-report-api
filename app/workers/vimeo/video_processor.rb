module Vimeo
  class VideoProcessor
    include Sidekiq::Worker
    sidekiq_options(
      queue: :default,
      retry: 3,
      lock: :until_and_while_executing,
      lock_timeout: 0,
      on_conflict: { client: :log, server: :raise },
      unique_args: ->(args) { [ args.first ] }
    )

    sidekiq_retries_exhausted do |msg, _ex|
      id = msg["args"].first

      Video.find(id).failed!
    end

    def perform(id)
      video = Video.find(id)
      Rails.logger.info("[Vimeo::VideoProcessor] Processing video #{video.id}")

      if video.title.nil? || video.link.nil?
        Rails.logger.info("[Vimeo::VideoProcessor] Processing title and link for video #{video.id}")
        data = Vimeo::ApiClient.fetch_video(video.external_id)
        Vimeo::IngestContent.video(video, data)

        Rails.logger.info("[Vimeo::VideoProcessor] Video #{video.id} link and title added.")
      elsif video.transcript.nil?
        Rails.logger.info("[Vimeo::VideoProcessor] Processing transcript for video #{video.id}")
        res = Vimeo::ApiClient.fetch_texttracks(video.external_id)
        Vimeo::IngestContent.transcript(video, res)
        video.complete!

        Rails.logger.info("[Vimeo::VideoProcessor] Video #{video.id} (#{video.title}) completed.")
      end

      Vimeo::ContentPipeline.perform_async
    end
  end
end
