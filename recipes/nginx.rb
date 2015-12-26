# Install nginx
package ['nginx', 'unzip']

service 'nginx' do
    action [ :enable, :start ]
end

# Install HHVM
include_recipe 'hhvm::default'

# Enable HHVM in nginx
ruby_block 'enable_hhvm_nginx' do
    block do
        file = Chef::Util::FileEdit.new('/etc/nginx/sites-available/default')
        file.insert_line_after_match('^\s*server_name.*$', '        include hhvm.conf;')
        file.write_file
    end
    not_if 'grep -q "include hhvm.conf;" /etc/nginx/sites-available/default'
    notifies :restart, 'service[nginx]', :delayed
end

# Enable index.php
ruby_block 'enable_index.php' do
    block do
        file = Chef::Util::FileEdit.new('/etc/nginx/sites-available/default')
        file.search_file_replace_line('^\s*index index.html index.htm;$', '        index index.php index.html index.htm;')
        file.write_file
    end
    not_if 'grep -q "index index.html index.htm index.php;" /etc/nginx/sites-available/default'
    notifies :restart, 'service[nginx]', :delayed
end

# This disables the nginx welcome page
ruby_block 'server_name' do
    block do
        file = Chef::Util::FileEdit.new('/etc/nginx/sites-available/default')
        file.search_file_replace_line('^\s*server_name localhost;$', '        server_name "";')
        file.write_file
    end
    not_if 'grep -q "server_name \"\";" /etc/nginx/sites-available/default'
    notifies :restart, 'service[nginx]', :delayed
end
