module VimeoWorkers
  class TranscriptProcessor
    include Sidekiq::Worker

    def perform
      pending_video = Video.pending.first

      if pending_video.present?
        VimeoServices::IngestContent.video(pending_video)
        VimeoWorkers::TranscriptProcessor.perform_in(30.seconds)
      else
        Rails.logger.info("[VimeoWorkers::TranscriptProcessor] Last batch complete")
      end
    end
  end
end
