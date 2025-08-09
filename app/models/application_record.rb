class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Use replica only in environments that define it
  if Rails.env.development? || Rails.env.production?
    connects_to database: { writing: :primary, reading: :replica }
  end
end
