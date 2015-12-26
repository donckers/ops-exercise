mysql2_chef_gem 'default' do
    action :install
end

mysql_service 'wordpress' do
    version '5.5'
    initial_root_password node['wordpress']['db']['root_password']
    action [:create, :start]
end

mysql_connection_info = {
    :host     => "127.0.0.1",
    :port     => 3306,
    :username => 'root',
    :password => node['wordpress']['db']['root_password']
}

mysql_database node['wordpress']['db']['name'] do
    connection mysql_connection_info
    action :create
end

mysql_database_user node['wordpress']['db']['user'] do
    connection mysql_connection_info
    password node['wordpress']['db']['pass']
    database_name node['wordpress']['db']['name']
    host 'localhost'
    privileges [:select,:update,:insert,:create,:delete]
    action :grant
end
