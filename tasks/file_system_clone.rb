#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../lib/puppet/util/task_helper'
require 'json'
require 'puppet'
require 'openssl'
# require 'pry-remote'; binding.remote_pry
    
class PowerstoreFileSystemCloneTask < TaskHelper

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
    namevar = 'name'
    namevar = 'id' if namevar.empty?
    operation_verb = 'Post'
    operation_path = '/file_system/%{id}/clone'
    parent_consumes = 'application/json'
    parent_produces = 'application/json'
    query_params, body_params, path_params = format_params(arg_hash)

    header_params = {}

    result = transport.call_op(path_params, query_params, header_params, body_params, operation_path, operation_verb, parent_consumes)

    if result.is_a? Net::HTTPSuccess
      if result.body.nil?
        return nil
      end
      if result.to_hash["content-type"].include? "document/text"
        return result.body
      end
      body = JSON.parse(result.body)
      if body.class == Array
        # return { "list" => body }
        return body.map { | i | [ i[namevar], i ] }.to_h
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
      op_param('access_policy', 'body', 'access_policy', 'access_policy'),
      op_param('description', 'body', 'description', 'description'),
      op_param('folder_rename_policy', 'body', 'folder_rename_policy', 'folder_rename_policy'),
      op_param('id', 'path', 'id', 'id'),
      op_param('is_async_MTime_enabled', 'body', 'is_async_m_time_enabled', 'is_async_m_time_enabled'),
      op_param('is_smb_no_notify_enabled', 'body', 'is_smb_no_notify_enabled', 'is_smb_no_notify_enabled'),
      op_param('is_smb_notify_on_access_enabled', 'body', 'is_smb_notify_on_access_enabled', 'is_smb_notify_on_access_enabled'),
      op_param('is_smb_notify_on_write_enabled', 'body', 'is_smb_notify_on_write_enabled', 'is_smb_notify_on_write_enabled'),
      op_param('is_smb_op_locks_enabled', 'body', 'is_smb_op_locks_enabled', 'is_smb_op_locks_enabled'),
      op_param('is_smb_sync_writes_enabled', 'body', 'is_smb_sync_writes_enabled', 'is_smb_sync_writes_enabled'),
      op_param('locking_policy', 'body', 'locking_policy', 'locking_policy'),
      op_param('name', 'body', 'name', 'name'),
      op_param('smb_notify_on_change_dir_depth', 'body', 'smb_notify_on_change_dir_depth', 'smb_notify_on_change_dir_depth'),
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
    PowerstoreFileSystemCloneTask.run
  end

end
