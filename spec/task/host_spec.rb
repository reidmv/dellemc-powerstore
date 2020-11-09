#!/opt/puppetlabs/puppet/bin/ruby

require 'spec_helper_acceptance_local'
require 'bolt_spec/run'

config_data = {
  'modulepath' => "#{__dir__}/../fixtures/modules",
}

inventory_data = YAML.load_file("#{__dir__}/../fixtures/inventory.yaml")

include BoltSpec::Run

describe 'powerstore_host' do
  it 'performs host_collection_query' do
    result = run_task('powerstore::host_collection_query', 'sut', {}, config: config_data, inventory: inventory_data)
    expect(result[0]['status']).to eq('success')
    expect(result[0]['value']).not_to be_nil
  end
  it 'performs host_instance_query' do
    result = run_task('powerstore::host_instance_query', 'sut', { 'id' => 'string' }, config: config_data, inventory: inventory_data)
    expect(result[0]['status']).to eq('success')
    expect(result[0]['value']).not_to be_nil
  end
  it 'performs host_delete' do
    result = run_task('powerstore::host_delete', 'sut', { 'id' => 'string' }, config: config_data, inventory: inventory_data)
    expect(result[0]['status']).to eq('success')
  end
  it 'performs host_create' do
    result = run_task('powerstore::host_create', 'sut', sample_task_parameters('host_create'), config: config_data, inventory: inventory_data)
    expect(result[0]['status']).to eq('success')
  end
  it 'performs host_attach' do
    result = run_task('powerstore::host_attach', 'sut', sample_task_parameters('host_attach'), config: config_data, inventory: inventory_data)
    expect(result[0]['status']).to eq('success')
  end
  it 'performs host_detach' do
    result = run_task('powerstore::host_detach', 'sut', sample_task_parameters('host_detach'), config: config_data, inventory: inventory_data)
    expect(result[0]['status']).to eq('success')
  end
  end
