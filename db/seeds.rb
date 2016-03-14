# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'elasticsearch'
client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]
if !client.indices.exists_type index: ELASTICSEARCH_SERVER['admin_index'], type: "audit_trail_logs"
  res = client.indices.put_mapping index: ELASTICSEARCH_SERVER['admin_index'], type: "audit_trail_logs", body: {
    audit_trail_logs:{
      properties: {
        Account: { type: "string", index: "not_analyzed" },
        #Region: { type: "string", index: "not_analyzed" },
        S3: { type: "string", index: "not_analyzed" }
      }
    }
  }
  puts res
  puts "created audit_trail_logs"
end
if !client.indices.exists_type index: ELASTICSEARCH_SERVER['admin_index'], type: "asg_monitoring"
  res = client.indices.put_mapping index: ELASTICSEARCH_SERVER['admin_index'], type: 'asg_monitoring', body: {
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
        Time: { type: "date", format: "dateOptionalTime" },
        Asg_identifier: { type: "date", format: "dateOptionalTime" }

      }
    }
  }
  puts res
  puts "created asg_monitoring"
end

if !client.indices.exists_type index: ELASTICSEARCH_SERVER['admin_index'], type: "s3_monitoring"
  # puts "dsdsdsdsds"
  res = client.indices.put_mapping index: ELASTICSEARCH_SERVER['admin_index'], type: 's3_monitoring', body: {
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
        Time: { type: "date", format: "dateOptionalTime" }


      }
    }
  }
  puts res
  puts "s3_monitoring"
end
if !client.indices.exists_type index: ELASTICSEARCH_SERVER['admin_index'], type: "rds_monitoring"
  # puts "dsdsdsdsds"
  res = client.indices.put_mapping index: ELASTICSEARCH_SERVER['admin_index'], type: 'rds_monitoring', body: {
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
        Time: { type: "date", format: "dateOptionalTime" },
        Endpoint: { type: "string", index: "not_analyzed" },
        Db_identifier: { type: "string", index: "not_analyzed" }

      }
    }
  }
  puts res
  puts "rds_monitoring"
end

if !client.indices.exists_type index: ELASTICSEARCH_SERVER['admin_index'], type: "elb_monitoring"
  # puts "dsdsdsdsds"
  res = client.indices.put_mapping index: ELASTICSEARCH_SERVER['admin_index'], type: 'elb_monitoring', body: {
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
        Time: { type: "date", format: "dateOptionalTime" },
        Dns: {type: "string", index: "not_analyzed"},
        Elb_identifier: {type: "string", index: "not_analyzed"}

      }
    }
  }
  puts res
  puts "elb_monitoring"
end
if !User.find_by_username("admin")
  u=User.new(:username => "admin", :firstname => "Admin", :email => "admin@wipro.com", :password => "D1g1taLHu6", :password_confirmation => "D1g1taLHu6") rescue User.find_by_username('admin')
  u.save!(validate: false)
  u.save(validate: false)
  puts "created admin user"
end
