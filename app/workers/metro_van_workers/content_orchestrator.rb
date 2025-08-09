module MetroVanWorkers
  class ContentOrchestrator
    include Sidekiq::Worker

    def perform
      api_client = MetroVanServices::ApiClient.new
      ingest   = MetroVanServices::Ingest.new

      meetings = api_client.fetch_meetings

      meetings.each do |payload|
        ActiveRecord::Base.transaction do
          meeting_record = ingest.meeting(payload)
          ingest.documents(meeting_record, payload)
          ingest.videos(meeting_record, payload)
        end
      end
    end
  end
end
