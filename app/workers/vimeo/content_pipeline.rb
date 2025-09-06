module Vimeo
  class ContentPipeline
    include Sidekiq::Worker
    sidekiq_options queue: :default, retry: false

    def perform(work_remaining: nil)
      jittered_delay = rand(5..30).seconds

      if (transcript = Transcript.in_progress.first.presence)
        Rails.logger.info("[Vimeo::ContentPipeline] Starting Transcript processor")
        Vimeo::TranscriptProcessor.perform_in(jittered_delay, transcript.id)
        return
      elsif (video = Video.in_progress.first.presence)
        Rails.logger.info("[Vimeo::ContentPipeline] Starting video processor")
        Vimeo::VideoProcessor.perform_in(jittered_delay, video.id)
        return
      end

      if work_remaining?
        Rails.logger.info("[Vimeo::ContentPipeline] Starting Content Orchestator")
        Vimeo::ContentPipeline.new.perform
      end
    end

    def work_remaining?
      Video.in_progress.present? || Transcript.in_progress.present?
    end

    def future_job_already_scheduled?
      Rails.logger.info("[Vimeo::ContentPipeline] Checking for future jobs")
      Sidekiq::ScheduledSet.new.any? { |j| j.klass == self.class.name }
    end
  end
end
