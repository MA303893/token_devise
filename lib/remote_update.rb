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


end
