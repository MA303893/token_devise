json.prettify! if %w(1 yes true).include?(params["pretty"])
json.array!(@subscriptions) do |subscription|
  json.extract! subscription, :id, :name, :tenant_id
  json.url tenant_subscription_url(params[:tenant_id], subscription.id, format: :json)
end