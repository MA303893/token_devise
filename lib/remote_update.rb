require 'net/ssh'
require 'elasticsearch'

class String
  def to_bool
    return true if self == true || self =~ (/^(true|t|yes|y|1)$/i)
    return false if self == false || self =~ (/^(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end

class Remote_edit

  attr_reader :path, :host, :username, :keys

  def initialize
    @path = LOGSTASH_PRODUCER["path"]
    @host = LOGSTASH_PRODUCER["ip"] #enter remote ip of logstash producer here
    @username = LOGSTASH_PRODUCER["username"]
    @keys = LOGSTASH_PRODUCER["keys_path"] # enter key path here
    @client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]
  end

  def asg(params)
    if !@client.indices.exists_type index: ELASTICSEARCH_SERVER['admin_index'], type: "asg_monitoring"
      res = @client.indices.put_mapping index: ELASTICSEARCH_SERVER['admin_index'], type: 'asg_monitoring', body: {
        asg_monitoring: {
          properties: {
            Account: { type: "string", index: "not_analyzed" },
            Region: { type: "string", index: "not_analyzed" },
            Tenant: { type: "string", index: "not_analyzed" },
            Subscription: { type: "string", index: "not_analyzed" },
            Blueprint: { type: "string", index: "not_analyzed" },
            Metrics: { type: "string", index: "not_analyzed" },
            Availability: { type: "string", index: "not_analyzed" },
            Logs: { type: "string", index: "not_analyzed" },
            Name: { type: "string", index: "not_analyzed" },
            Service: { type: "string", index: "not_analyzed" },
            Metrics_interval: { type: "string", index: "not_analyzed" },
            Availability_interval: { type: "string", index: "not_analyzed" },
            Logs_interval: { type: "string", index: "not_analyzed" },
            Time: { type: "string", index: "not_analyzed" }

          }
        }
      }
      puts res
    else
      name = params['name']
      tenant = Tenant.find(params['tenant']).name
      subscription = Subscription.find(params['subscription']).name
      blueprint = Blueprint.find(params['blueprint']).name
      index = params['account'].index('::')
      account = params['account'][index+2..index+13]
      region = params['region']
      time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      availability = 'OFF' if params['metrics']['Service-Availability']['asg']['enabled']
      availability_interval = params['metrics']['Service-Availability']['asg']['refresh-interval']
      logs = nil#params['metrics']['Log-Monitoring'].keys.join(" ") if !params['metrics']['Log-Monitoring'].nil?
      logs_interval = nil#params['refresh_interval']
      service = "AutoScalingGroup"
      # metrics_keys = params['metrics']['Service-Metrics'].keys if !params['metrics']['Service-Metrics'].nil?
      metrics = Array.new
      params['metrics']['Service-Metrics']['asg']['output-format'].each do |key|
        metrics << key.keys
      end
      metrics_interval = params['metrics']['Service-Metrics']['asg']['refresh_interval']
      # metrics_keys.each do |key|
      #   params['metrics']['Infrastructure-Metrics'][key]['output-format'].each do |inner_hash|
      #     metrics << inner_hash.keys
      #   end
      #   metrics_interval = params['metrics']['Infrastructure-Metrics'][key]['refresh-interval']
      # end
      metrics = metrics.flatten.join(" ")


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
        Time: time
      }

      puts res

    end
  end

  def s3(params)
    if !@client.indices.exists_type index: ELASTICSEARCH_SERVER['admin_index'], type: "s3_monitoring"
      puts "dsdsdsdsds"
      res = @client.indices.put_mapping index: ELASTICSEARCH_SERVER['admin_index'], type: 's3_monitoring', body: {
        s3_monitoring: {
          properties: {
            Account: { type: "string", index: "not_analyzed" },
            Region: { type: "string", index: "not_analyzed" },
            Tenant: { type: "string", index: "not_analyzed" },
            Subscription: { type: "string", index: "not_analyzed" },
            Blueprint: { type: "string", index: "not_analyzed" },
            Metrics: { type: "string", index: "not_analyzed" },
            Availability: { type: "string", index: "not_analyzed" },
            Logs: { type: "string", index: "not_analyzed" },
            Name: { type: "string", index: "not_analyzed" },
            Service: { type: "string", index: "not_analyzed" },
            Metrics_interval: { type: "string", index: "not_analyzed" },
            Availability_interval: { type: "string", index: "not_analyzed" },
            Logs_interval: { type: "string", index: "not_analyzed" },
            Time: { type: "string", index: "not_analyzed" }


          }
        }
      }
      puts res
    else
      name = params['name']
      tenant = Tenant.find(params['tenant']).name
      subscription = Subscription.find(params['subscription']).name
      blueprint = Blueprint.find(params['blueprint']).name
      index = params['account'].index('::')
      account = params['account'][index+2..index+13]
      region = params['region']
      time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      availability = 'OFF' if params['metrics']['Service-Availability']['s3']['enabled']
      availability_interval = params['metrics']['Service-Availability']['s3']['refresh-interval']
      logs = params['metrics']['Service-Logs']['path']
      logs_interval = params['metrics']['Service-Logs']['refresh-interval']
      metrics = Array.new
      params['metrics']['Service-Metrics']['s3']['output-format'].each do |key|
        metrics << key.keys
      end
      metrics = metrics.flatten.join(" ")
      metrics_interval = params['metrics']['Service-Metrics']['s3']['refresh-interval']
      service = "S3"
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
  end

  def rds(params)
    if !@client.indices.exists_type index: ELASTICSEARCH_SERVER['admin_index'], type: "rds_monitoring"
      # puts "dsdsdsdsds"
      res = @client.indices.put_mapping index: ELASTICSEARCH_SERVER['admin_index'], type: 'rds_monitoring', body: {
        rds_monitoring: {
          properties: {
            Account: { type: "string", index: "not_analyzed" },
            Region: { type: "string", index: "not_analyzed" },
            Tenant: { type: "string", index: "not_analyzed" },
            Subscription: { type: "string", index: "not_analyzed" },
            Blueprint: { type: "string", index: "not_analyzed" },
            Metrics: { type: "string", index: "not_analyzed" },
            Availability: { type: "string", index: "not_analyzed" },
            Logs: { type: "string", index: "not_analyzed" },
            Name: { type: "string", index: "not_analyzed" },
            Service: { type: "string", index: "not_analyzed" },
            Metrics_interval: { type: "string", index: "not_analyzed" },
            Availability_interval: { type: "string", index: "not_analyzed" },
            Logs_interval: { type: "string", index: "not_analyzed" },
            Time: { type: "string", index: "not_analyzed" },
            Endpoint: { type: "string", index: "not_analyzed" }

          }
        }
      }
      puts res
    else
      name = params['name']
      tenant = Tenant.find(params['tenant']).name
      subscription = Subscription.find(params['subscription']).name
      blueprint = Blueprint.find(params['blueprint']).name
      index = params['account'].index('::')
      account = params['account'][index+2..index+13]
      region = params['region']
      time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      availability = 'OFF' if params['metrics']['Service-Availability']['rds']['enabled']
      availability_interval = params['metrics']['Service-Availability']['rds']['refresh-interval']
      logs = Array.new
      params['metrics']['Service-Logs']['rds']['logfiles'].each do |value|
        logs << value.values
      end
      logs = logs.flatten.join(" ")
      logs_interval = params['metrics']['Service-Logs']['rds']['refresh-interval']
      metrics = Array.new
      params['metrics']['Service-Metrics']['rds']['output-format'].each do |key|
        metrics << key.keys
      end
      metrics = metrics.flatten.join(" ")
      metrics_interval = params['metrics']['Service-Metrics']['rds']['refresh_interval']
      endpoint = params['endpoint']
      service = "RDS"
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
        Endpoint: endpoint
      }

      puts res

    end
  end

  def elb(params)
    if !@client.indices.exists_type index: ELASTICSEARCH_SERVER['admin_index'], type: "elb_monitoring"
      puts "dsdsdsdsds"
      res = @client.indices.put_mapping index: ELASTICSEARCH_SERVER['admin_index'], type: 'elb_monitoring', body: {
        elb_monitoring: {
          properties: {
            Account: { type: "string", index: "not_analyzed" },
            Region: { type: "string", index: "not_analyzed" },
            Tenant: { type: "string", index: "not_analyzed" },
            Subscription: { type: "string", index: "not_analyzed" },
            Blueprint: { type: "string", index: "not_analyzed" },
            Metrics: { type: "string", index: "not_analyzed" },
            Availability: { type: "string", index: "not_analyzed" },
            Logs: { type: "string", index: "not_analyzed" },
            Name: { type: "string", index: "not_analyzed" },
            Service: { type: "string", index: "not_analyzed" },
            Metrics_interval: { type: "string", index: "not_analyzed" },
            Availability_interval: { type: "string", index: "not_analyzed" },
            Logs_interval: { type: "string", index: "not_analyzed" },
            Time: { type: "string", index: "not_analyzed" }

          }
        }
      }
      puts res

    else

      name = params['name']
      tenant = Tenant.find(params['tenant']).name
      subscription = Subscription.find(params['subscription']).name
      blueprint = Blueprint.find(params['blueprint']).name
      index = params['account'].index('::')
      account = params['account'][index+2..index+13]
      region = params['region']
      time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      availability = 'OFF' if params['metrics']['Service-Availability']['enabled']
      availability_interval = params['metrics']['Service-Availability']['refresh-interval']
      logs = params['metrics']['Service-Logs']['path']
      logs_interval = params['metrics']['Service-Logs']['refresh-interval']

      metrics = Array.new
      metrics_interval = params['refresh_interval']
      metrics_keys = params['metrics']['Service-Metrics'].keys if !params['metrics']['Service-Metrics'].nil?
      metrics_keys.each do |key|
        params['metrics']['Service-Metrics'][key]['output-format'].each do |inner_hash|
          metrics << inner_hash.keys
        end
      end
      metrics = metrics.flatten.join(" ")
      service = "LoadBalancer"
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
        Time: time
      }

      puts res

    end
  end


  def check_remote_file_exists(resourse_dir,filename)
    Net::SSH.start(
      self.host, self.username, :keys => self.keys
    ) do |session|
      res = session.exec!("[ -f #{self.path}/#{resourse_dir}/#{filename} ] && echo 'true' || echo 'false'").to_bool
      res
    end
  end

  def check_remote_dir_exists(resourse_dir)
    Net::SSH.start(
      self.host, self.username, :keys => self.keys
    ) do |session|
      res = session.exec!("[ -d #{self.path}/#{resourse_dir} ] && echo 'true' || echo 'false'").to_bool
      res
    end
  end

  def create_empty_remote_file(resourse_dir,filename)
    Net::SSH.start(
      self.host, self.username, :keys => self.keys
    ) do |session|
      res = session.exec!("touch #{self.path}/#{resourse_dir}/#{filename}")
    end
  end

  def create_remote_dir(resourse_dir)
    Net::SSH.start(
      self.host, self.username, :keys => self.keys
    ) do |session|
      res = session.exec!("mkdir -p #{self.path}/#{resourse_dir}")
    end
  end

  def grep_remote_file(resourse_dir,filename,tempTSBString)
    Net::SSH.start(
      self.host, self.username, :keys => self.keys
    ) do |session|
      grep = session.exec!("cat #{self.path}/#{resourse_dir}/#{filename}|grep '#{tempTSBString}'")
    end
  end

  def write_remote_file(resourse_dir,filename,file_content)
    Net::SSH.start(
      self.host, self.username, :keys => self.keys
    ) do |session|
      session.exec!("echo '#{file_content}' >> #{self.path}/#{resourse_dir}/#{filename}")
    end
  end

  def write_audit_log_input(params)
    create_remote_dir('audittrail') unless check_remote_dir_exists('audittrail')
    create_empty_remote_file('audittrail','audit_log_input.txt') unless check_remote_file_exists('audittrail','audit_log_input.txt')
    fileData = "#{params['number']} #{params['s3_bucket']}"
    grep = grep_remote_file('audittrail','audit_log_input.txt',fileData)
    if grep.empty?
      write_remote_file('audittrail','audit_log_input.txt',fileData)
    end
  end

  def write_s3(params)
    create_remote_dir('s3') unless check_remote_dir_exists('s3')
    create_empty_remote_file('s3','s3_monitoring.txt') unless check_remote_file_exists('s3','s3_monitoring.txt')
    create_empty_remote_file('s3','s3_logs.txt') unless check_remote_file_exists('s3','s3_logs.txt')
    tempTSBString = "#{params[:s3][:account]} #{params[:s3][:region]} #{params[:s3][:tenant]} #{params[:s3][:subscription]} #{params[:s3][:blueprint]}"
    grep = grep_remote_file('s3','s3_monitoring.txt',tempTSBString)
    time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    if grep.empty?
      puts "writing s3_monitoring.txt"
      file_content = "#{tempTSBString} S3 #{params[:s3][:name]} #{params[:s3][:refresh_interval]} #{time} #{params[:s3][:metrics].join(" ")}"
      file_content += "\n#{tempTSBString} S3 #{params[:s3][:name]} #{params[:s3][:refresh_interval]} #{time} availability OFF"
      write_remote_file('s3','s3_monitoring.txt',file_content)
    end

    grep = grep_remote_file('s3','s3_logs.txt',tempTSBString)
    if grep.empty?
      puts "writing s3_logs.txt"

      file_content = "#{tempTSBString} S3 #{params[:s3][:name]} #{params[:s3][:refresh_interval]} logs #{params[:s3][:target_bucket]}/#{params[:s3][:target_prefix]}"

      write_remote_file('s3','s3_logs.txt',file_content)
    end
  end

  def write_asg(params)
    create_remote_dir('autoscaling') unless check_remote_dir_exists('autoscaling')
    create_empty_remote_file('autoscaling','as_monitoring.txt') unless check_remote_file_exists('autoscaling','as_monitoring.txt')

    tempTSBString = "#{params[:autoscaling][:account]} #{params[:autoscaling][:region]} #{params[:autoscaling][:tenant]} #{params[:autoscaling][:subscription]} #{params[:autoscaling][:blueprint]}"
    grep = grep_remote_file('autoscaling','as_monitoring.txt',tempTSBString)
    time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    if grep.empty?
      puts "writing as_monitoring.txt"
      file_content = "#{tempTSBString} S3 #{params[:autoscaling][:name]} #{params[:autoscaling][:refresh_interval]} #{time} #{params[:autoscaling][:metrics].join(" ")}"
      file_content += "\n#{tempTSBString} AutoScalingGroup #{params[:autoscaling][:name]} #{params[:autoscaling][:refresh_interval]} #{time} availability OFF"
      write_remote_file('autoscaling','as_monitoring.txt',file_content)
    end
  end

  def write_elb(params)
    create_remote_dir('loadbalancer') unless check_remote_dir_exists('loadbalancer')
    create_empty_remote_file('loadbalancer','lb_monitoring.txt') unless check_remote_file_exists('loadbalancer','lb_monitoring.txt')
    create_empty_remote_file('loadbalancer','lb_logs.txt') unless check_remote_file_exists('loadbalancer','lb_logs.txt')
    tempTSBString = "#{params[:elb][:account]} #{params[:elb][:region]} #{params[:elb][:tenant]} #{params[:elb][:subscription]} #{params[:elb][:blueprint]}"
    grep = grep_remote_file('loadbalancer','lb_monitoring.txt',tempTSBString)
    time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    if grep.empty?
      puts "writing lb_monitoring.txt"
      file_content = "#{tempTSBString} URL #{params[:elb][:dns_name]} #{params[:elb][:refresh_interval]} #{time} availability OFF"
      file_content += "\n#{tempTSBString} LoadBalancer #{params[:elb][:name]} #{params[:elb][:refresh_interval]} #{time} availability OFF"
      file_content += "\n#{tempTSBString} LoadBalancer #{params[:elb][:name]} #{params[:elb][:refresh_interval]} #{time} #{params[:elb][:metrics].join(" ")}"
      write_remote_file('loadbalancer','lb_monitoring.txt',file_content)
    end
    grep = grep_remote_file('loadbalancer','lb_logs.txt',tempTSBString)
    if grep.empty?
      puts "writing lb_logs.txt"
      file_content =""
      file_content = "#{tempTSBString} LoadBalancer #{params[:elb][:name]} #{params[:elb][:refresh_interval]} #{time} logs s3://#{params[:elb][:s3_bucket]}/AWSLogs/#{params[:elb][:account]}/elasticloadbalancing/#{params[:elb][:region]}/"
      write_remote_file('loadbalancer','lb_logs.txt',file_content)
    end
  end

  def write_rds(params)

    create_remote_dir('rds') unless check_remote_dir_exists('rds')
    create_empty_remote_file('rds','rds_monitoring.txt') unless check_remote_file_exists('rds','rds_monitoring.txt')
    create_empty_remote_file('rds','rds_logs.txt') unless check_remote_file_exists('rds','rds_logs.txt')
    tempTSBString = "#{params[:rds][:account]} #{params[:rds][:region]} #{params[:rds][:tenant]} #{params[:rds][:subscription]} #{params[:rds][:blueprint]}"
    grep = grep_remote_file('rds','rds_monitoring.txt',tempTSBString)
    time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    if grep.empty?
      puts "writing rds_monitoring.txt"
      file_content = "#{tempTSBString} RDS #{params[:rds][:name]} #{params[:rds][:endpoint]} #{params[:rds][:refresh_interval]} #{time} #{params[:rds][:metrics].join(" ")}"
      file_content += "\n{tempTSBString} RDS #{params[:rds][:name]} #{params[:rds][:endpoint]} #{params[:rds][:refresh_interval]} availability OFF"
      write_remote_file('rds','rds_monitoring.txt',file_content)
    end
    grep = grep_remote_file('rds','rds_logs.txt',tempTSBString)
    if grep.empty?
      puts "writing rds_logs.txt"
      file_content = ''
      if params[:rds][:rds_engine] == "mysql"
        file_content = "#{tempTSBString} RDS #{params[:rds][:name]} #{params[:rds][:endpoint]} #{params[:rds][:refresh_interval]} #{time} mysqlUpgrade"
        file_content += "\n#{tempTSBString} RDS #{params[:rds][:name]} #{params[:rds][:endpoint]} #{params[:rds][:refresh_interval]} #{time} error/mysql-error.log"
      elsif params[:rds][:rds_engine] == "oracle-se"
        file_content = "#{tempTSBString} RDS #{params[:rds][:name]} #{params[:rds][:endpoint]} #{params[:rds][:refresh_interval]} #{time} trace/alert_ORCL.log"
      elsif params[:rds][:rds_engine] == "sqlserver-se"
        file_content = "#{tempTSBString} RDS #{params[:rds][:name]} #{params[:rds][:endpoint]} #{params[:rds][:refresh_interval]} log/ERROR"
        file_content += "\n#{tempTSBString} RDS #{params[:rds][:name]} #{params[:rds][:endpoint]} #{params[:rds][:refresh_interval]} #{time} log/SQLAGENT.OUT"
      end
      write_remote_file('rds','rds_logs.txt',file_content)
    end

  end


end
