#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../lib/puppet/util/task_helper'
require 'json'
require 'puppet'
require 'openssl'
# require 'pry-remote'; binding.remote_pry
    
class PowerstoreFileFtpModifyTask < TaskHelper

  def task(arg_hash)

    header_params = {}
    
    # params=args[0][1..-1].split(',')

    # arg_hash={}
    # params.each { |param|
    #   mapValues= param.split(':',2)
    #   if mapValues[1].include?(';')
    #       mapValues[1].gsub! ';',','
    #   end
    #   arg_hash[mapValues[0][1..-2]]=mapValues[1][1..-2]
    # }

    # Remove task name from arguments - should contain all necessary parameters for URI
    arg_hash.delete('_task')
    operation_verb = 'Patch'
    operation_path = '/file_ftp/%{id}'
    parent_consumes = 'application/json'
    query_params, body_params, path_params = format_params(arg_hash)

    header_params = {}

    result = transport.call_op(path_params, query_params, header_params, body_params, operation_path, operation_verb, parent_consumes)

    if result.is_a? Net::HTTPSuccess
      if result.body.nil?
        return nil
      end
      body = JSON.parse(result.body)
      if body.class == Array
        return { "list" => body }
      else
        return body
      end
    else
      raise result.body
    end
  end

  def op_param(name, location, paramalias, namesnake)
    { :name => name, :location => location, :paramalias => paramalias, :namesnake => namesnake }
  end
  
  def format_params(key_values)
    query_params = {}
    body_params = {}
    path_params = {}

    key_values.each { | key, value |
      if value.respond_to?(:include) and value.include?("=>")
        value.include?("=>")
        Puppet.debug("Running hash from string on #{value}")
        value.gsub!("=>",":")
        value.gsub!("'","\"")
        key_values[key] = JSON.parse(value)
        Puppet.debug("Obtained hash #{key_values[key].inspect}")
      end
    }


    if key_values.key?('body')
      if File.file?(key_values['body'])
        if key_values['body'].include?('json')
          body_params['file_content'] = File.read(key_values['body'])
        else
          body_params['file_content'] =JSON.pretty_generate(YAML.load_file(key_values['body']))
        end
      end
    end

    op_params = [
      op_param('add_groups', 'body', 'add_groups', 'add_groups'),
      op_param('add_hosts', 'body', 'add_hosts', 'add_hosts'),
      op_param('add_users', 'body', 'add_users', 'add_users'),
      op_param('audit_dir', 'body', 'audit_dir', 'audit_dir'),
      op_param('audit_max_size', 'body', 'audit_max_size', 'audit_max_size'),
      op_param('default_homedir', 'body', 'default_homedir', 'default_homedir'),
      op_param('groups', 'body', 'groups', 'groups'),
      op_param('hosts', 'body', 'hosts', 'hosts'),
      op_param('id', 'path', 'id', 'id'),
      op_param('is_allowed_groups', 'body', 'is_allowed_groups', 'is_allowed_groups'),
      op_param('is_allowed_hosts', 'body', 'is_allowed_hosts', 'is_allowed_hosts'),
      op_param('is_allowed_users', 'body', 'is_allowed_users', 'is_allowed_users'),
      op_param('is_anonymous_authentication_enabled', 'body', 'is_anonymous_authentication_enabled', 'is_anonymous_authentication_enabled'),
      op_param('is_audit_enabled', 'body', 'is_audit_enabled', 'is_audit_enabled'),
      op_param('is_ftp_enabled', 'body', 'is_ftp_enabled', 'is_ftp_enabled'),
      op_param('is_homedir_limit_enabled', 'body', 'is_homedir_limit_enabled', 'is_homedir_limit_enabled'),
      op_param('is_sftp_enabled', 'body', 'is_sftp_enabled', 'is_sftp_enabled'),
      op_param('is_smb_authentication_enabled', 'body', 'is_smb_authentication_enabled', 'is_smb_authentication_enabled'),
      op_param('is_unix_authentication_enabled', 'body', 'is_unix_authentication_enabled', 'is_unix_authentication_enabled'),
      op_param('message_of_the_day', 'body', 'message_of_the_day', 'message_of_the_day'),
      op_param('remove_groups', 'body', 'remove_groups', 'remove_groups'),
      op_param('remove_hosts', 'body', 'remove_hosts', 'remove_hosts'),
      op_param('remove_users', 'body', 'remove_users', 'remove_users'),
      op_param('users', 'body', 'users', 'users'),
      op_param('welcome_message', 'body', 'welcome_message', 'welcome_message'),
      ]
    op_params.each do |i|
      location = i[:location]
      name     = i[:name]
      paramalias = i[:paramalias]
      name_snake = i[:namesnake]
      if location == 'query'
        query_params[name] = key_values[name_snake.to_sym] unless key_values[name_snake.to_sym].nil?
      elsif location == 'body'
        body_params[name] = key_values[name_snake.to_sym] unless key_values[name_snake.to_sym].nil?
      else
        path_params[name_snake.to_sym] = key_values[name_snake.to_sym] unless key_values[name_snake.to_sym].nil?
      end
    end
    
    return query_params,body_params,path_params
  end

  if __FILE__ == $0
    PowerstoreFileFtpModifyTask.run
  end

end