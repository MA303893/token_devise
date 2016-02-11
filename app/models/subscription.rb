class Subscription

  attr_accessor :name, :display_name, :id, :created_at, :updated_at, :tenant_id, :budget, :tenant_name
  cattr_accessor :client
  @@client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]

  def self.all
    result = @@client.search index: ELASTICSEARCH_SERVER['admin_index'].to_s, type: 'subscriptions', body:{size: 99999999}
    subscriptions = Array.new
    result['hits']['hits'].each do |res|
      subscription = Subscription.new
      subscription.name = res['_source']['Subscription']
      subscription.display_name = res['_source']['Name']
      subscription.id = res['_id']
      subscription.budget = res['_source']['Budget']
      subscription.tenant_id = res['_source']['Tenant']#['Tenant_id']
      subscription.created_at = res['_source']['DateofCreation']
      subscription.updated_at = res['_source']['LastUpdated']
      subscription.tenant_name = res['_source']['Tenant']

      subscriptions << subscription
    end
    subscriptions
  end

  def save(params)

    #if @@client.indices.exists_type index: ELASTICSEARCH_SERVER['admin_index'], type: 'subscriptionseq'
      res_id = params[:id] #@@client.index(index: ELASTICSEARCH_SERVER['admin_index'] , type: 'subscriptionseq' , id: 'sequence', body:{ }, refresh: true)['_version']
      result = @@client.index  index: ELASTICSEARCH_SERVER['admin_index'] , type: 'subscriptions' , id: res_id, body: {
        Name: params["display_name"], Tenant: tenant.name , Tenant_id: params['tenant_id'],
        Subscription: params['name'], Budget: params['budget'],
        State: 'created',DateofCreation: Time.now.strftime("%d/%m/%Y").to_s,LastUpdated: Time.now.strftime("%d/%m/%Y").to_s
      }
      self.name = params['name']
      create_billing
      return res_id
    #else
    #   @@client.indices.put_mapping index: ELASTICSEARCH_SERVER['admin_index'], type: 'subscriptionseq', body: {
    #     subscriptionseq: {
    #       properties:{}
    #     }
    #   }
    #   res_id = @@client.index(index: ELASTICSEARCH_SERVER['admin_index'] , type: 'subscriptionseq' , id: 'sequence', body:{ }, refresh: true)['_version']
    #   result = @@client.index  index: ELASTICSEARCH_SERVER['admin_index'] , type: 'subscriptions' , id: res_id, body: {
    #     Name: params["display_name"], Tenant: tenant.name , Tenant_id: params['tenant_id'],
    #     Subscription: params['name'], Budget: params['budget'],
    #     State: 'created',DateofCreation: Time.now.strftime("%d/%m/%Y").to_s,LastUpdated: Time.now.strftime("%d/%m/%Y").to_s
    #   }
    #   create_billing
    #   return res_id
    # end
  end

  def self.find(id)
    subscription_result = nil
    begin
      subscription_result = @@client.get(index: ELASTICSEARCH_SERVER['admin_index'] , type: 'subscriptions' , id: id)
    rescue
    end
    if !subscription_result.nil?
      subscription = Subscription.new
      subscription.name = subscription_result['_source']['Subscription']
      subscription.display_name = subscription_result['_source']['Name']
      subscription.id = subscription_result['_id']
      subscription.created_at = subscription_result['_source']['DateofCreation']
      subscription.updated_at = subscription_result['_source']['LastUpdated']
      subscription.tenant_id = subscription_result['_source']['Tenant_id']
      subscription.tenant_name = subscription_result['_source']['Tenant']
      subscription.budget = subscription_result['_source']['Budget']
      return subscription
    end
  end

  def update(params,id)

    result =  @@client.update index: ELASTICSEARCH_SERVER['admin_index'], type: 'subscriptions', id: id, body:{
      doc:{
        Name: params["display_name"], Subscription: params["name"], Budget: params["budget"], LastUpdated: Time.now.strftime("%d/%m/%Y").to_s
      }
    }, refresh: true
    create_billing
    Subscription.find(result['_id'])
    
  end

  def destroy
    @@client.delete index: ELASTICSEARCH_SERVER['admin_index'], type: 'subscriptions', id: self.id
  end

  def tenant
    @tenant = Tenant.new
    #find tenant with subscriptions's tenant_id
    tenant_result = @@client.get(index: ELASTICSEARCH_SERVER['admin_index'] , type: 'tenants' , id: @tenant_id)
    @tenant.name = tenant_result['_source']['Tenant']
    @tenant.display_name = tenant_result['_source']['Name']
    @tenant.id = @tenant_id
    @tenant.created_at = tenant_result['_source']["DateofCreation"]
    @tenant.updated_at = tenant_result['_source']['LastUpdated']
    @tenant
  end

  def create_billing
      
        ip = ELASTICSEARCH_SERVER['ip'].to_s 
        port = ELASTICSEARCH_SERVER['port'].to_s
        result_mapper = @@client.search( :index => ELASTICSEARCH_SERVER['admin_index'], :type => 'entity_mapper')
        puts result_mapper
        keys_result_mapper = result_mapper['hits']['hits'][0]['_source'].values
        tenant = keys_result_mapper[0].to_s
        puts tenant
        subscription =keys_result_mapper[1].to_s
        puts subscription
        blueprint = keys_result_mapper[2].to_s
        puts blueprint
        month = Time.now.strftime("%m").to_s
        year = Time.now.strftime("%Y").to_s
        puts self.name
        id   = self.tenant.name+self.name+Time.now.strftime("%m").to_s+Time.now.strftime("%Y").to_s
        tenantname = self.tenant.name.to_s
        subscriptionname = self.name.to_s
        displayname = self.display_name.to_s
       
        if @@client.indices.exists_type  index: ELASTICSEARCH_SERVER['admin_index'] , type: 'monthly_billing'
              `curl -XPUT "http://#{ip}:#{port}/admin/monthly_billing/#{id}" -d' { #{tenant} : "#{tenantname}", #{subscription} : "#{subscriptionname}", #{blueprint} : "*", "RecordId" : "#{id}", "View" : "Subscription", "TotalCost" : "0.0", "Month" : "#{month}", "Year" : "#{year}", "Name" : "#{displayname}" } '`
               puts "mapping is done based on entity mapper upon subscription onboarding"
        end
    end

end
