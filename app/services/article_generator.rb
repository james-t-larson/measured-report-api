require "httparty"
require "json-schema"
require "json"

class ArticleGenerator
  include HTTParty

  @@api_key = ENV["LLM_API_KEY"]
  @@system_instructions = nil

  base_uri ENV.fetch("LLM_BASE_URI", "https://api.openai.com")

  class ResponseValidationError < StandardError; end
  class MissingAPIKeyError < StandardError; end

  COMPLETIONS_ROUTE = "/v1/chat/completions"

  RESPONSE_SCHEMA = {
    name: "article_schema",
    strict: true,
    schema: {
      type: "object",
      properties: {
        article: {
          type: "object",
          properties: {
            title: {
              type: "string",
              description: "The title of the article."
            },
            summary: {
              type: "string",
              description: "A short summary of the article."
            },
            content: {
              type: "string",
              description: "The main content of the article."
            }
          },
          required: [ "title", "summary", "content" ],
          additionalProperties: false
        }
      },
      required: [ "article" ],
      additionalProperties: false
    }
  }

  def self.api_key
    @@api_key
  end

  def self.api_key=(value)
    @@api_key = value
  end

  def initialize(api_key = nil)
    @@api_key = api_key || ENV["LLM_API_KEY"]
    raise_missing_key if @@api_key.nil?
  end

  def generate_article(title:, summary:, content:)
    response = self.class.post(
      COMPLETIONS_ROUTE,
      headers: {
        "Authorization" => "Bearer #{@@api_key}",
        "Content-Type" => "application/json"
      },
      body: request_payload(title, summary, content).to_json
    )

    article_data = JSON.parse(response["choices"].first["message"]["content"], symbolize_names: true)

    # TODO: Use validate response to trigger retry in generation worker
    validate_response(article_data)
  end

  private

  def request_payload(title, summary, content)
    {
      model: "gpt-4o",
      messages: [
        {
          role: "system",
          content: [
            {
              type: "text",
              text: system_instructions
            }
          ]
        },
        {
          role: "user",
          content: [
            {
              type: "text",
              text: "Please rewrite the following title in an objective, impartial tone: #{title}"
            },
            {
              type: "text",
              text: "Please rewrite the following title in an objective, impartial tone: #{summary}"
            },
            {
              type: "text",
              text: "Please rewrite the following article content in an objective, impartial tone: #{content}"
            }
          ]
        }
      ],
      temperature: 1,
      max_tokens: 2048,
      top_p: 1,
      frequency_penalty: 0,
      presence_penalty: 0,
      response_format: {
        type: "json_schema",
        json_schema: RESPONSE_SCHEMA
      }
    }
  end

  def system_instructions
    @@system_instructions ||= <<~INSTRUCTIONS.strip
      You are a neutral editor. Rewrite any article the user gives you so it is politically neutral,
      without polarization, and free of sentiment. Remove or rephrase politically polarizing language
      from any side. Eliminate any emotionally charged or opinionated phrasing. Preserve all core
      factual information and maintain a clear, coherent structure in the output.
    INSTRUCTIONS
  end

  def validate_response(data)
    JSON::Validator.validate!(RESPONSE_SCHEMA[:schema], data)
    data
  rescue JSON::Schema::ValidationError
    false
  end

  private

  def raise_missing_key
    raise MissingAPIKeyError, "API key is missing. Provide it as an argument or set LLM_API_KEY environment variable."
  end
end
