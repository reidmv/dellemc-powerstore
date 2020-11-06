require 'puppet/resource_api'
require "pry"

class Puppet::Provider::PowerstoreFileLdap::PowerstoreFileLdap
  def canonicalize(context, resources)
    #nout to do here but seems we need to implement it
    resources
  end

  def get(context)
context.debug("Entered get")
      hash = self.class.fetch_all_as_hash(context)
      context.debug("Completed get, returning hash #{hash}")
      hash

  end

  def set(context, changes, noop: false)
    context.debug("Entered set")


    changes.each do |name, change|
      context.debug("set change with #{name} and #{change}")
      #FIXME: key[:name] below hardwires the unique key of the resource to be :name
      is = change.key?(:is) ? change[:is] : get(context).find { |key| key[:name] == name }
      should = change[:should]

      is = { name: name, ensure: 'absent' } if is.nil?
      should = { name: name, ensure: 'absent' } if should.nil?

      if is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'present'
        create(context, name, should) unless noop
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
        context.deleting(name) do
          # FIXME hardwired
          should[:id] = is[:id]
          delete(context, should) unless noop
        end
      elsif is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'absent'
        context.failed(name, message: 'Unexpected absent to absent change')
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'present'
          # FIXME hardwired
          should[:id] = is[:id]
        update(context, name, should)
      end
    end
  end

  def create(context, name, should)
    context.creating(name) do
      new_hash = build_create_hash(should)
      new_hash.delete("id")
      response = self.class.invoke_create(context, should, new_hash)

      if response.is_a? Net::HTTPSuccess
        should[:ensure] = 'present'
        Puppet.info("Added :ensure to property hash")
      else
        raise("Create failed.  Response is #{response} and body is #{response.body}")
      end
    end
  rescue Exception => ex
    Puppet.alert("Exception during create. The state of the resource is unknown.  ex is #{ex} and backtrace is #{ex.backtrace}")
    raise
  end

  def update(context, name, should)
    context.updating(name) do
      new_hash = build_update_hash(should)
      new_hash.delete("id")
      response = self.class.invoke_update(context, should, new_hash)

      if response.is_a? Net::HTTPSuccess
        should[:ensure] = 'present'
        Puppet.info("Added :ensure to property hash")
      else
        raise("Update failed. The state of the resource is unknown.  Response is #{response} and body is #{response.body}")
      end
    end
  rescue Exception => ex
    Puppet.alert("Exception during update. ex is #{ex} and backtrace is #{ex.backtrace}")
    raise
  end

  def build_create_hash(resource)
    file_ldap = {}
    file_ldap["addresses"] = resource[:addresses] unless resource[:addresses].nil?
    file_ldap["authentication_type"] = resource[:authentication_type] unless resource[:authentication_type].nil?
    file_ldap["base_DN"] = resource[:base_dn] unless resource[:base_dn].nil?
    file_ldap["bind_DN"] = resource[:bind_dn] unless resource[:bind_dn].nil?
    file_ldap["bind_password"] = resource[:bind_password] unless resource[:bind_password].nil?
    file_ldap["is_smb_account_used"] = resource[:is_smb_account_used] unless resource[:is_smb_account_used].nil?
    file_ldap["is_verify_server_certificate"] = resource[:is_verify_server_certificate] unless resource[:is_verify_server_certificate].nil?
    file_ldap["nas_server_id"] = resource[:nas_server_id] unless resource[:nas_server_id].nil?
    file_ldap["password"] = resource[:password] unless resource[:password].nil?
    file_ldap["port_number"] = resource[:port_number] unless resource[:port_number].nil?
    file_ldap["principal"] = resource[:principal] unless resource[:principal].nil?
    file_ldap["profile_DN"] = resource[:profile_dn] unless resource[:profile_dn].nil?
    file_ldap["protocol"] = resource[:protocol] unless resource[:protocol].nil?
    file_ldap["realm"] = resource[:realm] unless resource[:realm].nil?
    return file_ldap
  end

  def build_update_hash(resource)
    file_ldap = {}
    file_ldap["add_addresses"] = resource[:add_addresses] unless resource[:add_addresses].nil?
    file_ldap["addresses"] = resource[:addresses] unless resource[:addresses].nil?
    file_ldap["authentication_type"] = resource[:authentication_type] unless resource[:authentication_type].nil?
    file_ldap["base_DN"] = resource[:base_dn] unless resource[:base_dn].nil?
    file_ldap["bind_DN"] = resource[:bind_dn] unless resource[:bind_dn].nil?
    file_ldap["bind_password"] = resource[:bind_password] unless resource[:bind_password].nil?
    file_ldap["is_smb_account_used"] = resource[:is_smb_account_used] unless resource[:is_smb_account_used].nil?
    file_ldap["is_verify_server_certificate"] = resource[:is_verify_server_certificate] unless resource[:is_verify_server_certificate].nil?
    file_ldap["password"] = resource[:password] unless resource[:password].nil?
    file_ldap["port_number"] = resource[:port_number] unless resource[:port_number].nil?
    file_ldap["principal"] = resource[:principal] unless resource[:principal].nil?
    file_ldap["profile_DN"] = resource[:profile_dn] unless resource[:profile_dn].nil?
    file_ldap["protocol"] = resource[:protocol] unless resource[:protocol].nil?
    file_ldap["realm"] = resource[:realm] unless resource[:realm].nil?
    file_ldap["remove_addresses"] = resource[:remove_addresses] unless resource[:remove_addresses].nil?
    return file_ldap
  end

  def build_delete_hash(resource)
    file_ldap = {}
    return file_ldap
  end

  def build_hash(resource)
    file_ldap = {}
    file_ldap["add_addresses"] = resource[:add_addresses] unless resource[:add_addresses].nil?
    file_ldap["addresses"] = resource[:addresses] unless resource[:addresses].nil?
    file_ldap["authentication_type"] = resource[:authentication_type] unless resource[:authentication_type].nil?
    file_ldap["authentication_type_l10n"] = resource[:authentication_type_l10n] unless resource[:authentication_type_l10n].nil?
    file_ldap["base_DN"] = resource[:base_dn] unless resource[:base_dn].nil?
    file_ldap["bind_DN"] = resource[:bind_dn] unless resource[:bind_dn].nil?
    file_ldap["bind_password"] = resource[:bind_password] unless resource[:bind_password].nil?
    file_ldap["id"] = resource[:id] unless resource[:id].nil?
    file_ldap["is_certificate_uploaded"] = resource[:is_certificate_uploaded] unless resource[:is_certificate_uploaded].nil?
    file_ldap["is_config_file_uploaded"] = resource[:is_config_file_uploaded] unless resource[:is_config_file_uploaded].nil?
    file_ldap["is_smb_account_used"] = resource[:is_smb_account_used] unless resource[:is_smb_account_used].nil?
    file_ldap["is_verify_server_certificate"] = resource[:is_verify_server_certificate] unless resource[:is_verify_server_certificate].nil?
    file_ldap["nas_server_id"] = resource[:nas_server_id] unless resource[:nas_server_id].nil?
    file_ldap["password"] = resource[:password] unless resource[:password].nil?
    file_ldap["port_number"] = resource[:port_number] unless resource[:port_number].nil?
    file_ldap["principal"] = resource[:principal] unless resource[:principal].nil?
    file_ldap["profile_DN"] = resource[:profile_dn] unless resource[:profile_dn].nil?
    file_ldap["protocol"] = resource[:protocol] unless resource[:protocol].nil?
    file_ldap["protocol_l10n"] = resource[:protocol_l10n] unless resource[:protocol_l10n].nil?
    file_ldap["realm"] = resource[:realm] unless resource[:realm].nil?
    file_ldap["remove_addresses"] = resource[:remove_addresses] unless resource[:remove_addresses].nil?
    file_ldap["schema_type"] = resource[:schema_type] unless resource[:schema_type].nil?
    file_ldap["schema_type_l10n"] = resource[:schema_type_l10n] unless resource[:schema_type_l10n].nil?
    return file_ldap
  end

  def self.build_key_values
    key_values = {}
    
    key_values["api-version"] = "assets"
    key_values
  end

  # def destroy(context)
  #   delete(context, resource)
  # end

  def delete(context, should)
    new_hash = build_delete_hash(should)
    response = self.class.invoke_delete(context, should, new_hash)
    if response.is_a? Net::HTTPSuccess
      should[:ensure] = 'absent'
      Puppet.info "Added 'absent' to property_hash"
    else
      raise("Delete failed.  The state of the resource is unknown.  Response is #{response} and body is #{response.body}")
    end
  rescue Exception => ex
    Puppet.alert("Exception during destroy. ex is #{ex} and backtrace is #{ex.backtrace}")
    raise
  end


  def self.invoke_list_all(context, resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation file_ldap_collection_query")
    path_params = {}
    query_params = {}
    header_params = {}
    header_params["User-Agent"] = ""
    
    op_params = [
    ]
    op_params.each do |i|
      inquery = i[:inquery]
      name    = i[:name]
      paramalias = i[:paramalias]
      name_snake = i[:namesnake]
      if inquery == 'query'
        query_params[name] = key_values[name] unless key_values[name].nil?
        query_params[name] = ENV["powerstore_#{name_snake}"] unless ENV["powerstore_#{name_snake}"].nil?
        query_params[name] = resource[paramalias.to_sym] unless resource.nil? || resource[paramalias.to_sym].nil?
      else
        path_params[name_snake.to_sym] = key_values[name] unless key_values[name].nil?
        path_params[name_snake.to_sym] = ENV["powerstore_#{name_snake}"] unless ENV["powerstore_#{name_snake}"].nil?
        path_params[name_snake.to_sym] = resource[paramalias.to_sym] unless resource.nil? || resource[paramalias.to_sym].nil?
      end
    end
    context.transport.call_op(path_params, query_params, header_params, body_params, '/file_ldap', 'Get','application/json')
  end


  def self.invoke_create(context, resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation file_ldap_create")
    path_params = {}
    query_params = {}
    header_params = {}
    header_params["User-Agent"] = ""
    
    op_params = [
      self.op_param('addresses', 'body', 'addresses', 'addresses'),
      self.op_param('authentication_type', 'body', 'authentication_type', 'authentication_type'),
      self.op_param('base_DN', 'body', 'base_dn', 'base_dn'),
      self.op_param('bind_DN', 'body', 'bind_dn', 'bind_dn'),
      self.op_param('bind_password', 'body', 'bind_password', 'bind_password'),
      self.op_param('is_smb_account_used', 'body', 'is_smb_account_used', 'is_smb_account_used'),
      self.op_param('is_verify_server_certificate', 'body', 'is_verify_server_certificate', 'is_verify_server_certificate'),
      self.op_param('nas_server_id', 'body', 'nas_server_id', 'nas_server_id'),
      self.op_param('password', 'body', 'password', 'password'),
      self.op_param('port_number', 'body', 'port_number', 'port_number'),
      self.op_param('principal', 'body', 'principal', 'principal'),
      self.op_param('profile_DN', 'body', 'profile_dn', 'profile_dn'),
      self.op_param('protocol', 'body', 'protocol', 'protocol'),
      self.op_param('realm', 'body', 'realm', 'realm'),
    ]
    op_params.each do |i|
      inquery = i[:inquery]
      name    = i[:name]
      paramalias = i[:paramalias]
      name_snake = i[:namesnake]
      if inquery == 'query'
        query_params[name] = key_values[name] unless key_values[name].nil?
        query_params[name] = ENV["powerstore_#{name_snake}"] unless ENV["powerstore_#{name_snake}"].nil?
        query_params[name] = resource[paramalias.to_sym] unless resource.nil? || resource[paramalias.to_sym].nil?
      else
        path_params[name_snake.to_sym] = key_values[name] unless key_values[name].nil?
        path_params[name_snake.to_sym] = ENV["powerstore_#{name_snake}"] unless ENV["powerstore_#{name_snake}"].nil?
        path_params[name_snake.to_sym] = resource[paramalias.to_sym] unless resource.nil? || resource[paramalias.to_sym].nil?
      end
    end
    context.transport.call_op(path_params, query_params, header_params, body_params, '/file_ldap', 'Post','application/json')
  end


  def self.invoke_update(context, resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation file_ldap_modify")
    path_params = {}
    query_params = {}
    header_params = {}
    header_params["User-Agent"] = ""
    
    op_params = [
      self.op_param('add_addresses', 'body', 'add_addresses', 'add_addresses'),
      self.op_param('addresses', 'body', 'addresses', 'addresses'),
      self.op_param('authentication_type', 'body', 'authentication_type', 'authentication_type'),
      self.op_param('base_DN', 'body', 'base_dn', 'base_dn'),
      self.op_param('bind_DN', 'body', 'bind_dn', 'bind_dn'),
      self.op_param('bind_password', 'body', 'bind_password', 'bind_password'),
      self.op_param('id', 'path', 'id', 'id'),
      self.op_param('is_smb_account_used', 'body', 'is_smb_account_used', 'is_smb_account_used'),
      self.op_param('is_verify_server_certificate', 'body', 'is_verify_server_certificate', 'is_verify_server_certificate'),
      self.op_param('password', 'body', 'password', 'password'),
      self.op_param('port_number', 'body', 'port_number', 'port_number'),
      self.op_param('principal', 'body', 'principal', 'principal'),
      self.op_param('profile_DN', 'body', 'profile_dn', 'profile_dn'),
      self.op_param('protocol', 'body', 'protocol', 'protocol'),
      self.op_param('realm', 'body', 'realm', 'realm'),
      self.op_param('remove_addresses', 'body', 'remove_addresses', 'remove_addresses'),
    ]
    op_params.each do |i|
      inquery = i[:inquery]
      name    = i[:name]
      paramalias = i[:paramalias]
      name_snake = i[:namesnake]
      if inquery == 'query'
        query_params[name] = key_values[name] unless key_values[name].nil?
        query_params[name] = ENV["powerstore_#{name_snake}"] unless ENV["powerstore_#{name_snake}"].nil?
        query_params[name] = resource[paramalias.to_sym] unless resource.nil? || resource[paramalias.to_sym].nil?
      else
        path_params[name_snake.to_sym] = key_values[name] unless key_values[name].nil?
        path_params[name_snake.to_sym] = ENV["powerstore_#{name_snake}"] unless ENV["powerstore_#{name_snake}"].nil?
        path_params[name_snake.to_sym] = resource[paramalias.to_sym] unless resource.nil? || resource[paramalias.to_sym].nil?
      end
    end
    context.transport.call_op(path_params, query_params, header_params, body_params, '/file_ldap/%{id}', 'Patch','application/json')
  end


  def self.invoke_delete(context, resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation file_ldap_delete")
    path_params = {}
    query_params = {}
    header_params = {}
    header_params["User-Agent"] = ""
    
    op_params = [
      self.op_param('id', 'path', 'id', 'id'),
    ]
    op_params.each do |i|
      inquery = i[:inquery]
      name    = i[:name]
      paramalias = i[:paramalias]
      name_snake = i[:namesnake]
      if inquery == 'query'
        query_params[name] = key_values[name] unless key_values[name].nil?
        query_params[name] = ENV["powerstore_#{name_snake}"] unless ENV["powerstore_#{name_snake}"].nil?
        query_params[name] = resource[paramalias.to_sym] unless resource.nil? || resource[paramalias.to_sym].nil?
      else
        path_params[name_snake.to_sym] = key_values[name] unless key_values[name].nil?
        path_params[name_snake.to_sym] = ENV["powerstore_#{name_snake}"] unless ENV["powerstore_#{name_snake}"].nil?
        path_params[name_snake.to_sym] = resource[paramalias.to_sym] unless resource.nil? || resource[paramalias.to_sym].nil?
      end
    end
    context.transport.call_op(path_params, query_params, header_params, body_params, '/file_ldap/%{id}', 'Delete','application/json')
  end




  def self.invoke_get_one(context, resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation file_ldap_instance_query")
    path_params = {}
    query_params = {}
    header_params = {}
    header_params["User-Agent"] = ""
    
    op_params = [
      self.op_param('id', 'path', 'id', 'id'),
    ]
    op_params.each do |i|
      inquery = i[:inquery]
      name    = i[:name]
      paramalias = i[:paramalias]
      name_snake = i[:namesnake]
      if inquery == 'query'
        query_params[name] = key_values[name] unless key_values[name].nil?
        query_params[name] = ENV["powerstore_#{name_snake}"] unless ENV["powerstore_#{name_snake}"].nil?
        query_params[name] = resource[paramalias.to_sym] unless resource.nil? || resource[paramalias.to_sym].nil?
      else
        path_params[name_snake.to_sym] = key_values[name] unless key_values[name].nil?
        path_params[name_snake.to_sym] = ENV["powerstore_#{name_snake}"] unless ENV["powerstore_#{name_snake}"].nil?
        path_params[name_snake.to_sym] = resource[paramalias.to_sym] unless resource.nil? || resource[paramalias.to_sym].nil?
      end
    end
    context.transport.call_op(path_params, query_params, header_params, body_params, '/file_ldap/%{id}', 'Get','application/json')
  end


  def self.fetch_all_as_hash(context)
    items = self.fetch_all(context)
    if items
      items.collect do |item|
        hash = {

          add_addresses: item['add_addresses'],
          addresses: item['addresses'],
          authentication_type: item['authentication_type'],
          authentication_type_l10n: item['authentication_type_l10n'],
          base_dn: item['base_DN'],
          bind_dn: item['bind_DN'],
          bind_password: item['bind_password'],
          id: item['id'],
          is_certificate_uploaded: item['is_certificate_uploaded'],
          is_config_file_uploaded: item['is_config_file_uploaded'],
          is_smb_account_used: item['is_smb_account_used'],
          is_verify_server_certificate: item['is_verify_server_certificate'],
          nas_server_id: item['nas_server_id'],
          password: item['password'],
          port_number: item['port_number'],
          principal: item['principal'],
          profile_dn: item['profile_DN'],
          protocol: item['protocol'],
          protocol_l10n: item['protocol_l10n'],
          realm: item['realm'],
          remove_addresses: item['remove_addresses'],
          schema_type: item['schema_type'],
          schema_type_l10n: item['schema_type_l10n'],
          ensure: 'present',
        }
        Puppet.debug("Adding to collection: #{item}")

        hash

      end.compact
    else
      []
    end
  rescue Exception => ex
    Puppet.alert("ex is #{ex} and backtrace is #{ex.backtrace}")
    raise
  end

  def self.deep_delete(hash_item, tokens)
    if tokens.size == 1
      if hash_item.kind_of?(Array)
        hash_item.map! { |item| deep_delete(item, tokens) }
      else
        hash_item.delete(tokens[0]) unless hash_item.nil? or hash_item[tokens[0]].nil?
      end
    else
      if hash_item.kind_of?(Array)
        hash_item.map! { |item| deep_delete(item, tokens[1..-1]) }
      else
        hash_item[tokens.first] = deep_delete(hash_item[tokens.first], tokens[1..-1]) unless hash_item.nil? or hash_item[tokens[0]].nil?
      end
    end
    return hash_item
  end

  def self.fetch_all(context)
    response = invoke_list_all(context)
    if response.kind_of? Net::HTTPSuccess
      body = JSON.parse(response.body)
      if body.is_a? Array # and body.key? "value"
        return body #["value"]
      end
    end
  end


  def self.authenticate(path_params, query_params, header_params, body_params)
    return true
  end


  def exists?
    return_value = @property_hash[:ensure] && @property_hash[:ensure] != 'absent'
    Puppet.info("Checking if resource #{name} of type <no value> exists, returning #{return_value}")
    return_value
  end

  def self.add_keys_to_request(request, hash)
    if hash
      hash.each { |x, v| request[x] = v }
    end
  end

  def self.to_query(hash)
    if hash
      return_value = hash.map { |x, v| "#{x}=#{v}" }.reduce { |x, v| "#{x}&#{v}" }
      if !return_value.nil?
        return return_value
      end
    end
    return ""
  end

  def self.op_param(name, inquery, paramalias, namesnake)
    operation_param = { :name => name, :inquery => inquery, :paramalias => paramalias, :namesnake => namesnake }
    return operation_param
  end


end
