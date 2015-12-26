# Link /var/www to /usr/share/nginx
link '/var/www' do
    to '/usr/share/nginx'
end

# Install latest wordpress
tar_extract 'http://wordpress.org/latest.tar.gz' do
    target_dir '/var/www'
    creates '/var/www/wordpress'
end

execute "chown-www-data" do
    command "chown -R www-data:www-data /var/www/wordpress"
    user "root"
    action :run
    not_if "stat -c %U /var/www/wordpress | grep www-data"
end

template '/var/www/wordpress/wp-config.php' do
    source 'wp-config.php.erb'
    mode '0644'
    owner 'www-data'
    group 'www-data'
    variables({
        :db_name => node['wordpress']['db']['name'],
        :db_user => node['wordpress']['db']['user'],
        :db_pass => node['wordpress']['db']['pass'],
        :db_host => node['wordpress']['db']['host']
    })
end

ruby_block 'set_document_root' do
    block do
        file = Chef::Util::FileEdit.new('/etc/nginx/sites-available/default')
        file.search_file_replace_line('^\s*root /usr/share/nginx/html;$', '        root /var/www/wordpress;')
        file.write_file
    end
    not_if 'grep -q "root /var/www/wordpress;" /etc/nginx/sites-available/default'
    notifies :restart, 'service[nginx]', :delayed
end

