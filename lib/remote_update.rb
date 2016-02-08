require 'net/ssh'

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
    @path = '/dsh/application/logstash-1.5.0/logstash-plugins'
    @host = '10.220.0.62' #enter remote ip here
    @username = 'root'
    @keys = ["#{Rails.root}/VS_Key.pem"] # enter key path here
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
    fileData = "#{params['number']} #{params['region']} #{params['s3_bucket']}"
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

    tempTSBString = "#{params[:asg][:account]} #{params[:asg][:region]} #{params[:asg][:tenant]} #{params[:asg][:subscription]} #{params[:asg][:blueprint]}"
    grep = grep_remote_file('autoscaling','as_monitoring.txt',tempTSBString)
    time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    if grep.empty?
      puts "writing as_monitoring.txt"
      file_content = "#{tempTSBString} S3 #{params[:asg][:name]} #{params[:asg][:refresh_interval]} #{time} #{params[:asg][:metrics].join(" ")}"
      file_content += "\n#{tempTSBString} AutoScalingGroup #{params[:asg][:name]} #{params[:asg][:refresh_interval]} #{time} availability OFF"
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
