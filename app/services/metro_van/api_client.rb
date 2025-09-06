module MetroVan
  class ApiClient
    include HTTParty
    base_uri "https://metrovancouver.org"

    HEADERS = {
      "Accept" => "application/json;odata=verbose",
      "X-Requested-With" => "XMLHttpRequest"
    }.freeze

    def fetch_meetings(start_date: nil, end_date: nil)
      start_date ||= 6.months.ago.beginning_of_day.utc.iso8601
      end_date   ||= Time.current.beginning_of_day.utc.iso8601

      endpoint = "/boards/_api/Web/Lists/GetByTitle('Meetings')/Items"
      options = {
        headers: HEADERS,
        query: {
          "$filter" => "EventStartDate ge datetime'#{start_date}' and EventStartDate lt datetime'#{end_date}'"
        }
      }

      response = self.class.get(endpoint, options)
      raise "MetroVan API error: #{response.code}" unless response.success?

      response.parsed_response.dig("d", "results")
    end
  end
end
