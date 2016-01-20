json.prettify! if %w(1 yes true).include?(params["pretty"])
json.array!(@tenants) do |tenant|
  json.extract! tenant, :id, :name, :display_name
  json.url tenant_url(tenant.id, format: :json)
end