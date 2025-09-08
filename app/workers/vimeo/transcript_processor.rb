module Vimeo
  class TranscriptProcessor
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

      Transcript.find(id).failed!
    end

    def perform(id)
      transcript = Transcript.find(id)

      if transcript.present?
        data = Vimeo::ApiClient.fetch_vtt(transcript.vtt_link)
        Rails.logger.info("[Vimeo::TranscriptProcessor] Fetched VTT #{data.first(10)}.")
        Vimeo::IngestContent.vtt(transcript, data)
        transcript.complete!

        Rails.logger.info("[Vimeo::TranscriptProcessor] Transcript #{transcript.id} completed.")
      end

      Vimeo::Orchestrator.perform_async
    end
  end
end
