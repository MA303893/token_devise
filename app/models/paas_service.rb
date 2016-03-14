class PaasService

  attr_reader :path, :host, :username, :keys

  def initialize
    @path = LOGSTASH_PRODUCER["path"]
    @host = LOGSTASH_PRODUCER["ip"] #enter remote ip of logstash producer here
    @username = LOGSTASH_PRODUCER["username"]
    @keys = LOGSTASH_PRODUCER["keys_path"] # enter key path here
    @client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]
  end

  def delete_paas_from_es(params, type)
    name = params['name']
    tenant = Tenant.find(params['tenant']).name
    subscription = Subscription.find(params['subscription']).name
    blueprint = Blueprint.find(params['blueprint']).name
    id = nil
    case type
    when 's3'
      id = [name,tenant,subscription,blueprint,"S3"].join(".")
    when 'rds'
      id = [name,tenant,subscription,blueprint,"RDS"].join(".")
    when 'elb'
      id = [name,tenant,subscription,blueprint,"LoadBalancer"].join(".")
    when 'asg'
      id = [name+"ASGroup",tenant,subscription,blueprint,"AutoScalingGroup"].join(".")
    else
      puts "wrong paas service type sent\nCannot progress delete"
    end
    type = "#{type}_monitoring"
    res = @client.delete index: ELASTICSEARCH_SERVER['admin_index'], type: type, id: id unless id.nil?
    puts res
  end

  def asg(params)

    name = params['name']
    tenant = Tenant.find(params['tenant']).name || ""
    subscription = Subscription.find(params['subscription']).name || ""
    blueprint = Blueprint.find(params['blueprint']).name || ""
    index = params['account'].index('::') || ""
    account = params['account'][index+2..index+13] || ""
    region = params['region'] || ""
    time = Time.now.strftime("%Y-%m-%dT%H:%M:%S") || ""
    availability ||= ""
    availability_interval ||= ""
    if params['metrics']['Service-Availability']
      availability = 'OFF' if params['metrics']['Service-Availability']['asg']['enabled']
      availability_interval = params['metrics']['Service-Availability']['asg']['refresh-interval']
    end

    logs = ""#params['metrics']['Log-Monitoring'].keys.join(" ") if !params['metrics']['Log-Monitoring'].nil?
    logs_interval = ""#params['refresh_interval']
    service = "AutoScalingGroup" || ""
    metrics = Array.new
    metrics_interval ||= ""
    if params['metrics']['Service-Metrics']
      params['metrics']['Service-Metrics']['asg']['output-format'].each do |key|
        metrics << key.keys
      end
      metrics_interval = params['metrics']['Service-Metrics']['asg']['refresh-interval'] || ""
    end
    metrics = metrics.flatten.join(" ") || ""
    asg_identifier = params['asg_identifier'] || ""

    res = @client.index index: ELASTICSEARCH_SERVER['admin_index'], type: "asg_monitoring", id: [name,tenant,subscription,blueprint,service].join("."),
    body: {
      Account: account,
      Region: region,
      Tenant: tenant,
      Subscription: subscription,
      Blueprint: blueprint,
      Metrics: metrics,
      Availability: availability,
      Logs: logs,
      Name: name,
      Service: service,
      Metrics_interval: metrics_interval,
      Availability_interval: availability_interval,
      Logs_interval: logs_interval,
      Time: time,
      Asg_identifier: asg_identifier
    }

    puts res
  end

  def s3(params)

    name = params['name'] || ""
    tenant = Tenant.find(params['tenant']).name || ""
    subscription = Subscription.find(params['subscription']).name || ""
    blueprint = Blueprint.find(params['blueprint']).name || ""
    index = params['account'].index('::') || ""
    account = params['account'][index+2..index+13] || ""
    region = params['region'] || ""
    time = Time.now.strftime("%Y-%m-%dT%H:%M:%S") || ""
    availability = ""
    availability_interval = ""
    if params['metrics']['Service-Availability']
      availability = 'OFF' if params['metrics']['Service-Availability']['s3']['enabled'] || ""
      availability_interval = params['metrics']['Service-Availability']['s3']['refresh-interval'] || ""
    end


    # logs = params['metrics']['Service-Logs']['path']
    logs = ""
    logs_interval = ""
    if params['metrics']['Service-Logs']
      bucket = params["s3_log_location"]
      prefix = params["s3_log_prefix"]
      logs = bucket + "/" + prefix || ""
      logs_interval = params['metrics']['Service-Logs']['s3']['refresh-interval'] || ""
    end

    metrics = Array.new
    metrics_interval = ""
    if params['metrics']['Service-Metrics']
      params['metrics']['Service-Metrics']['s3']['output-format'].each do |key|
        metrics << key.keys
      end
      metrics_interval = params['metrics']['Service-Metrics']['s3']['refresh-interval'] || ""
    end
    metrics = metrics.flatten.join(" ") || ""
    service = "S3" || ""
    res = @client.index index: ELASTICSEARCH_SERVER['admin_index'], type: "s3_monitoring", id: [name,tenant,subscription,blueprint,service].join("."),
    body: {
      Account: account,
      Region: region,
      Tenant: tenant,
      Subscription: subscription,
      Blueprint: blueprint,
      Metrics: metrics,
      Availability: availability,
      Logs: logs,
      Name: name,
      Service: service,
      Metrics_interval: metrics_interval,
      Availability_interval: availability_interval,
      Logs_interval: logs_interval,
      Time: time
    }

    puts res

  end

  def rds(params)

    name = params['name'] || ""
    tenant = Tenant.find(params['tenant']).name || ""
    subscription = Subscription.find(params['subscription']).name || ""
    blueprint = Blueprint.find(params['blueprint']).name || ""
    index = params['account'].index('::')
    account = params['account'][index+2..index+13] || ""
    region = params['region'] || ""
    time = Time.now.strftime("%Y-%m-%dT%H:%M:%S") || ""
    availability = ""
    availability_interval = ""
    if params['metrics']['Service-Availability']
      availability = 'OFF' if params['metrics']['Service-Availability']['rds']['enabled'] || ""
      availability_interval = params['metrics']['Service-Availability']['rds']['refresh-interval'] || ""
    end

    # logs = Array.new
    # params['metrics']['Service-Logs']['rds']['logfiles'].each do |value|
    #   logs << value.values
    # end
    # logs = logs.flatten.join(" ")
    logs  ||= ""
    logs_interval = ""
    rds_engine = params["rds_engine"]
    if params['metrics']['Service-Logs']
      if rds_engine.downcase == "mysql"
        logs =" mysqlUpgrade  error/mysql-error.log"
      elsif rds_engine.downcase == "oracle-se"
        logs = "trace/alert_ORCL.log"
      elsif rds_engine.downcase == "sqlserver-se"|| rds_engine.downcase == "sqlserver-ee"
        logs = "log/ERRORlog/SQLAGENT.OUT"
      end
      logs_interval = params['metrics']['Service-Logs']['rds']['refresh-interval']  || ""
    end

    metrics = Array.new
    metrics_interval = ""
    if params['metrics']['Service-Metrics']
      params['metrics']['Service-Metrics']['rds']['output-format'].each do |key|
        metrics << key.keys
      end
      metrics_interval = params['metrics']['Service-Metrics']['rds']['refresh-interval'] || ""
    end
    metrics = metrics.flatten.join(" ") || ""

    endpoint = params['endpoint'] || ""
    service = "RDS" || ""
    db_identifier = params["db_identifier"] || ""

    res = @client.index index: ELASTICSEARCH_SERVER['admin_index'], type: "rds_monitoring", id: [name,tenant,subscription,blueprint,service].join("."),
    body: {
      Account: account,
      Region: region,
      Tenant: tenant,
      Subscription: subscription,
      Blueprint: blueprint,
      Metrics: metrics,
      Availability: availability,
      Logs: logs,
      Name: name,
      Service: service,
      Metrics_interval: metrics_interval,
      Availability_interval: availability_interval,
      Logs_interval: logs_interval,
      Time: time,
      Endpoint: endpoint,
      Engine: rds_engine,
      Db_identifier: db_identifier
    }

    puts res

  end

  def elb(params)


    name = params['name'] || ""
    tenant = Tenant.find(params['tenant']).name || ""
    subscription = Subscription.find(params['subscription']).name || ""
    blueprint = Blueprint.find(params['blueprint']).name || ""
    index = params['account'].index('::')
    account = params['account'][index+2..index+13] || ""
    region = params['region'] || ""
    time = Time.now.strftime("%Y-%m-%dT%H:%M:%S") || ""
    availability = ""
    availability_interval = ""
    if params['metrics']['Service-Availability']
      availability = 'OFF' if params['metrics']['Service-Availability']['elb']['enabled'] || ""
      availability_interval = params['metrics']['Service-Availability']['elb']['refresh-interval'] || ""
    end
    logs ||= ""
    logs_interval = ""
    if params['metrics']['Service-Logs']
      bucket = params['s3_log_location']
      prefix = params['s3_log_prefix']
      if prefix.nil? && !bucket.nil?
        logs = "s3://"+bucket.to_s+"/AWSLogs/"+account+"/elasticloadbalancing/"+region+"/"
      else
        logs = "s3://"+bucket.to_s+"/#{prefix}"+"/AWSLogs/"+account+"/elasticloadbalancing/"+region+"/"
      end

      logs_interval = params['metrics']['Service-Logs']['elb']['refresh-interval'] || ""
    end
    dns_name = params["dns_name"] || ""
    metrics = Array.new
    metrics_interval = ""
    if params['metrics']['Service-Metrics']
      metrics_interval = params['refresh_interval'] || ""
      metrics_keys = params['metrics']['Service-Metrics']['elb'].keys if !params['metrics']['Service-Metrics'].nil?
      metrics_keys.each do |key|
        params['metrics']['Service-Metrics']['elb'][key]['output-format'].each do |inner_hash|
          metrics << inner_hash.keys
        end
      end
    end

    metrics = metrics.flatten.join(" ") || ""
    service = "LoadBalancer" || ""
    elb_identifier = params['elb_identifier'] || ""
    res = @client.index index: ELASTICSEARCH_SERVER['admin_index'], type: "elb_monitoring", id: [name,tenant,subscription,blueprint,service].join("."),
    body: {
      Account: account,
      Region: region,
      Tenant: tenant,
      Subscription: subscription,
      Blueprint: blueprint,
      Metrics: metrics,
      Availability: availability,
      Logs: logs,
      Name: name,
      Service: service,
      Metrics_interval: metrics_interval,
      Availability_interval: availability_interval,
      Logs_interval: logs_interval,
      Time: time,
      Dns: dns_name,
      Elb_identifier: elb_identifier
    }

    puts res

  end


  # def check_remote_file_exists(resourse_dir,filename)
  #   Net::SSH.start(
  #     self.host, self.username, :keys => self.keys
  #   ) do |session|
  #     res = session.exec!("[ -f #{self.path}/#{resourse_dir}/#{filename} ] && echo 'true' || echo 'false'").to_bool
  #     res
  #   end
  # end

  # def check_remote_dir_exists(resourse_dir)
  #   Net::SSH.start(
  #     self.host, self.username, :keys => self.keys
  #   ) do |session|
  #     res = session.exec!("[ -d #{self.path}/#{resourse_dir} ] && echo 'true' || echo 'false'").to_bool
  #     res
  #   end
  # end

  # def create_empty_remote_file(resourse_dir,filename)
  #   Net::SSH.start(
  #     self.host, self.username, :keys => self.keys
  #   ) do |session|
  #     res = session.exec!("touch #{self.path}/#{resourse_dir}/#{filename}")
  #   end
  # end

  # def create_remote_dir(resourse_dir)
  #   Net::SSH.start(
  #     self.host, self.username, :keys => self.keys
  #   ) do |session|
  #     res = session.exec!("mkdir -p #{self.path}/#{resourse_dir}")
  #   end
  # end

  # def grep_remote_file(resourse_dir,filename,tempTSBString)
  #   Net::SSH.start(
  #     self.host, self.username, :keys => self.keys
  #   ) do |session|
  #     grep = session.exec!("cat #{self.path}/#{resourse_dir}/#{filename}|grep '#{tempTSBString}'")
  #   end
  # end

  # def write_remote_file(resourse_dir,filename,file_content)
  #   Net::SSH.start(
  #     self.host, self.username, :keys => self.keys
  #   ) do |session|
  #     session.exec!("echo '#{file_content}' >> #{self.path}/#{resourse_dir}/#{filename}")
  #   end
  # end

  def write_audit_log_input(params)
    index = params[:account].index('::')
    account = params[:account][index+2..index+13]
    s3_bucket = params[:log_location] + "/" + params[:log_prefix]
    res = @client.index index: ELASTICSEARCH_SERVER['admin_index'], type: "audit_trail_logs",
    body: {
      Account: account,
      S3: s3_bucket
    }
    puts res
    # create_remote_dir('audittrail') unless check_remote_dir_exists('audittrail')
    # create_empty_remote_file('audittrail','audit_log_input.txt') unless check_remote_file_exists('audittrail','audit_log_input.txt')
    # fileData = "#{params['number']} #{params['s3_bucket']}"
    # grep = grep_remote_file('audittrail','audit_log_input.txt',fileData)
    # if grep.empty?
    #   write_remote_file('audittrail','audit_log_input.txt',fileData)
    # end

  end


end
