Rails.application.config.to_prepare do
  skip = %w[application_record]

  exceptions = {
    "category" => "categories"
  }

  Dir[Rails.root.join("app/models/*.rb")].each do |file|
    model_name = File.basename(file, ".rb")
    next if skip.include?(model_name)

    class_name = model_name.camelize
    plural_const = exceptions[model_name] || model_name.pluralize
    plural_class = plural_const.camelize

    Object.const_set(plural_class, class_name.constantize) unless Object.const_defined?(plural_class)
  end
end
