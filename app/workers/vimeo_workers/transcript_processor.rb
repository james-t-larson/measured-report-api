module VimeoWorkers
  class TranscriptProcessor
    include Sidekiq::Worker
    sidekiq_options queue: :default, retry: false

    def perform
      if future_job_already_scheduled?
        Rails.logger.info("[VimeoWorkers::TranscriptProcessor] Jobs already scheduled Halting.")
        return
      end

      @pending_transcripts ||= Transcript.pending
      @active_transcript ||= @pending_transcripts.first

      unless @active_transcript.present?
        Rails.logger.info("[VimeoWorkers::TranscriptProcessor] No pending transcripts. Halting.")
        return
      end

      VimeoServices::IngestContent.transcript(@active_transcript)
      @active_transcript.success!
      remaining_count = @pending_transcripts.count

      Rails.logger.info(
        "[VimeoWorkers::TranscriptProcessor] " \
        "Transcript #{@active_transcript.id} (#{@active_transcript.title}) completed. " \
        "#{remaining_count} transcripts remaining."
      )

      VimeoWorkers::TranscriptProcessor.perform_in(30.seconds)
    end

    def future_job_already_scheduled?
      Rails.logger.info("[VimeoWorkers::TranscriptProcessor] Checking for future jobs")
      Sidekiq::ScheduledSet.new.any? { |j| j.klass == self.class.name }
    end
  end
end
