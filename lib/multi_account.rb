require 'net/ssh'

class String
  def to_bool
    return true if self == true || self =~ (/^(true|t|yes|y|1)$/i)
    return false if self == false || self =~ (/^(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end

class Remote_edit_profile

  attr_reader :path, :host, :username, :keys

  def initialize
    @path = '/root'
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



  def update_remote_aws_config(param)
  	region = param[:region]
  	index = param[:arn].index('::')
  	account = param[:arn][index+2..index+13]
  	role_arn = param[:arn]
  	tempTSBString = "role_arn = #{role_arn}"
  	puts tempTSBString
    create_remote_dir('.aws') unless check_remote_dir_exists('.aws')
    create_empty_remote_file('.aws','config') unless check_remote_file_exists('.aws','config')    
    grep = grep_remote_file('.aws','config',tempTSBString)
    if grep.empty?
      puts "writing aws config"
      file_content = "[profile #{account}]\n#{tempTSBString}\nsource_profile = default\noutput = text\nregion = #{region}"
      write_remote_file('.aws','config',file_content)
    end
  end


end


#ob = Remote_edit_profile.new
#ob.update_remote_aws_config({region: 'us-east-1', arn: 'arn:aws:iam::278710931978:role/DSIRole'})