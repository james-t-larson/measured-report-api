module MetroVan
  class ContentPipeline
    include Sidekiq::Worker
    sidekiq_options queue: :default, retry: false

    def perform
      ingest   = MetroVan::IngestContent.new
      api_client = MetroVan::ApiClient.new

      meetings = api_client.fetch_meetings

      meetings.each do |payload|
        meeting_record = ingest.meeting(payload)
        ingest.documents(meeting_record, payload)
        ingest.videos(meeting_record, payload)
      end

      Vimeo::Orchestrator.perform_async
    end
  end
end
