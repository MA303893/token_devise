require 'elasticsearch'

class Tenant

  attr_accessor :name, :display_name, :id, :created_at, :updated_at


  def self.all
    @client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]
    result = @client.search index: ELASTICSEARCH_SERVER['admin_index'].to_s, type: 'tenants', body:{size: 99999999}
    tenants = Array.new
    result['hits']['hits'].each do |res|
      tenant = Tenant.new
      tenant.name = res['_source']['Tenant']
      tenant.display_name = res['_source']['Name']
      tenant.id = res['_id']
      tenants << tenant
    end
    tenants
  end

  def save(params)
    @client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]
    self.name = params["name"]
    if @client.indices.exists_type index: ELASTICSEARCH_SERVER['admin_index'], type: 'tenantseq'
      res_id = @client.index(index: ELASTICSEARCH_SERVER['admin_index'] , type: 'tenantseq' , id: 'sequence', body:{ })['_version']
      result = @client.index  index: ELASTICSEARCH_SERVER['admin_index'] , type: 'tenants' , id: res_id, body: {      Name: params["display_name"], Tenant: params["name"] ,      State: 'created',DateofCreation: Time.now.strftime("%d/%m/%Y").to_s,LastUpdated: Time.now.strftime("%d/%m/%Y").to_s}
      create_index
      update_logstash
      return res_id
    else
      @client.indices.put_mapping index: ELASTICSEARCH_SERVER['admin_index'], type: 'tenantseq', body: {tenantseq: {
                                                                                                          properties:{}
                                                                                                        }
                                                                                                        }
      res_id = @client.index(index: ELASTICSEARCH_SERVER['admin_index'] , type: 'tenantseq' , id: 'sequence', body:{ })['_version']
      result = @client.index  index: ELASTICSEARCH_SERVER['admin_index'] , type: 'tenants' , id: res_id, body: {      Name: params["display_name"], Tenant: params["name"] ,      State: 'created',DateofCreation: Time.now.strftime("%d/%m/%Y").to_s,LastUpdated: Time.now.strftime("%d/%m/%Y").to_s}
      create_index
      update_logstash
      return res_id
    end
  end

  def update(params,id)
    @client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]
    self.name = params["name"]
    result =  @client.update index: ELASTICSEARCH_SERVER['admin_index'], type: 'tenants', id: id, body:{
      doc:{
        Name: params["display_name"], Tenant: params["name"], LastUpdated: Time.now.strftime("%d/%m/%Y").to_s
      }
    }, refresh: true
    create_index
    Tenant.find(result['_id'])

  end

  def destroy
    @client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]
    @client.delete index: ELASTICSEARCH_SERVER['admin_index'], type: 'tenants', id: self.id
  end

  def self.find(id)
    @client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]
    tenant_result = nil
    begin
      tenant_result = @client.get(index: ELASTICSEARCH_SERVER['admin_index'] , type: 'tenants' , id: id)
    rescue
    end
    if !tenant_result.nil?
      tenant = Tenant.new
      tenant.name = tenant_result['_source']['Tenant']
      tenant.display_name = tenant_result['_source']['Name']
      tenant.id = tenant_result['_id']
      tenant.created_at = tenant_result['_source']['DateofCreation']
      tenant.updated_at = tenant_result['_source']['LastUpdated']
      return tenant
    end
  end

  def subscriptions
    @client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]
    subscription_result = @client.search index: ELASTICSEARCH_SERVER['admin_index'].to_s, type: 'subscriptions', body:{
      size: 99999999,
      query:{
        filtered:{
          query:{
            match:{
              Tenant_id:{
                query: @id, type: "phrase"
              }
            }
          }
        }
      }
    }
    subscriptions = Array.new
    subscription_result['hits']['hits'].each do |res|
      subscription =  Subscription.new
      subscription.name = res['_source']['Subscription']
      subscription.display_name = res['_source']['Name']
      subscription.id = res['_id']
      subscription.budget = res['_source']['Budget']
      subscription.tenant_id = res['_source']['Tenant_id']
      subscription.created_at = res['_source']['DateofCreation']
      subscription.updated_at = res['_source']['LastUpdated']
      subscriptions << subscription
    end
    subscriptions
  end

  def create_index
    @client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]
    if !@client.indices.exists index: self.name.downcase
      ip = ELASTICSEARCH_SERVER['ip'].to_s
      port = ELASTICSEARCH_SERVER['port'].to_s
      `curl -XPUT 'http://#{ip}:#{port}/#{self.name.downcase}'`
      `curl -XPUT 'http://#{ip}:#{port}/#{self.name.downcase}/system-metrics/_mapping' -d '{  "system-metrics" : {"properties" : {"Blueprint" : { "type" : "string", "index" : "not_analyzed" }, "Name" : { "type" : "string", "index" : "not_analyzed" }, "Subscription" : { "type" : "string", "index" : "not_analyzed" }, "Tenant" : { "type" : "string", "index" : "not_analyzed" } } }}'`
      `curl -XPUT 'http://#{ip}:#{port}/#{self.name.downcase}/service-metrics/_mapping' -d '{  "service-metrics" : {"properties" : {"Blueprint" : { "type" : "string", "index" : "not_analyzed" }, "Name" : { "type" : "string", "index" : "not_analyzed" }, "Subscription" : { "type" : "string", "index" : "not_analyzed" }, "Tenant" : { "type" : "string", "index" : "not_analyzed" } } }}'`
      `curl -XPUT 'http://#{ip}:#{port}/#{self.name.downcase}/serviceavailability/_mapping' -d '{  "serviceavailability" : {"properties" : {"Blueprint" : { "type" : "string", "index" : "not_analyzed" }, "Name" : { "type" : "string", "index" : "not_analyzed" }, "Subscription" : { "type" : "string", "index" : "not_analyzed" }, "Tenant" : { "type" : "string", "index" : "not_analyzed" } } }}'`
      `curl -XPUT 'http://#{ip}:#{port}/#{self.name.downcase}/vmavailability/_mapping' -d '{  "vmavailability" : {"properties" : {"Blueprint" : { "type" : "string", "index" : "not_analyzed" }, "Name" : { "type" : "string", "index" : "not_analyzed" }, "Subscription" : { "type" : "string", "index" : "not_analyzed" }, "Tenant" : { "type" : "string", "index" : "not_analyzed" } } }}'`
      `curl -XPUT 'http://#{ip}:#{port}/#{self.name.downcase}/logs/_mapping' -d '{  "logs" : {"properties" : {"Blueprint" : { "type" : "string", "index" : "not_analyzed" }, "Name" : { "type" : "string", "index" : "not_analyzed" }, "Subscription" : { "type" : "string", "index" : "not_analyzed" }, "Tenant" : { "type" : "string", "index" : "not_analyzed" } } }}'`
      `curl -XPUT 'http://#{ip}:#{port}/#{self.name.downcase}/assets/_mapping' -d '{  "assets" : {"properties" : {"Blueprint" : { "type" : "string", "index" : "not_analyzed" }, "Name" : { "type" : "string", "index" : "not_analyzed" }, "Subscription" : { "type" : "string", "index" : "not_analyzed" }, "Tenant" : { "type" : "string", "index" : "not_analyzed" } } }}'`

    end
    result_mapper = @client.search( :index => ELASTICSEARCH_SERVER['admin_index'], :type => 'entity_mapper')
    keys_result_mapper = result_mapper['hits']['hits'][0]['_source'].values
    tenant = keys_result_mapper[0].to_s
    subscription =keys_result_mapper[1].to_s
    blueprint = keys_result_mapper[2].to_s
    puts blueprint
    month = Time.now.strftime("%m").to_s
    year = Time.now.strftime("%Y").to_s
    id   = self.name+Time.now.strftime("%m").to_s+Time.now.strftime("%Y").to_s
    tenantname = self.name.to_s
    displayname = self.display_name.to_s


    if @client.indices.exists_type index: ELASTICSEARCH_SERVER['admin_index'], type: 'monthly_billing'

      `curl -XPUT "http://#{ip}:#{port}/admin/monthly_billing/#{id}" -d' { #{tenant} : "#{tenantname}", #{subscription} : "*", #{blueprint} : "*", "RecordId" : "#{id}", "View" : "Tenant", "TotalCost" : "0.0", "Month" : "#{month}", "Year" : "#{year}", "Name" : "#{displayname}" } '`
    end
  end

  def update_logstash      
    Net::SCP.download!(LOGSTASH_SERVER['ip'], LOGSTASH_SERVER['username'], LOGSTASH_SERVER['server_path_download'], LOGSTASH_SERVER['rails_path_download'], :ssh => { :keys => LOGSTASH_SERVER['keys_path'] } )
    puts "Downloaded"
    myfile = File.open("agent.conf", "r+")
    text = File.read(myfile)
    a   = " \nkafka {" +              
          "\nzk_connect => \"internal-kafkacluster-218486480.us-east-1.elb.amazonaws.com:2181\"" +
           "\ntopic_id => " + self.name.to_s +
           "\nreset_beginning => false" + 
           "\nconsumer_threads => 1" +
           "\ngroup_id => \"" + "CG_" + self.name.to_s + "\"" + 
          "\n} \nkafka {"
           new_contents = text.sub(/kafka\s*\{/, a)        
          myfile2 = File.open("agent.conf", "r+")
    myfile2.write(new_contents)
    myfile2.close()
    myfile.close()
    puts "edited"
    Net::SCP.upload!(LOGSTASH_SERVER['ip'], LOGSTASH_SERVER['username'], LOGSTASH_SERVER['rails_path_upload'], LOGSTASH_SERVER['server_path_upload'], :ssh => { :keys => LOGSTASH_SERVER['keys_path'] } )
    puts "Uploaded"
  end
end
