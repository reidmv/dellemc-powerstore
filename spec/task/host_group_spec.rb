#!/opt/puppetlabs/puppet/bin/ruby

require 'spec_helper_acceptance_local'
require 'bolt_spec/run'

config_data = {
  'modulepath' => "#{__dir__}/../fixtures/modules",
}

inventory_data = YAML.load_file("#{__dir__}/../fixtures/inventory.yaml")

include BoltSpec::Run

describe 'powerstore_host_group' do
  it 'performs host_group_collection_query' do
    result = run_task('powerstore::host_group_collection_query', 'sut', {}, config: config_data, inventory: inventory_data)
    expect(result[0]['status']).to eq('success')
    expect(result[0]['value']).not_to be_nil
  end
  it 'performs host_group_instance_query' do
    result = run_task('powerstore::host_group_instance_query', 'sut', { 'id' => 'string' }, config: config_data, inventory: inventory_data)
    expect(result[0]['status']).to eq('success')
    expect(result[0]['value']).not_to be_nil
  end
  it 'performs host_group_delete' do
    result = run_task('powerstore::host_group_delete', 'sut', { 'id' => 'string' }, config: config_data, inventory: inventory_data)
    expect(result[0]['status']).to eq('success')
  end
  it 'performs host_group_create' do
    result = run_task('powerstore::host_group_create', 'sut', sample_task_parameters('host_group_create'), config: config_data, inventory: inventory_data)
    expect(result[0]['status']).to eq('success')
  end
  it 'performs host_group_attach' do
    result = run_task('powerstore::host_group_attach', 'sut', sample_task_parameters('host_group_attach'), config: config_data, inventory: inventory_data)
    expect(result[0]['status']).to eq('success')
  end
  it 'performs host_group_detach' do
    result = run_task('powerstore::host_group_detach', 'sut', sample_task_parameters('host_group_detach'), config: config_data, inventory: inventory_data)
    expect(result[0]['status']).to eq('success')
  end
  end
