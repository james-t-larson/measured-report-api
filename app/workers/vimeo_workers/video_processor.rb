module VimeoWorkers
  class VideoProcessor
    include Sidekiq::Worker
    sidekiq_options queue: :default, retry: false

    def perform
      if future_job_already_scheduled?
        Rails.logger.info("[VimeoWorkers::VideoProcessor] Jobs already scheduled Halting.")
        return
      end

      @pending_videos ||= Video.pending
      @active_video ||= @pending_videos.first

      unless @active_video.present?
        Rails.logger.info("[VimeoWorkers::VideoProcessor] No pending videos. Halting.")
        return
      end

      VimeoServices::IngestContent.video(@active_video)
      @active_video.success!
      remaining_count = @pending_videos.count

      Rails.logger.info(
        "[VimeoWorkers::VideoProcessor] " \
        "Video #{@active_video.id} (#{@active_video.title}) completed. " \
        "#{remaining_count} videos remaining."
      )

      VimeoWorkers::VideoProcessor.perform_in(30.seconds)
    end

    def future_job_already_scheduled?
      Rails.logger.info("[VimeoWorkers::VideoProcessor] Checking for future jobs")
      Sidekiq::ScheduledSet.new.any? { |j| j.klass == self.class.name }
    end
  end
end
