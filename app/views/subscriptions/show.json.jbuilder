json.prettify! if %w(1 yes true).include?(params["pretty"])
json.extract! @subscription, :id, :name, :created_at, :updated_at, :display_name