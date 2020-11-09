require 'puppet/resource_api'
require "pry"

class Puppet::Provider::PowerstoreVolume::PowerstoreVolume
  def canonicalize(_context, resources)
    # nout to do here but seems we need to implement it
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
      # FIXME: key[:name] below hardwires the unique key of the resource to be :name
      is = change.key?(:is) ? change[:is] : get(context).find { |key| key[:name] == name }
      should = change[:should]

      is = { name: name, ensure: 'absent' } if is.nil?
      should = { name: name, ensure: 'absent' } if should.nil?

      if is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'present'
        create(context, name, should) unless noop
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
        context.deleting(name) do
          # FIXME: hardwired
          should[:id] = is[:id]
          delete(context, should) unless noop
        end
      elsif is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'absent'
        context.failed(name, message: 'Unexpected absent to absent change')
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'present'
        # FIXME: hardwired
        should[:id] = is[:id]
        update(context, name, should)
      end
    end
  end

  def create(context, name, should)
    context.creating(name) do
      new_hash = build_create_hash(should)
      new_hash.delete('id')
      response = self.class.invoke_create(context, should, new_hash)

      if response.is_a? Net::HTTPSuccess
        should[:ensure] = 'present'
        Puppet.info('Added :ensure to property hash')
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
      new_hash.delete('id')
      response = self.class.invoke_update(context, should, new_hash)

      if response.is_a? Net::HTTPSuccess
        should[:ensure] = 'present'
        Puppet.info('Added :ensure to property hash')
      else
        raise("Update failed. The state of the resource is unknown.  Response is #{response} and body is #{response.body}")
      end
    end
  rescue Exception => ex
    Puppet.alert("Exception during update. ex is #{ex} and backtrace is #{ex.backtrace}")
    raise
  end

  def build_create_hash(resource)
    volume = {}
    volume['appliance_id'] = resource[:appliance_id] unless resource[:appliance_id].nil?
    volume['description'] = resource[:description] unless resource[:description].nil?
    volume['host_group_id'] = resource[:host_group_id] unless resource[:host_group_id].nil?
    volume['host_id'] = resource[:host_id] unless resource[:host_id].nil?
    volume['logical_unit_number'] = resource[:logical_unit_number] unless resource[:logical_unit_number].nil?
    volume['min_size'] = resource[:min_size] unless resource[:min_size].nil?
    volume['name'] = resource[:name] unless resource[:name].nil?
    volume['performance_policy_id'] = resource[:performance_policy_id] unless resource[:performance_policy_id].nil?
    volume['protection_policy_id'] = resource[:protection_policy_id] unless resource[:protection_policy_id].nil?
    volume['sector_size'] = resource[:sector_size] unless resource[:sector_size].nil?
    volume['size'] = resource[:size] unless resource[:size].nil?
    volume['volume_group_id'] = resource[:volume_group_id] unless resource[:volume_group_id].nil?
    return volume
  end

  def build_update_hash(resource)
    volume = {}
    volume['description'] = resource[:description] unless resource[:description].nil?
    volume['expiration_timestamp'] = resource[:expiration_timestamp] unless resource[:expiration_timestamp].nil?
    volume['force'] = resource[:force] unless resource[:force].nil?
    volume['is_replication_destination'] = resource[:is_replication_destination] unless resource[:is_replication_destination].nil?
    volume['name'] = resource[:name] unless resource[:name].nil?
    volume['node_affinity'] = resource[:node_affinity] unless resource[:node_affinity].nil?
    volume['performance_policy_id'] = resource[:performance_policy_id] unless resource[:performance_policy_id].nil?
    volume['protection_policy_id'] = resource[:protection_policy_id] unless resource[:protection_policy_id].nil?
    volume['size'] = resource[:size] unless resource[:size].nil?
    return volume
  end

  def build_delete_hash(resource)
    volume = {}
    return volume
  end

  def build_hash(resource)
    volume = {}
    volume['appliance_id'] = resource[:appliance_id] unless resource[:appliance_id].nil?
    volume['creation_timestamp'] = resource[:creation_timestamp] unless resource[:creation_timestamp].nil?
    volume['description'] = resource[:description] unless resource[:description].nil?
    volume['expiration_timestamp'] = resource[:expiration_timestamp] unless resource[:expiration_timestamp].nil?
    volume['force'] = resource[:force] unless resource[:force].nil?
    volume['host_group_id'] = resource[:host_group_id] unless resource[:host_group_id].nil?
    volume['host_id'] = resource[:host_id] unless resource[:host_id].nil?
    volume['id'] = resource[:id] unless resource[:id].nil?
    volume['is_replication_destination'] = resource[:is_replication_destination] unless resource[:is_replication_destination].nil?
    volume['location_history'] = resource[:location_history] unless resource[:location_history].nil?
    volume['logical_unit_number'] = resource[:logical_unit_number] unless resource[:logical_unit_number].nil?
    volume['migration_session_id'] = resource[:migration_session_id] unless resource[:migration_session_id].nil?
    volume['min_size'] = resource[:min_size] unless resource[:min_size].nil?
    volume['name'] = resource[:name] unless resource[:name].nil?
    volume['node_affinity'] = resource[:node_affinity] unless resource[:node_affinity].nil?
    volume['node_affinity_l10n'] = resource[:node_affinity_l10n] unless resource[:node_affinity_l10n].nil?
    volume['performance_policy_id'] = resource[:performance_policy_id] unless resource[:performance_policy_id].nil?
    volume['protection_data'] = resource[:protection_data] unless resource[:protection_data].nil?
    volume['protection_policy_id'] = resource[:protection_policy_id] unless resource[:protection_policy_id].nil?
    volume['sector_size'] = resource[:sector_size] unless resource[:sector_size].nil?
    volume['size'] = resource[:size] unless resource[:size].nil?
    volume['state'] = resource[:state] unless resource[:state].nil?
    volume['state_l10n'] = resource[:state_l10n] unless resource[:state_l10n].nil?
    volume['type'] = resource[:type] unless resource[:type].nil?
    volume['type_l10n'] = resource[:type_l10n] unless resource[:type_l10n].nil?
    volume['volume_group_id'] = resource[:volume_group_id] unless resource[:volume_group_id].nil?
    volume['wwn'] = resource[:wwn] unless resource[:wwn].nil?
    return volume
  end

  def self.build_key_values
    key_values = {}
    
    key_values['api-version'] = 'assets'
    key_values
  end

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
    Puppet.info("Calling operation volume_collection_query")
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
    context.transport.call_op(path_params, query_params, header_params, body_params, '/volume', 'Get','application/json')
  end


  def self.invoke_create(context, resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation volume_create")
    path_params = {}
    query_params = {}
    header_params = {}
    header_params["User-Agent"] = ""
    
    op_params = [
      self.op_param('appliance_id', 'body', 'appliance_id', 'appliance_id'),
      self.op_param('description', 'body', 'description', 'description'),
      self.op_param('host_group_id', 'body', 'host_group_id', 'host_group_id'),
      self.op_param('host_id', 'body', 'host_id', 'host_id'),
      self.op_param('logical_unit_number', 'body', 'logical_unit_number', 'logical_unit_number'),
      self.op_param('min_size', 'body', 'min_size', 'min_size'),
      self.op_param('name', 'body', 'name', 'name'),
      self.op_param('performance_policy_id', 'body', 'performance_policy_id', 'performance_policy_id'),
      self.op_param('protection_policy_id', 'body', 'protection_policy_id', 'protection_policy_id'),
      self.op_param('sector_size', 'body', 'sector_size', 'sector_size'),
      self.op_param('size', 'body', 'size', 'size'),
      self.op_param('volume_group_id', 'body', 'volume_group_id', 'volume_group_id'),
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
    context.transport.call_op(path_params, query_params, header_params, body_params, '/volume', 'Post','application/json')
  end


  def self.invoke_update(context, resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation volume_modify")
    path_params = {}
    query_params = {}
    header_params = {}
    header_params["User-Agent"] = ""
    
    op_params = [
      self.op_param('description', 'body', 'description', 'description'),
      self.op_param('expiration_timestamp', 'body', 'expiration_timestamp', 'expiration_timestamp'),
      self.op_param('force', 'body', 'force', 'force'),
      self.op_param('id', 'path', 'id', 'id'),
      self.op_param('is_replication_destination', 'body', 'is_replication_destination', 'is_replication_destination'),
      self.op_param('name', 'body', 'name', 'name'),
      self.op_param('node_affinity', 'body', 'node_affinity', 'node_affinity'),
      self.op_param('performance_policy_id', 'body', 'performance_policy_id', 'performance_policy_id'),
      self.op_param('protection_policy_id', 'body', 'protection_policy_id', 'protection_policy_id'),
      self.op_param('size', 'body', 'size', 'size'),
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
    context.transport.call_op(path_params, query_params, header_params, body_params, '/volume/%{id}', 'Patch','application/json')
  end


  def self.invoke_delete(context, resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation volume_delete")
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
    context.transport.call_op(path_params, query_params, header_params, body_params, '/volume/%{id}', 'Delete','application/json')
  end




  def self.invoke_get_one(context, resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation volume_instance_query")
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
    context.transport.call_op(path_params, query_params, header_params, body_params, '/volume/%{id}', 'Get','application/json')
  end


  def self.fetch_all_as_hash(context)
    items = self.fetch_all(context)
    if items
      items.collect do |item|
        hash = {

          appliance_id: item['appliance_id'],
          creation_timestamp: item['creation_timestamp'],
          description: item['description'],
          expiration_timestamp: item['expiration_timestamp'],
          force: item['force'],
          host_group_id: item['host_group_id'],
          host_id: item['host_id'],
          id: item['id'],
          is_replication_destination: item['is_replication_destination'],
          location_history: item['location_history'],
          logical_unit_number: item['logical_unit_number'],
          migration_session_id: item['migration_session_id'],
          min_size: item['min_size'],
          name: item['name'],
          node_affinity: item['node_affinity'],
          node_affinity_l10n: item['node_affinity_l10n'],
          performance_policy_id: item['performance_policy_id'],
          protection_data: item['protection_data'],
          protection_policy_id: item['protection_policy_id'],
          sector_size: item['sector_size'],
          size: item['size'],
          state: item['state'],
          state_l10n: item['state_l10n'],
          type: item['type'],
          type_l10n: item['type_l10n'],
          volume_group_id: item['volume_group_id'],
          wwn: item['wwn'],
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


  def self.authenticate(_path_params, _query_params, _header_params, _body_params)
    true
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
      return return_value unless return_value.nil?
    end
    ''
  end

  def self.op_param(name, inquery, paramalias, namesnake)
    { name: name, inquery: inquery, paramalias: paramalias, namesnake: namesnake }
  end


end
