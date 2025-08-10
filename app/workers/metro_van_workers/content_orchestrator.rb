module MetroVanWorkers
  class ContentOrchestrator
    include Sidekiq::Worker
    sidekiq_options queue: :metro_van, retry: false

    def perform
      ingest   = MetroVanServices::IngestContent.new
      api_client = MetroVanServices::ApiClient.new

      meetings = api_client.fetch_meetings

      Rails.logger.info(meetings)

      meetings.each do |payload|
        meeting_record = ingest.meeting(payload)
        ingest.documents(meeting_record, payload)
        ingest.videos(meeting_record, payload)
      end
    end
  end
end
