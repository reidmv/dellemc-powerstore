require 'puppet/resource_api'

# rubocop:disable Layout/EmptyLinesAroundClassBody

# class Puppet::Provider::PowerstoreNfsExport::PowerstoreNfsExport
class Puppet::Provider::PowerstoreNfsExport::PowerstoreNfsExport
  def canonicalize(_context, resources)
    # nout to do here but seems we need to implement it
    resources
  end

  def get(context)
    context.debug('Entered get')
    hash = self.class.fetch_all_as_hash(context)
    context.debug("Completed get, returning hash #{hash}")
    hash
  end

  def set(context, changes, noop: false)
    context.debug('Entered set')

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

      raise("Create failed.  Response is #{response} and body is #{response.body}") unless response.is_a? Net::HTTPSuccess
      should[:ensure] = 'present'
      Puppet.info('Added :ensure to property hash')
    end
  rescue StandardError => ex
    Puppet.alert("Exception during create. The state of the resource is unknown.  ex is #{ex} and backtrace is #{ex.backtrace}")
    raise
  end

  def update(context, name, should)
    context.updating(name) do
      new_hash = build_update_hash(should)
      new_hash.delete('id')
      response = self.class.invoke_update(context, should, new_hash)

      raise("Update failed. The state of the resource is unknown.  Response is #{response} and body is #{response.body}") unless response.is_a? Net::HTTPSuccess
      should[:ensure] = 'present'
      Puppet.info('Added :ensure to property hash')
    end
  rescue StandardError => ex
    Puppet.alert("Exception during update. ex is #{ex} and backtrace is #{ex.backtrace}")
    raise
  end

  def build_create_hash(resource)
    nfs_export = {}
    nfs_export['anonymous_GID'] = resource[:anonymous_gid] unless resource[:anonymous_gid].nil?
    nfs_export['anonymous_UID'] = resource[:anonymous_uid] unless resource[:anonymous_uid].nil?
    nfs_export['default_access'] = resource[:default_access] unless resource[:default_access].nil?
    nfs_export['description'] = resource[:description] unless resource[:description].nil?
    nfs_export['file_system_id'] = resource[:file_system_id] unless resource[:file_system_id].nil?
    nfs_export['is_no_SUID'] = resource[:is_no_suid] unless resource[:is_no_suid].nil?
    nfs_export['min_security'] = resource[:min_security] unless resource[:min_security].nil?
    nfs_export['name'] = resource[:name] unless resource[:name].nil?
    nfs_export['no_access_hosts'] = resource[:no_access_hosts] unless resource[:no_access_hosts].nil?
    nfs_export['path'] = resource[:path] unless resource[:path].nil?
    nfs_export['read_only_hosts'] = resource[:read_only_hosts] unless resource[:read_only_hosts].nil?
    nfs_export['read_only_root_hosts'] = resource[:read_only_root_hosts] unless resource[:read_only_root_hosts].nil?
    nfs_export['read_write_hosts'] = resource[:read_write_hosts] unless resource[:read_write_hosts].nil?
    nfs_export['read_write_root_hosts'] = resource[:read_write_root_hosts] unless resource[:read_write_root_hosts].nil?
    nfs_export
  end
  def build_update_hash(resource)
    nfs_export = {}
    nfs_export['add_no_access_hosts'] = resource[:add_no_access_hosts] unless resource[:add_no_access_hosts].nil?
    nfs_export['add_read_only_hosts'] = resource[:add_read_only_hosts] unless resource[:add_read_only_hosts].nil?
    nfs_export['add_read_only_root_hosts'] = resource[:add_read_only_root_hosts] unless resource[:add_read_only_root_hosts].nil?
    nfs_export['add_read_write_hosts'] = resource[:add_read_write_hosts] unless resource[:add_read_write_hosts].nil?
    nfs_export['add_read_write_root_hosts'] = resource[:add_read_write_root_hosts] unless resource[:add_read_write_root_hosts].nil?
    nfs_export['anonymous_GID'] = resource[:anonymous_gid] unless resource[:anonymous_gid].nil?
    nfs_export['anonymous_UID'] = resource[:anonymous_uid] unless resource[:anonymous_uid].nil?
    nfs_export['default_access'] = resource[:default_access] unless resource[:default_access].nil?
    nfs_export['description'] = resource[:description] unless resource[:description].nil?
    nfs_export['is_no_SUID'] = resource[:is_no_suid] unless resource[:is_no_suid].nil?
    nfs_export['min_security'] = resource[:min_security] unless resource[:min_security].nil?
    nfs_export['no_access_hosts'] = resource[:no_access_hosts] unless resource[:no_access_hosts].nil?
    nfs_export['read_only_hosts'] = resource[:read_only_hosts] unless resource[:read_only_hosts].nil?
    nfs_export['read_only_root_hosts'] = resource[:read_only_root_hosts] unless resource[:read_only_root_hosts].nil?
    nfs_export['read_write_hosts'] = resource[:read_write_hosts] unless resource[:read_write_hosts].nil?
    nfs_export['read_write_root_hosts'] = resource[:read_write_root_hosts] unless resource[:read_write_root_hosts].nil?
    nfs_export['remove_no_access_hosts'] = resource[:remove_no_access_hosts] unless resource[:remove_no_access_hosts].nil?
    nfs_export['remove_read_only_hosts'] = resource[:remove_read_only_hosts] unless resource[:remove_read_only_hosts].nil?
    nfs_export['remove_read_only_root_hosts'] = resource[:remove_read_only_root_hosts] unless resource[:remove_read_only_root_hosts].nil?
    nfs_export['remove_read_write_hosts'] = resource[:remove_read_write_hosts] unless resource[:remove_read_write_hosts].nil?
    nfs_export['remove_read_write_root_hosts'] = resource[:remove_read_write_root_hosts] unless resource[:remove_read_write_root_hosts].nil?
    nfs_export
  end
  # rubocop:disable Lint/UnusedMethodArgument
  def build_delete_hash(resource)
    nfs_export = {}
    nfs_export
  end
  # rubocop:enable Lint/UnusedMethodArgument

  def build_hash(resource)
    nfs_export = {}
    nfs_export['add_no_access_hosts'] = resource[:add_no_access_hosts] unless resource[:add_no_access_hosts].nil?
    nfs_export['add_read_only_hosts'] = resource[:add_read_only_hosts] unless resource[:add_read_only_hosts].nil?
    nfs_export['add_read_only_root_hosts'] = resource[:add_read_only_root_hosts] unless resource[:add_read_only_root_hosts].nil?
    nfs_export['add_read_write_hosts'] = resource[:add_read_write_hosts] unless resource[:add_read_write_hosts].nil?
    nfs_export['add_read_write_root_hosts'] = resource[:add_read_write_root_hosts] unless resource[:add_read_write_root_hosts].nil?
    nfs_export['anonymous_GID'] = resource[:anonymous_gid] unless resource[:anonymous_gid].nil?
    nfs_export['anonymous_UID'] = resource[:anonymous_uid] unless resource[:anonymous_uid].nil?
    nfs_export['default_access'] = resource[:default_access] unless resource[:default_access].nil?
    nfs_export['default_access_l10n'] = resource[:default_access_l10n] unless resource[:default_access_l10n].nil?
    nfs_export['description'] = resource[:description] unless resource[:description].nil?
    nfs_export['file_system_id'] = resource[:file_system_id] unless resource[:file_system_id].nil?
    nfs_export['id'] = resource[:id] unless resource[:id].nil?
    nfs_export['is_no_SUID'] = resource[:is_no_suid] unless resource[:is_no_suid].nil?
    nfs_export['min_security'] = resource[:min_security] unless resource[:min_security].nil?
    nfs_export['min_security_l10n'] = resource[:min_security_l10n] unless resource[:min_security_l10n].nil?
    nfs_export['name'] = resource[:name] unless resource[:name].nil?
    nfs_export['nfs_owner_username'] = resource[:nfs_owner_username] unless resource[:nfs_owner_username].nil?
    nfs_export['no_access_hosts'] = resource[:no_access_hosts] unless resource[:no_access_hosts].nil?
    nfs_export['path'] = resource[:path] unless resource[:path].nil?
    nfs_export['read_only_hosts'] = resource[:read_only_hosts] unless resource[:read_only_hosts].nil?
    nfs_export['read_only_root_hosts'] = resource[:read_only_root_hosts] unless resource[:read_only_root_hosts].nil?
    nfs_export['read_write_hosts'] = resource[:read_write_hosts] unless resource[:read_write_hosts].nil?
    nfs_export['read_write_root_hosts'] = resource[:read_write_root_hosts] unless resource[:read_write_root_hosts].nil?
    nfs_export['remove_no_access_hosts'] = resource[:remove_no_access_hosts] unless resource[:remove_no_access_hosts].nil?
    nfs_export['remove_read_only_hosts'] = resource[:remove_read_only_hosts] unless resource[:remove_read_only_hosts].nil?
    nfs_export['remove_read_only_root_hosts'] = resource[:remove_read_only_root_hosts] unless resource[:remove_read_only_root_hosts].nil?
    nfs_export['remove_read_write_hosts'] = resource[:remove_read_write_hosts] unless resource[:remove_read_write_hosts].nil?
    nfs_export['remove_read_write_root_hosts'] = resource[:remove_read_write_root_hosts] unless resource[:remove_read_write_root_hosts].nil?
    nfs_export
  end

  def self.build_key_values
    key_values = {}
    key_values['api-version'] = 'assets'
    key_values
  end

  def delete(context, should)
    new_hash = build_delete_hash(should)
    response = self.class.invoke_delete(context, should, new_hash)
    raise("Delete failed.  The state of the resource is unknown.  Response is #{response} and body is #{response.body}") unless response.is_a? Net::HTTPSuccess
    should[:ensure] = 'absent'
    Puppet.info "Added 'absent' to property_hash"
  rescue StandardError => ex
    Puppet.alert("Exception during destroy. ex is #{ex} and backtrace is #{ex.backtrace}")
    raise
  end


  def self.invoke_list_all(context, resource = nil, body_params = nil)
    key_values = build_key_values
    Puppet.info('Calling operation nfs_export_collection_query')
    path_params = {}
    query_params = {}
    header_params = {}
    header_params['User-Agent'] = ''

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
    context.transport.call_op(path_params, query_params, header_params, body_params, '/nfs_export', 'Get', 'application/json')
  end


  def self.invoke_create(context, resource = nil, body_params = nil)
    key_values = build_key_values
    Puppet.info('Calling operation nfs_export_create')
    path_params = {}
    query_params = {}
    header_params = {}
    header_params['User-Agent'] = ''

    op_params = [
      op_param('anonymous_GID', 'body', 'anonymous_gid', 'anonymous_gid'),
      op_param('anonymous_UID', 'body', 'anonymous_uid', 'anonymous_uid'),
      op_param('default_access', 'body', 'default_access', 'default_access'),
      op_param('description', 'body', 'description', 'description'),
      op_param('file_system_id', 'body', 'file_system_id', 'file_system_id'),
      op_param('is_no_SUID', 'body', 'is_no_suid', 'is_no_suid'),
      op_param('min_security', 'body', 'min_security', 'min_security'),
      op_param('name', 'body', 'name', 'name'),
      op_param('no_access_hosts', 'body', 'no_access_hosts', 'no_access_hosts'),
      op_param('path', 'body', 'path', 'path'),
      op_param('read_only_hosts', 'body', 'read_only_hosts', 'read_only_hosts'),
      op_param('read_only_root_hosts', 'body', 'read_only_root_hosts', 'read_only_root_hosts'),
      op_param('read_write_hosts', 'body', 'read_write_hosts', 'read_write_hosts'),
      op_param('read_write_root_hosts', 'body', 'read_write_root_hosts', 'read_write_root_hosts'),
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
    context.transport.call_op(path_params, query_params, header_params, body_params, '/nfs_export', 'Post', 'application/json')
  end


  def self.invoke_update(context, resource = nil, body_params = nil)
    key_values = build_key_values
    Puppet.info('Calling operation nfs_export_modify')
    path_params = {}
    query_params = {}
    header_params = {}
    header_params['User-Agent'] = ''

    op_params = [
      op_param('add_no_access_hosts', 'body', 'add_no_access_hosts', 'add_no_access_hosts'),
      op_param('add_read_only_hosts', 'body', 'add_read_only_hosts', 'add_read_only_hosts'),
      op_param('add_read_only_root_hosts', 'body', 'add_read_only_root_hosts', 'add_read_only_root_hosts'),
      op_param('add_read_write_hosts', 'body', 'add_read_write_hosts', 'add_read_write_hosts'),
      op_param('add_read_write_root_hosts', 'body', 'add_read_write_root_hosts', 'add_read_write_root_hosts'),
      op_param('anonymous_GID', 'body', 'anonymous_gid', 'anonymous_gid'),
      op_param('anonymous_UID', 'body', 'anonymous_uid', 'anonymous_uid'),
      op_param('default_access', 'body', 'default_access', 'default_access'),
      op_param('description', 'body', 'description', 'description'),
      op_param('id', 'path', 'id', 'id'),
      op_param('is_no_SUID', 'body', 'is_no_suid', 'is_no_suid'),
      op_param('min_security', 'body', 'min_security', 'min_security'),
      op_param('no_access_hosts', 'body', 'no_access_hosts', 'no_access_hosts'),
      op_param('read_only_hosts', 'body', 'read_only_hosts', 'read_only_hosts'),
      op_param('read_only_root_hosts', 'body', 'read_only_root_hosts', 'read_only_root_hosts'),
      op_param('read_write_hosts', 'body', 'read_write_hosts', 'read_write_hosts'),
      op_param('read_write_root_hosts', 'body', 'read_write_root_hosts', 'read_write_root_hosts'),
      op_param('remove_no_access_hosts', 'body', 'remove_no_access_hosts', 'remove_no_access_hosts'),
      op_param('remove_read_only_hosts', 'body', 'remove_read_only_hosts', 'remove_read_only_hosts'),
      op_param('remove_read_only_root_hosts', 'body', 'remove_read_only_root_hosts', 'remove_read_only_root_hosts'),
      op_param('remove_read_write_hosts', 'body', 'remove_read_write_hosts', 'remove_read_write_hosts'),
      op_param('remove_read_write_root_hosts', 'body', 'remove_read_write_root_hosts', 'remove_read_write_root_hosts'),
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
    context.transport.call_op(path_params, query_params, header_params, body_params, '/nfs_export/%{id}', 'Patch', 'application/json')
  end


  def self.invoke_delete(context, resource = nil, body_params = nil)
    key_values = build_key_values
    Puppet.info('Calling operation nfs_export_delete')
    path_params = {}
    query_params = {}
    header_params = {}
    header_params['User-Agent'] = ''

    op_params = [
      op_param('id', 'path', 'id', 'id'),
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
    context.transport.call_op(path_params, query_params, header_params, body_params, '/nfs_export/%{id}', 'Delete', 'application/json')
  end




  def self.invoke_get_one(context, resource = nil, body_params = nil)
    key_values = build_key_values
    Puppet.info('Calling operation nfs_export_instance_query')
    path_params = {}
    query_params = {}
    header_params = {}
    header_params['User-Agent'] = ''

    op_params = [
      op_param('id', 'path', 'id', 'id'),
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
    context.transport.call_op(path_params, query_params, header_params, body_params, '/nfs_export/%{id}', 'Get', 'application/json')
  end


  def self.fetch_all_as_hash(context)
    items = fetch_all(context)
    if items
      items.map { |item|
        hash = {
          add_no_access_hosts: item['add_no_access_hosts'],
          add_read_only_hosts: item['add_read_only_hosts'],
          add_read_only_root_hosts: item['add_read_only_root_hosts'],
          add_read_write_hosts: item['add_read_write_hosts'],
          add_read_write_root_hosts: item['add_read_write_root_hosts'],
          anonymous_gid: item['anonymous_GID'],
          anonymous_uid: item['anonymous_UID'],
          default_access: item['default_access'],
          default_access_l10n: item['default_access_l10n'],
          description: item['description'],
          file_system_id: item['file_system_id'],
          id: item['id'],
          is_no_suid: item['is_no_SUID'],
          min_security: item['min_security'],
          min_security_l10n: item['min_security_l10n'],
          name: item['name'],
          nfs_owner_username: item['nfs_owner_username'],
          no_access_hosts: item['no_access_hosts'],
          path: item['path'],
          read_only_hosts: item['read_only_hosts'],
          read_only_root_hosts: item['read_only_root_hosts'],
          read_write_hosts: item['read_write_hosts'],
          read_write_root_hosts: item['read_write_root_hosts'],
          remove_no_access_hosts: item['remove_no_access_hosts'],
          remove_read_only_hosts: item['remove_read_only_hosts'],
          remove_read_only_root_hosts: item['remove_read_only_root_hosts'],
          remove_read_write_hosts: item['remove_read_write_hosts'],
          remove_read_write_root_hosts: item['remove_read_write_root_hosts'],
          ensure: 'present',
        }
        Puppet.debug("Adding to collection: #{item}")
        hash
      }.compact
    else
      []
    end
  rescue StandardError => ex
    Puppet.alert("ex is #{ex} and backtrace is #{ex.backtrace}")
    raise
  end

  def self.deep_delete(hash_item, tokens)
    if tokens.size == 1
      if hash_item.is_a?(Array)
        hash_item.map! { |item| deep_delete(item, tokens) }
      else
        hash_item.delete(tokens[0]) unless hash_item.nil? || hash_item[tokens[0]].nil?
      end
    elsif hash_item.is_a?(Array)
      hash_item.map! { |item| deep_delete(item, tokens[1..-1]) }
    else
      hash_item[tokens.first] = deep_delete(hash_item[tokens.first], tokens[1..-1]) unless hash_item.nil? || hash_item[tokens[0]].nil?
    end
    hash_item
  end

  def self.fetch_all(context)
    response = invoke_list_all(context)
    return unless response.is_a? Net::HTTPSuccess
    body = JSON.parse(response.body)
    body # ["value"] if body.is_a? Array # and body.key? "value"
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
    hash.each { |x, v| request[x] = v } if hash
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
