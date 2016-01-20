
ELASTICSEARCH_SERVER = {
  "ip" => "10.220.3.40",
  "port" => "9200",
  "shards" => "2",
  "replicas" => "2",
  "admin_index" => "stupid_admin"
}

LOGSTASH_SERVER = {
  "ip" => "10.220.2.121",
  "server_path_download" => "/dsh/application/logstash-1.5.0/conf/agent.conf",
  "rails_path_download" => "/dsh/application/rails/",
  "server_path_upload" => "/dsh/application/logstash-1.5.0/conf",
  "rails_path_upload" => "/dsh/application/rails/agent.conf",
  "username" => "root",
  "keys_path" => "/dsh/application/rails/VS_Key.pem"
}
