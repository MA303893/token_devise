
ELASTICSEARCH_SERVER = {
  "ip" => "internal-elasticsearch-1610824972.us-east-1.elb.amazonaws.com",
  "port" => "9200",
  "shards" => "2",
  "replicas" => "2",
  "admin_index" => "admin"
}

LOGSTASH_SERVER = {
  "ip" => "10.220.2.121",
  "server_path_download" => "/etc/logstash/conf.d/agent.conf",
  "rails_path_download" => Rails.root.to_s,
  "server_path_upload" => "/etc/logstash/conf.d/",
  "rails_path_upload" => Rails.root.to_s+"/agent.conf",
  "username" => "root",
  "keys_path" => Rails.root.to_s+"/VS_Key.pem"
}

LOGSTASH_PRODUCER = {
  "ip" => "10.220.2.219",
  "path" => '/dsh/application/logstash-1.5.0/logstash-plugins',  
  "username" => "root",
  "keys_path" => "{Rails.root.to_s}/VS_Key.pem",
  "aws_config_path" => "/root"

}
