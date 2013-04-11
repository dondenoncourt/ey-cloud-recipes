#
# Cookbook Name:: solr
# Recipe:: default
#
 
require 'digest/sha1'
SOLR_VERSION = '4.2.0'
 
if node[:instance_role] == "app_master"
    node[:applications].each do |app,data|
     
      directory "/data/#{app}/jettyapps" do
        owner node[:owner_name]
        group node[:owner_name]
        mode 0755
        recursive true
      end
     
      directory "/var/run/solr" do
        owner node[:owner_name]
        group node[:owner_name]
        mode 0755
        recursive true
      end
     
      template "/engineyard/bin/solr" do
        source "solr.erb"
        owner node[:owner_name]
        group node[:owner_name]
        mode 0755
        variables({
          :rails_env => node[:environment][:framework_env],
          :app => app
        })
      end
     
      template "/etc/monit.d/solr.#{app}.monitrc" do
        source "solr.monitrc.erb"
        owner node[:owner_name]
        group node[:owner_name]
        mode 0644
        variables({
          :app => app,
          :user => node[:owner_name],
          :group => node[:owner_name]
        })
      end
     
      execute "install solr example package" do
        user node[:owner_nameun
        group node[:owner_name]
        command("if [ ! -e /data/#{app}/jettyapps/solr ]; then cd /data/#{app}/jettyapps && " +
                "wget -O solr-#{SOLR_VERSION}.tgz http://archive.apache.org/dist/lucene/solr/#{SOLR_VERSION}/solr-#{SOLR_VERSION}.tgz && " +
                "tar -xzf solr-#{SOLR_VERSION}.tgz && " +
                "mv solr-#{SOLR_VERSION}/example solr && " +
                "rm -rf solr-#{SOLR_VERSION}; fi")
        action :run
      end
     
      gem_package "sunspot_solr" do
        source "http://gemcutter.org"
        action :install
        ignore_failure true
      end
      
      gem_package "nokogiri" do
        source "http://gemcutter.org"
        ignore_failure true
        action :install
      end
     
      execute "install-sunspot-solr" do
        user node[:owner_name]
        group node[:owner_name]
        command "sunspot-installer -f /data/#{app}/jettyapps/solr/solr"
        action :run
      end
     
      #execute "copy VPSA custom schema.xml" do
        #user node[:owner_name]
        #group node[:owner_name]
        #command "cp /data/#{app}/current/solr/conf/* /data/#{app}/jettyapps/solr/solr/conf"
        #action :run
      #end
      
      execute "restart-monit-solr" do
        command "/usr/bin/monit reload && " +
                "/usr/bin/monit restart all -g solr"
        action :run
      end
     
    end
end
