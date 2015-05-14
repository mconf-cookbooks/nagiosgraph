#
# Cookbook Name:: nagiosgraph
# Recipe:: default
# Author:: Felipe Cecagno (<felipe@mconf.org>)
#
# This file is part of the Mconf project.
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

%w{ subversion libcgi-pm-perl librrds-perl libgd-gd2-perl }.each do |pkg|
    package pkg do
        action :install
    end
end

subversion "/usr/local/src/nagiosgraph" do
    repository "https://svn.code.sf.net/p/nagiosgraph/code/trunk/nagiosgraph"
    revision "578"
    action :sync
    notifies :run, "execute[nagiosgraph check prerequisites]", :immediately
end

execute "nagiosgraph check prerequisites" do
    cwd "/usr/local/src/nagiosgraph"
    command "./install.pl --check-prereq"
    action :nothing
end

bash "nagiosgraph compile and install" do
  cwd "/usr/local/src/nagiosgraph"
  code <<-EOH
    ./install.pl --layout debian
  EOH
  creates "/usr/lib/nagiosgraph"
end

# \TODO it shouldn't be done this way, use templates and attributes instead
%w{ datasetdb.conf labels.conf nagiosgraph.conf ngshared.pm rrdopts.conf }.each do |conf|
    cookbook_file "/etc/nagiosgraph/#{conf}" do
        source conf
        action :create
    end
end

include_recipe 'apache2'
apache_conf 'nagiosgraph' do
  source 'nagiosgraph-apache.conf.erb'
  enable true
end
