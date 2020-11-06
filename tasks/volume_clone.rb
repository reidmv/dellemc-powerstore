#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../lib/puppet/util/task_helper'
require 'json'
require 'puppet'
require 'openssl'
# require 'pry-remote'; binding.remote_pry
    
class PowerstoreVolumeCloneTask < TaskHelper

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
    operation_path = '/volume/%{id}/clone'
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
      op_param('description', 'body', 'description', 'description'),
      op_param('host_group_id', 'body', 'host_group_id', 'host_group_id'),
      op_param('host_id', 'body', 'host_id', 'host_id'),
      op_param('id', 'path', 'id', 'id'),
      op_param('logical_unit_number', 'body', 'logical_unit_number', 'logical_unit_number'),
      op_param('name', 'body', 'name', 'name'),
      op_param('performance_policy_id', 'body', 'performance_policy_id', 'performance_policy_id'),
      op_param('protection_policy_id', 'body', 'protection_policy_id', 'protection_policy_id'),
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
    PowerstoreVolumeCloneTask.run
  end

end
