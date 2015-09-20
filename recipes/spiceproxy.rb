# encoding: UTF-8
#
# Cookbook Name:: openstack-compute
# Recipe:: spiceproxy
#
# Copyright 2015, Tomasz Setkowski <tom@ai-traders.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'openstack-compute::nova-common'

platform_options = node['openstack']['compute']['platform']

platform_options['compute_spicehtml5proxy_packages'].each do |pkg|
  package pkg do
    options platform_options['package_overrides']

    action :upgrade
  end
end

proxy_service = platform_options['compute_spicehtml5proxy_service']

if node['openstack']['compute']['spice']['enabled']
  action = [:enable, :start]
else
  action = [:disable, :stop]
end

service proxy_service do
  service_name proxy_service
  provider Chef::Provider::Service::Upstart
  supports status: true, restart: true
  subscribes :restart, resources('template[/etc/nova/nova.conf]')

  action action
end
