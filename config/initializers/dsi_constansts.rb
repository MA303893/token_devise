
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
  "rails_path_download" => "/dsh/application/rails/",
  "server_path_upload" => "/etc/logstash/conf.d/",
  "rails_path_upload" => "/dsh/application/rails/agent.conf",
  "username" => "root",
  "keys_path" => "/dsh/application/rails/VS_Key.pem"
}
