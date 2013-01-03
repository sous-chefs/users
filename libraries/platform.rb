#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
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

require 'chef/config'
require 'chef/log'
require 'chef/mixin/params_validate'

# This file depends on nearly every provider in chef, but requiring them
# directly causes circular requires resulting in uninitialized constant errors.
require 'chef/provider'
require 'chef/provider/log'
require 'chef/provider/user'
require 'chef/provider/group'
require 'chef/provider/mount'
require 'chef/provider/service'
require 'chef/provider/package'


class Chef
  class Platform

    class << self
      attr_writer :platforms

      def platforms
        @platforms ||= {
          :smartos => {
            :default => {
              :service => Chef::Provider::Service::Solaris,
              :package => Chef::Provider::Package::SmartOS,
              :cron => Chef::Provider::Cron::Solaris,
              :group => Chef::Provider::Group::Usermod,
              :user => Chef::Provider::User::Smartos

            }
          },
          :default  => {
            :file => Chef::Provider::File,
            :directory => Chef::Provider::Directory,
            :link => Chef::Provider::Link,
            :template => Chef::Provider::Template,
            :remote_directory => Chef::Provider::RemoteDirectory,
            :execute => Chef::Provider::Execute,
            :mount => Chef::Provider::Mount::Mount,
            :script => Chef::Provider::Script,
            :service => Chef::Provider::Service::Init,
            :perl => Chef::Provider::Script,
            :python => Chef::Provider::Script,
            :ruby => Chef::Provider::Script,
            :bash => Chef::Provider::Script,
            :csh => Chef::Provider::Script,
            :user => Chef::Provider::User::Useradd,
            :group => Chef::Provider::Group::Gpasswd,
            :http_request => Chef::Provider::HttpRequest,
            :route => Chef::Provider::Route,
            :ifconfig => Chef::Provider::Ifconfig,
            :ruby_block => Chef::Provider::RubyBlock,
            :erl_call => Chef::Provider::ErlCall,
            :log => Chef::Provider::Log::ChefLog
          }
        }
      end
    end
  end
end
