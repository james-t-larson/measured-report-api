module VimeoWorkers
  class ContentPipeline
    include Sidekiq::Worker
    sidekiq_options queue: :default, retry: false

    def perform
      if future_job_already_scheduled?
        Rails.logger.info("[VimeoWorkers::ContentPipeline] Jobs already scheduled Halting.")
        return
      end

      if (video = Video.needs_details.first)
        Rails.logger.info("[VimeoWorkers::ContentPipeline] details -> ID=#{video.id}")
        VimeoServices::IngestContent.video(video)
        video.needs_transcript!
      elsif (video = Video.needs_transcript.first)
        Rails.logger.info("[VimeoWorkers::ContentPipeline] transcript -> ID=#{video.id}")
        VimeoServices::IngestContent.transcript(video)
        video.complete!
      elsif (transcript = Transcript.needs_vtt.first)
        Rails.logger.info("[VimeoWorkers::ContentPipeline] vtt -> ID=#{transcript.id}")
        VimeoServices::IngestContent.vtt(transcript)
        transcript.complete!
      end

      if work_remaining?
        Rails.logger.info("[VimeoWorkers::ContentPipeline] work remains; reschedule 30s")
        VimeoWorkers::ContentPipeline.perform_in(30.seconds)
      else
        Rails.logger.info("[VimeoWorkers::ContentPipeline] all done; not rescheduling")
      end
    end

    def work_remaining?
      Video.needs_details.exists? || Video.needs_transcript.exists? || Transcript.needs_vtt.exists?
    end

    def future_job_already_scheduled?
      Rails.logger.info("[VimeoWorkers::ContentPipeline] Checking for future jobs")
      Sidekiq::ScheduledSet.new.any? { |j| j.klass == self.class.name }
    end
  end
end
