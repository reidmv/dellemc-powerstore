#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../lib/puppet/util/task_helper'
require 'json'
require 'puppet'
require 'openssl'
# require 'pry-remote'; binding.remote_pry
    
class PowerstoreFileLdapModifyTask < TaskHelper

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
    namevar = 'id'
    namevar = 'id' if namevar.empty?
    operation_verb = 'Patch'
    operation_path = '/file_ldap/%{id}'
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
      op_param('add_addresses', 'body', 'add_addresses', 'add_addresses'),
      op_param('addresses', 'body', 'addresses', 'addresses'),
      op_param('authentication_type', 'body', 'authentication_type', 'authentication_type'),
      op_param('base_DN', 'body', 'base_dn', 'base_dn'),
      op_param('bind_DN', 'body', 'bind_dn', 'bind_dn'),
      op_param('bind_password', 'body', 'bind_password', 'bind_password'),
      op_param('id', 'path', 'id', 'id'),
      op_param('is_smb_account_used', 'body', 'is_smb_account_used', 'is_smb_account_used'),
      op_param('is_verify_server_certificate', 'body', 'is_verify_server_certificate', 'is_verify_server_certificate'),
      op_param('password', 'body', 'password', 'password'),
      op_param('port_number', 'body', 'port_number', 'port_number'),
      op_param('principal', 'body', 'principal', 'principal'),
      op_param('profile_DN', 'body', 'profile_dn', 'profile_dn'),
      op_param('protocol', 'body', 'protocol', 'protocol'),
      op_param('realm', 'body', 'realm', 'realm'),
      op_param('remove_addresses', 'body', 'remove_addresses', 'remove_addresses'),
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
    PowerstoreFileLdapModifyTask.run
  end

end
