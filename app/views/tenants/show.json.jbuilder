json.prettify! if %w(1 yes true).include?(params["pretty"])
json.extract! @tenant, :id, :name, :display_name, :created_at, :updated_at