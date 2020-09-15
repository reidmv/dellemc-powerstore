require 'puppet/resource_api'
require "pry"

class Puppet::Provider::Powerstorenfs_export::PowerstoreNfs_export
  def canonicalize(context, resources)
    #nout to do here but seems we need to implement it
    resources
  end

  def get(context)
context.debug("Entered get")
      hash = self.class.fetch_all_as_hash
      context.debug("Completed get, returning hash #{hash}")
      hash

  end

  def set(context, changes, noop: false)
    #binding.pry
    context.debug("Entered set")


    changes.each do |name, change|
      #binding.pry
      context.debug("set change with #{name} and #{change}")
      is = change.key?(:is) ? change[:is] : get(context).find { |key| key[:id] == name }
      should = change[:should]

      is = { name: name, ensure: 'absent' } if is.nil?
      should = { name: name, ensure: 'absent' } if should.nil?

      if is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'present'
        create(context, name, should) unless noop
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
        context.deleting(name) do
          delete(should) unless noop
        end
      elsif is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'absent'
        context.failed(name, message: 'Unexpected absent to absent change')
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'present'
        update(context, name, should)
      end
    end
  end

  def create(context, name, should)
    context.creating(name) do
      #binding.pry
      new_hash = build_hash(should)
      response = self.class.invoke_create(should, new_hash)

      if response.is_a? Net::HTTPSuccess
        should[:ensure] = :present
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
      new_hash = build_hash(should)
      response = self.class.invoke_update(should, new_hash)

      if response.is_a? Net::HTTPSuccess
        should[:ensure] = :present
        Puppet.info("Added :ensure to property hash")
      else
        raise("Flush failed.  The state of the resource is unknown.  Response is #{response} and body is #{response.body}")
      end
    end
  rescue Exception => ex
    Puppet.alert("Exception during flush. ex is #{ex} and backtrace is #{ex.backtrace}")
    raise
  end

  def build_hash(resource)
    nfs_export = {}
    nfs_export["add_no_access_hosts"] = resource[:add_no_access_hosts] unless resource[:add_no_access_hosts].nil?
    nfs_export["add_read_only_hosts"] = resource[:add_read_only_hosts] unless resource[:add_read_only_hosts].nil?
    nfs_export["add_read_only_root_hosts"] = resource[:add_read_only_root_hosts] unless resource[:add_read_only_root_hosts].nil?
    nfs_export["add_read_write_hosts"] = resource[:add_read_write_hosts] unless resource[:add_read_write_hosts].nil?
    nfs_export["add_read_write_root_hosts"] = resource[:add_read_write_root_hosts] unless resource[:add_read_write_root_hosts].nil?
    nfs_export["anonymous_GID"] = resource[:anonymous_gid] unless resource[:anonymous_gid].nil?
    nfs_export["anonymous_UID"] = resource[:anonymous_uid] unless resource[:anonymous_uid].nil?
    nfs_export["default_access"] = resource[:default_access] unless resource[:default_access].nil?
    nfs_export["description"] = resource[:description] unless resource[:description].nil?
    nfs_export["file_system_id"] = resource[:file_system_id] unless resource[:file_system_id].nil?
    nfs_export["is_no_SUID"] = resource[:is_no_suid] unless resource[:is_no_suid].nil?
    nfs_export["min_security"] = resource[:min_security] unless resource[:min_security].nil?
    nfs_export["name"] = resource[:name] unless resource[:name].nil?
    nfs_export["no_access_hosts"] = resource[:no_access_hosts] unless resource[:no_access_hosts].nil?
    nfs_export["path"] = resource[:path] unless resource[:path].nil?
    nfs_export["read_only_hosts"] = resource[:read_only_hosts] unless resource[:read_only_hosts].nil?
    nfs_export["read_only_root_hosts"] = resource[:read_only_root_hosts] unless resource[:read_only_root_hosts].nil?
    nfs_export["read_write_hosts"] = resource[:read_write_hosts] unless resource[:read_write_hosts].nil?
    nfs_export["read_write_root_hosts"] = resource[:read_write_root_hosts] unless resource[:read_write_root_hosts].nil?
    nfs_export["remove_no_access_hosts"] = resource[:remove_no_access_hosts] unless resource[:remove_no_access_hosts].nil?
    nfs_export["remove_read_only_hosts"] = resource[:remove_read_only_hosts] unless resource[:remove_read_only_hosts].nil?
    nfs_export["remove_read_only_root_hosts"] = resource[:remove_read_only_root_hosts] unless resource[:remove_read_only_root_hosts].nil?
    nfs_export["remove_read_write_hosts"] = resource[:remove_read_write_hosts] unless resource[:remove_read_write_hosts].nil?
    nfs_export["remove_read_write_root_hosts"] = resource[:remove_read_write_root_hosts] unless resource[:remove_read_write_root_hosts].nil?
    return nfs_export
  end

  def self.build_key_values
    key_values = {}
    
    key_values["api-version"] = "specs"
    key_values
  end

  def destroy
    delete(resource)
  end

  def delete(should)
    new_hash = build_hash(should)
    response = self.class.invoke_delete(should, new_hash)
    if response.is_a? Net::HTTPSuccess
      should[:ensure] = :present
      Puppet.info "Added :absent to property_hash"
    else
      raise("Delete failed.  The state of the resource is unknown.  Response is #{response} and body is #{response.body}")
    end
  rescue Exception => ex
    Puppet.alert("Exception during destroy. ex is #{ex} and backtrace is #{ex.backtrace}")
    raise
  end


  def self.invoke_list_all(resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation nfs_exportCollectionQuery")
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
    self.call_op(path_params, query_params, header_params, body_params, '/nfs_export', 'Get','[application/json]')
  end


  def self.invoke_create(resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation nfs_exportCreate")
    path_params = {}
    query_params = {}
    header_params = {}
    header_params["User-Agent"] = ""
    
    op_params = [
      self.op_param('body', 'body', 'body', 'body'),
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
    self.call_op(path_params, query_params, header_params, body_params, '/nfs_export', 'Post','[application/json]')
  end


  def self.invoke_update(resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation nfs_exportModify")
    path_params = {}
    query_params = {}
    header_params = {}
    header_params["User-Agent"] = ""
    
    op_params = [
      self.op_param('body', 'body', 'body', 'body'),
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
    self.call_op(path_params, query_params, header_params, body_params, '/nfs_export/%{id}', 'Patch','[application/json]')
  end


  def self.invoke_delete(resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation nfs_exportDelete")
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
    self.call_op(path_params, query_params, header_params, body_params, '/nfs_export/%{id}', 'Delete','[application/json]')
  end




  def self.invoke_get_one(resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation nfs_exportInstanceQuery")
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
    self.call_op(path_params, query_params, header_params, body_params, '/nfs_export/%{id}', 'Get','[application/json]')
  end


  def self.fetch_all_as_hash
    items = self.fetch_all
    if items
      items.collect do |item|
        hash = {

          add_no_access_hosts: item["add_no_access_hosts"],
          add_read_only_hosts: item["add_read_only_hosts"],
          add_read_only_root_hosts: item["add_read_only_root_hosts"],
          add_read_write_hosts: item["add_read_write_hosts"],
          add_read_write_root_hosts: item["add_read_write_root_hosts"],
          anonymous_gid: item["anonymous_GID"],
          anonymous_uid: item["anonymous_UID"],
          body: item["body"],
          default_access: item["default_access"],
          description: item["description"],
          file_system_id: item["file_system_id"],
          id: item["id"],
          is_no_suid: item["is_no_SUID"],
          min_security: item["min_security"],
          name: item["name"],
          no_access_hosts: item["no_access_hosts"],
          path: item["path"],
          read_only_hosts: item["read_only_hosts"],
          read_only_root_hosts: item["read_only_root_hosts"],
          read_write_hosts: item["read_write_hosts"],
          read_write_root_hosts: item["read_write_root_hosts"],
          remove_no_access_hosts: item["remove_no_access_hosts"],
          remove_read_only_hosts: item["remove_read_only_hosts"],
          remove_read_only_root_hosts: item["remove_read_only_root_hosts"],
          remove_read_write_hosts: item["remove_read_write_hosts"],
          remove_read_write_root_hosts: item["remove_read_write_root_hosts"],
          ensure: :present,
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

  def self.fetch_all
    response = invoke_list_all
    if response.kind_of? Net::HTTPSuccess
      body = JSON.parse(response.body)
      if body.is_a? Hash and body.key? "value"
        return body["value"]
      end
    end
  end


  def self.authenticate(path_params, query_params, header_params, body_params)
    return true
  end


  def exists?
    return_value = @property_hash[:ensure] && @property_hash[:ensure] != :absent
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

  def self.call_op(path_params, query_params, header_params, body_params, operation_path, operation_verb, parent_consumes)
    uri_string = "https://#{ENV["gen_endpoint"]}#{operation_path}" % path_params
    uri_string = uri_string + "?" + to_query(query_params)
    header_params['Content-Type'] = 'application/json' # first of #{parent_consumes}
    if authenticate(path_params, query_params, header_params, body_params)
      Puppet.info("Authentication succeeded")
      uri = URI(uri_string)
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        if operation_verb == 'Get'
          req = Net::HTTP::Get.new(uri)
        elsif operation_verb == 'Put'
          req = Net::HTTP::Put.new(uri)
        elsif operation_verb == 'Delete'
          req = Net::HTTP::Delete.new(uri)
		elsif operation_verb == 'Post'
          req = Net::HTTP::Post.new(uri)
        end
        add_keys_to_request(req, header_params)
        if body_params
          req.body = body_params.to_json
        end
        Puppet.debug("URI is (#{operation_verb}) #{uri}, body is #{body_params}, query params are #{query_params}, headers are #{header_params}")
        response = http.request req # Net::HTTPResponse object
        Puppet.debug("response code is #{response.code} and body is #{response.body}")
        success = response.is_a? Net::HTTPSuccess
        Puppet.info("Called (#{operation_verb}) endpoint at #{uri}, success was #{success}")
        return response
      end
    end
  end

end