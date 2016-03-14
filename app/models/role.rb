class Role

  @@client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]
  attr_accessor :role, :asset, :chargeback, :audit, :monitor, :network_audit, :id

  def initialize
    @role, @asset, @chargeback, @audit, @monitor, @network_audit, @id = nil
  end

  def save(params)
    @@client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]
    res_id = params["id"]
    result = @@client.index  index: ELASTICSEARCH_SERVER['admin_index'] , type: 'roles' , id: res_id, body: { Role: params["role"], Asset: params["asset"], Audit: params['audit'], Chargeback: params['chargeback'], Monitor: params['monitor'], NetworkAudit: params['network_audit']}
    return res_id
  end

  def update(params, id)
    result =  @client.update index: ELASTICSEARCH_SERVER['admin_index'], type: 'roles', id: id, body:{
      doc:{
        Name: params["display_name"], Tenant: params["name"], LastUpdated: Time.now.strftime("%d/%m/%Y").to_s
      }
    }, refresh: true
  end
  def self.find(id)
    role_result = @@client.get(index: ELASTICSEARCH_SERVER['admin_index'] , type: 'roles' , id: id) rescue nil
    if !role_result.nil?
      role = Role.new
      role.role = role_result['_source']['Role']
      role.asset = role_result['_source']['Asset']
      role.chargeback = role_result['_source']['Chargeback']
      role.audit = role_result['_source']['Audit']
      role.monitor = role_result['_source']['Monitor']
      role.network_audit = role_result['_source']['NetworkAudit']
      role.id = role_result['_id']
      role
    end
  end
  def destroy
    @@client.delete index: ELASTICSEARCH_SERVER['admin_index'], type: 'roles', id: self.id
  end
  def self.all
    result = @@client.search index: ELASTICSEARCH_SERVER['admin_index'].to_s, type: 'roles', body:{size: 99999999}
    puts JSON.pretty_generate(result)
    roles = []
    result['hits']['hits'].each do |res|
      role = Role.new
      role.role = res['_source']['Role']
      role.asset = res['_source']['Asset']
      role.chargeback = res['_source']['Chargeback']
      role.monitor = res['_source']['Monitor']
      role.network_audit = res['_source']['NetworkAudit']
      role.audit = res['_source']['Audit']
      roles << role
    end
    roles
  end

end
