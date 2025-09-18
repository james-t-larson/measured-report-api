HTTParty::Basement.default_options.update(
  logger: Rails.logger,
  log_level: :info,
  log_format: :curl
)
