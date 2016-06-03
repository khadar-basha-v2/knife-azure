#
# Author:: Aliasgar Batterywala (<aliasgar.batterywala@clogeny.com>)
# Copyright:: Copyright (c) 2016 Opscode, Inc.
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../unit/query_azure_mock')
require 'chef/knife/bootstrap'

describe Chef::Knife::AzurermServerCreate do
  include AzureSpecHelper
  include QueryAzureMock
  include AzureUtility

  before do
    @arm_server_instance = create_arm_instance(Chef::Knife::AzurermServerCreate)
    @service = @arm_server_instance.service

    @params = {
      :azure_resource_group_name => Chef::Config[:knife][:azure_resource_group_name],
      :azure_service_location => Chef::Config[:knife][:azure_service_location],
      :azure_vm_name => Chef::Config[:knife][:azure_vm_name],
      :winrm_user => 'winrm_user',
      :ssh_user => Chef::Config[:knife][:ssh_user],
      :ssh_password => 'ssh_password',
      :azure_vm_size => 'azure_vm_size',
      :azure_storage_account => 'azurestorageaccount',
      :azure_storage_account_type => 'azure_storage_account_type',
      :azure_os_disk_name => 'azureosdiskname',
      :azure_os_disk_caching => 'azure_os_disk_caching',
      :azure_os_disk_create_option => 'azure_os_disk_create_option',
      :azure_vnet_name => 'azure_virtual_network_name',
      :azure_vnet_subnet_name => 'azure_subnet_name',
      :rdp_port => '3389',
      :ssh_port => '22',
      :chef_extension_publisher => 'chef_extension_publisher',
      :chef_extension => 'chef_extension',
      :chef_extension_version => '11.10.1',
      :chef_extension_private_param => { :validation_key => '37284723sdjfhsdkfsfd' },
      :latest_chef_extension_version => '1210.12',
      :chef_extension_public_param => {
        :bootstrap_options => {},
        :hints => ['vm_name', 'public_fqdn', 'platform']
      }
    }


    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:read).and_return('foo')
  end

  describe "parameter test:" do
    context "compulsory parameters" do

      it "azure_subscription_id" do
        Chef::Config[:knife].delete(:azure_subscription_id)
        expect(@arm_server_instance.ui).to receive(:error)
        expect {@arm_server_instance.run}.to raise_error(SystemExit)
      end

      it "azure_tenant_id" do
        Chef::Config[:knife].delete(:azure_tenant_id)
        expect(@arm_server_instance.ui).to receive(:error)
        expect {@arm_server_instance.run}.to raise_error(SystemExit)
      end

      it "azure_client_id" do
        Chef::Config[:knife].delete(:azure_client_id)
        expect(@arm_server_instance.ui).to receive(:error)
        expect {@arm_server_instance.run}.to raise_error(SystemExit)
      end

      it "azure_client_secret" do
        Chef::Config[:knife].delete(:azure_client_secret)
        expect(@arm_server_instance.ui).to receive(:error)
        expect {@arm_server_instance.run}.to raise_error(SystemExit)
      end

      it "azure_resource_group_name" do
        Chef::Config[:knife].delete(:azure_resource_group_name)
        expect(@arm_server_instance.ui).to receive(:error)
        expect {@arm_server_instance.run}.to raise_error(SystemExit)
      end

      it "azure_vm_name" do
        Chef::Config[:knife].delete(:azure_vm_name)
        expect(@arm_server_instance.ui).to receive(:error)
        expect {@arm_server_instance.run}.to raise_error(SystemExit)
      end

      it "vm name validation success for Linux" do
        Chef::Config[:knife][:azure_vm_name] = 'test-vm1234'
        allow(@arm_server_instance).to receive(:is_image_windows?).and_return(false)
        expect{@arm_server_instance.validate_params!}.to_not raise_error(ArgumentError)
      end

      it "vm name validation success for Windows" do
        Chef::Config[:knife][:azure_vm_name] = 'test-vm1234'
        allow(@arm_server_instance).to receive(:is_image_windows?).and_return(true)
        expect{@arm_server_instance.validate_params!}.to_not raise_error(ArgumentError)
      end

      it "vm name validation failure for name containing special characters for Linux" do
        Chef::Config[:knife][:azure_vm_name] = 'test_vm1234!@#'
        allow(@arm_server_instance).to receive(:is_image_windows?).and_return(false)
        expect{@arm_server_instance.validate_params!}.to raise_error(ArgumentError)
      end

      it "vm name validation failure for name containing special characters for Windows" do
        Chef::Config[:knife][:azure_vm_name] = 'test_vm1234!@#'
        allow(@arm_server_instance).to receive(:is_image_windows?).and_return(true)
        expect{@arm_server_instance.validate_params!}.to raise_error(ArgumentError)
      end

      it "vm name validation failure for name containing more than 15 characters for Windows" do
        Chef::Config[:knife][:azure_vm_name] = 'testvm123123123123'
        allow(@arm_server_instance).to receive(:is_image_windows?).and_return(true)
        expect{@arm_server_instance.validate_params!}.to raise_error(ArgumentError)
      end

     it "vm name validation failure for name containing more than 64 characters for Linux" do
        Chef::Config[:knife][:azure_vm_name] = 'testvm123123123123123123123123123123123123123123123123123123123123123123123123123123123123123'
        allow(@arm_server_instance).to receive(:is_image_windows?).and_return(false)
        expect{@arm_server_instance.validate_params!}.to raise_error(ArgumentError)
      end

      it "azure_service_location" do
        Chef::Config[:knife].delete(:azure_service_location)
        expect(@arm_server_instance.ui).to receive(:error)
        expect {@arm_server_instance.run}.to raise_error(SystemExit)
      end

      it "azure_image_reference_publisher" do
        Chef::Config[:knife].delete(:azure_image_reference_publisher)
        expect(@arm_server_instance.ui).to receive(:error)
        expect {@arm_server_instance.run}.to raise_error(SystemExit)
      end

      it "azure_image_reference_offer" do
        Chef::Config[:knife].delete(:azure_image_reference_offer)
        expect(@arm_server_instance.ui).to receive(:error)
        expect {@arm_server_instance.run}.to raise_error(SystemExit)
      end

      it "azure_image_reference_sku" do
        Chef::Config[:knife].delete(:azure_image_reference_sku)
        expect(@arm_server_instance.ui).to receive(:error)
        expect {@arm_server_instance.run}.to raise_error(SystemExit)
      end

      it "winrm user and password error if not provided for windows image" do
        Chef::Config[:knife].delete(:winrm_user)
        Chef::Config[:knife].delete(:winrm_password)
        allow(@arm_server_instance).to receive(:is_image_windows?).and_return(true)
        expect{@arm_server_instance.validate_params!}.to raise_error(ArgumentError)
      end

      it "exits when incorrect Ohai Hints are given by the user" do
        @arm_server_instance.config[:ohai_hints] = 'vm_name,mac_address'
        expect(@arm_server_instance.ui).to receive(:error)
        expect {@arm_server_instance.run}.to raise_error(SystemExit)
      end
    end

    context "optional parameters" do
      context "when not given by user" do
        before do
          @vm_name_with_no_special_chars = 'testvm'
          Chef::Config[:knife][:ssh_password] = 'ssh_password'
          @azure_vm_size_default_value = 'Small'
        end

        it "azure_storage_account not provided by user so vm_name gets assigned to it" do
          Chef::Config[:knife].delete(:azure_storage_account)
          @server_params = @arm_server_instance.create_server_def
          expect(@server_params[:azure_storage_account]).to be == @vm_name_with_no_special_chars
        end

        it "azure_os_disk_name not provided by user so vm_name gets assigned to it" do
          Chef::Config[:knife].delete(:azure_os_disk_name)
          @server_params = @arm_server_instance.create_server_def
          expect(@server_params[:azure_os_disk_name]).to be == @vm_name_with_no_special_chars
        end

        it "azure_network_name not provided by user so vm_name gets assigned to it" do
          Chef::Config[:knife].delete(:azure_vnet_name)
          @server_params = @arm_server_instance.create_server_def
          expect(@server_params[:azure_vnet_name]).to be == 'test-vm'
        end

        it "azure_subnet_name not provided by user so vm_name gets assigned to it" do
          Chef::Config[:knife].delete(:azure_vnet_subnet_name)
          Chef::Config[:knife].delete(:azure_vnet_name)
          @server_params = @arm_server_instance.create_server_def
          expect(@server_params[:azure_vnet_subnet_name]).to be == 'test-vm'
        end

        it "should assign default value 1 to the server_count when not provided by the user" do
          @server_params = @arm_server_instance.create_server_def
          expect(@server_params[:server_count]).to be == 1
        end

        after do
          Chef::Config[:knife].delete(:ssh_password)
        end
      end

      context "when given by user" do
        before do
          @vm_name_with_no_special_chars = 'testvm'
          Chef::Config[:knife][:ssh_password] = 'ssh_password'
          Chef::Config[:knife][:azure_storage_account] = 'azure_storage_account'
          @storage_account_name_with_no_special_chars = 'azurestorageaccount'
          Chef::Config[:knife][:azure_os_disk_name] = 'azure_os_disk_name'
          @os_disk_name_with_no_special_chars = 'azureosdiskname'
          Chef::Config[:knife][:azure_vnet_name] = 'azure_vnet_name'
          Chef::Config[:knife][:azure_vnet_subnet_name] = 'azure_vnet_subnet_name'
          Chef::Config[:knife][:azure_vm_size] = 'Medium'
          Chef::Config[:knife][:server_count] = 3
        end

        it "azure_storage_account provided by user so vm_name does not get assigned to it" do
          @server_params = @arm_server_instance.create_server_def
          expect(@server_params[:azure_storage_account]).to be == @storage_account_name_with_no_special_chars
        end

        it "azure_os_disk_name provided by user so vm_name does not get assigned to it" do
          @server_params = @arm_server_instance.create_server_def
          expect(@server_params[:azure_os_disk_name]).to be == @os_disk_name_with_no_special_chars
        end

        it "azure_network_name provided by user so vm_name does not get assigned to it" do
          @server_params = @arm_server_instance.create_server_def
          expect(@server_params[:azure_vnet_name]).to be == 'azure_vnet_name'
        end

        it "azure_subnet_name provided by user so vm_name does not get assigned to it" do
          @server_params = @arm_server_instance.create_server_def
          expect(@server_params[:azure_vnet_subnet_name]).to be == 'azure_vnet_subnet_name'
        end

        it "azure_vm_size provided by user so default value does not get assigned to it" do
          @server_params = @arm_server_instance.create_server_def
          expect(@server_params[:azure_vm_size]).to be == 'Medium'
        end

        it "should set the value of server_count as provided by the user" do
          @server_params = @arm_server_instance.create_server_def
          expect(@server_params[:server_count]).to be == 3
        end

        after do
          Chef::Config[:knife].delete(:ssh_password)
          Chef::Config[:knife].delete(:azure_storage_account)
          Chef::Config[:knife].delete(:azure_os_disk_name)
          Chef::Config[:knife].delete(:azure_network_name)
          Chef::Config[:knife].delete(:azure_subnet_name)
          Chef::Config[:knife].delete(:azure_vm_size)
          Chef::Config[:knife].delete(:server_count)
        end
      end
    end
  end

  describe "server create" do
    before do
      Chef::Config[:knife][:ssh_password] = 'ssh_password'
      Chef::Config[:knife][:winrm_password] = 'winrm_password'

      @resource_client = double("ResourceManagementClient")
      @compute_client = double("ComputeManagementClient")
      @storage_client = double("StorageManagementClient")
      @network_client = double("NetworkResourceClient")

      @resource_promise = double("ResourcePromise")
      @compute_promise = double("ComputePromise")
      @storage_promise = double("StoragePromise")
      @network_promise = double("NetworkPromise")

      allow(@service).to receive(
        :resource_management_client).and_return(
          @resource_client)
      allow(@service).to receive(
        :compute_management_client).and_return(
          @compute_client)
      allow(@service).to receive(
        :storage_management_client).and_return(
          @storage_client)
      allow(@service).to receive(
        :network_resource_client).and_return(
          @network_client)
      allow(@arm_server_instance).to receive(
            :msg_server_summary)
      allow(@arm_server_instance).to receive(
            :set_default_image_reference!)
    end

    describe "resource group" do
      before do
        allow(@compute_client).to receive_message_chain(
          :virtual_machines, :get).and_return(
            @compute_promise)
        allow(@compute_promise).to receive_message_chain(
          :value, :nil?).and_return(
            false)
      end

      it "create resource group when it does not exist already" do
        expect(@resource_client).to receive_message_chain(
          :resource_groups, :check_existence).and_return(
            @resource_promise)
        expect(@resource_promise).to receive_message_chain(
          :value!, :body).and_return(
            false)
        expect(@service).to receive(
          :create_resource_group).exactly(1).and_return(
            stub_resource_group_create_response)
        @arm_server_instance.run
      end

      it "skip resource group creation when it does exist already" do
        expect(@resource_client).to receive_message_chain(
          :resource_groups, :check_existence).and_return(
            @resource_promise)
        expect(@resource_promise).to receive_message_chain(
          :value!, :body).and_return(
            true)
        expect(@service).to_not receive(:create_resource_group)
        @arm_server_instance.run
      end
    end

    describe "virtual machine" do
      context "for Linux" do
        before do
          {
            :azure_image_reference_publisher => 'OpenLogic',
            :azure_image_reference_offer => 'CentOS',
            :azure_image_reference_sku => '6.5',
            :azure_image_reference_version => 'latest',
            :ssh_user => 'ssh_user',
            :azure_chef_extension_version => '1210.12'
          }.each do |key, value|
              Chef::Config[:knife][key] = value
            end

          expect(@arm_server_instance).to receive(
            :is_image_windows?).at_least(3).and_return(false)

          allow(@resource_client).to receive_message_chain(
            :resource_groups, :check_existence).and_return(
              @resource_promise)
          allow(@resource_promise).to receive_message_chain(
            :value!, :body).and_return(
              false)
          allow(@service).to receive(
            :create_resource_group).and_return(
              stub_resource_group_create_response)
        end

        it "create virtual machine when it does not exist already" do
          expect(@compute_client).to receive_message_chain(
            :virtual_machines, :get).and_return(
              @compute_promise)
          expect(@compute_promise).to receive_message_chain(
            :value, :nil?).and_return(
              true)
          expect(@service).to receive(:create_virtual_machine_using_template).exactly(1).and_return(stub_deployments_create_response)
          expect(@service).to receive(:show_server).with("MyVM", "test-rgrp")
          @arm_server_instance.run
        end

        it "skip virtual machine creation when it does exist already" do
          expect(@compute_client).to receive_message_chain(
            :virtual_machines, :get).and_return(
              @compute_promise)
          expect(@compute_promise).to receive_message_chain(
            :value, :nil?).and_return(
              false)
          @arm_server_instance.run
        end
      end

      context "for Windows" do
        before do
          {
            :azure_image_reference_publisher => 'MicrosoftWindowsServer',
            :azure_image_reference_offer => 'WindowsServer',
            :azure_image_reference_sku => '2012-R2-Datacenter',
            :azure_image_reference_version => 'latest',
            :winrm_user => 'winrm_user'
          }.each do |key, value|
              Chef::Config[:knife][key] = value
            end

          expect(@arm_server_instance).to receive(
            :is_image_windows?).at_least(3).and_return(true)

          allow(@resource_client).to receive_message_chain(
            :resource_groups, :check_existence).and_return(
              @resource_promise)
          allow(@resource_promise).to receive_message_chain(
            :value!, :body).and_return(
              false)
          allow(@service).to receive(
            :create_resource_group).and_return(
              stub_resource_group_create_response)
        end

        it "skip virtual machine creation when it does exist already" do
          expect(@compute_client).to receive_message_chain(
            :virtual_machines, :get).and_return(
              @compute_promise)
          expect(@compute_promise).to receive_message_chain(
            :value, :nil?).and_return(
              false)
          @arm_server_instance.run
        end
      end

      context "for multiple VM creation" do
        before do
          Chef::Config[:knife][:server_count] = 3
          Chef::Config[:knife][:azure_chef_extension_version] = '1210.12'

          expect(@arm_server_instance).to receive(
            :is_image_windows?).at_least(3).and_return(false)

          allow(@resource_client).to receive_message_chain(
            :resource_groups, :check_existence).and_return(
              @resource_promise)
          allow(@resource_promise).to receive_message_chain(
            :value!, :body).and_return(
              false)
          allow(@service).to receive(
            :create_resource_group).and_return(
              stub_resource_group_create_response)

          allow(@service).to receive(:virtual_machine_exist?).and_return(false)
        end

        it "uses template for VM creation" do
          deployment = double("deployment", :name => "name", :id => "id", :properties => double)
          @deploy1 = double("deploy1", :resource_type => "Microsoft.Compute/virtualMachines", :resource_name => "MyVM0", :id => "/subscriptions/e00d2b3f-3b94-4dfc-ae8e-ca34c8ba1a99/resourceGroups/vjgroup/providers/Microsoft.Compute/virtualMachines/MyVM0
")
          @deploy2 = double("deploy2", :resource_type => "Microsoft.Compute/virtualMachines", :resource_name => "MyVM1", :id => "/subscriptions/e00d2b3f-3b94-4dfc-ae8e-ca34c8ba1a99/resourceGroups/vjgroup/providers/Microsoft.Compute/virtualMachines/MyVM1
")
          @deploy3 = double("deploy3", :resource_type => "Microsoft.Compute/virtualMachines", :resource_name => "MyVM2", :id => "/subscriptions/e00d2b3f-3b94-4dfc-ae8e-ca34c8ba1a99/resourceGroups/vjgroup/providers/Microsoft.Compute/virtualMachines/MyVM2
")
          allow(deployment.properties).to receive(:dependencies).and_return([@deploy1, @deploy2, @deploy3])
          allow(@service.ui).to receive(:log).at_least(:once)
          expect(@service).to receive(:create_virtual_machine_using_template).and_return(deployment)
          expect(@service).to receive(:show_server).thrice
          expect(@service).not_to receive(:create_virtual_machine)
          expect(@service).not_to receive(:create_vm_extension)
          expect(@service).not_to receive(:vm_details)
          @arm_server_instance.run
        end

        after do
          Chef::Config[:knife].delete(:server_count)
        end
      end
    end

    describe "create_resource_group" do
      it "successfully returns resource group create response" do
        expect(@service).to receive(:resource_management_client).and_return(stub_resource_management_client)
        response = @service.create_resource_group(@params)

        expect(response.name).to_not be nil
        expect(response.id).to_not be nil
        expect(response.location).to_not be nil
      end
    end

    describe "create_single_virtual_machine_using_template" do

      it "creates deployment template and deployment parameters" do
        expect(@service).to receive(:create_deployment_template).with(@params)
        expect(@service).to receive(:create_deployment_parameters)
        expect(@service).to receive(:resource_management_client).and_return(stub_resource_management_client)
        @service.create_virtual_machine_using_template(@params)
      end

      it "successfully returns virtual machine create response" do
        @platform = "Linux"
        allow(@service).to receive(:set_platform).and_return("Linux")
        expect(@service).to receive(:resource_management_client).and_return(stub_resource_management_client)
        response = @service.create_virtual_machine_using_template(@params)
        expect(response.name).to_not be nil
        expect(response.id).to_not be nil
      end
    end

    describe "create_storage_profile" do
      it "successfully returns storage profile response" do
        expect(@service).to receive(
          :create_storage_account).and_return(
            stub_storage_account_create_response)
        expect(@service).to receive(
          :get_vhd).and_return(
            stub_vhd_get_response)
        expect(@service).to receive(
          :get_image_reference).and_return(
            stub_image_reference_response)
        expect(@service).to receive(
          :get_os_disk).and_return(
            stub_os_disk_get_response)
        response = @service.create_storage_profile(@params)
        expect(response.image_reference).to_not be nil
        expect(response.os_disk).to_not be nil
        expect(response.data_disks).to be nil
      end
    end

    describe "vm_details" do
      context 'for Linux' do
        before do
          @service.instance_variable_set(:@platform, "Linux")
        end

        it "successfully returns vm details response" do
          expect(@service).to receive(
            :vm_public_ip).and_return(
              stub_vm_public_ip_get_response)
          expect(@service).to receive(
            :vm_default_port).and_return(
              stub_vm_default_port_get_response("Linux"))
          response = @service.vm_details(stub_virtual_machine_create_response, stub_vm_extension_create_response('NA'), @params)
          expect(response.publicipaddress).to_not be nil
          expect(response.sshport).to be == '22'
        end
      end

      context 'for Windows' do
        before do
          @service.instance_variable_set(:@platform, "Windows")
        end

        it "successfully returns vm details response" do
          expect(@service).to receive(
            :vm_public_ip).and_return(
              stub_vm_public_ip_get_response)
          expect(@service).to receive(
            :vm_default_port).and_return(
              stub_vm_default_port_get_response("Windows"))
          response = @service.vm_details(stub_virtual_machine_create_response, stub_vm_extension_create_response('NA'), @params)
          expect(response.publicipaddress).to_not be nil
          expect(response.rdpport).to be == '3389'
        end
      end
    end

    describe "vm_public_ip" do
      it "successfully returns vm public ip response" do
        expect(@service).to receive(:network_resource_client).and_return(stub_network_resource_client('Windows'))
        response = @service.vm_public_ip(@params)
        expect(response).to be == '1.2.3.4'
      end
    end

    describe "vm_default_port" do
      context "for Linux" do
        before do
          @platform = 'Linux'
        end

        it "successfully returns vm default port response" do
          expect(@service).to receive(:network_resource_client).and_return(stub_network_resource_client(@platform))
          response = @service.vm_default_port(@params)
          expect(response).to be == '22'
        end
      end

      context "for Windows" do
        before do
          @platform = 'Windows'
        end

        it "successfully returns vm default port response" do
          expect(@service).to receive(:network_resource_client).and_return(stub_network_resource_client(@platform))
          response = @service.vm_default_port(@params)
          expect(response).to be == '3389'
        end
      end
    end

    describe "create_storage_account" do
      it "successfully creates storage account" do
        expect(@service).to receive(:storage_management_client).and_return(stub_storage_management_client)
        response = @service.create_storage_account(
          @params[:azure_storage_account],
          @params[:azure_service_location],
          @params[:azure_storage_account_type],
          @params[:azure_resource_group_name])
        expect(response.location).to_not be nil
        expect(response.properties).to_not be nil
        expect(response.properties.account_type).to be == 'azure_storage_account_type'
      end
    end

    describe "get_vhd" do
      it "successfully returns virtual hard disk response" do
        response = @service.get_vhd(
          @params[:azure_storage_account], @params[:azure_os_disk_name])
        expect(response.uri).to be == 'http://azurestorageaccount.blob.core.windows.net/vhds/azureosdiskname.vhd'
      end
    end

    describe "get_image_reference" do
      it "successfully returns image reference response" do
        response = @service.get_image_reference(
          'azure_image_reference_publisher',
          'azure_image_reference_offer',
          'azure_image_reference_sku',
          'azure_image_reference_version')
        expect(response.publisher).to_not be nil
        expect(response.offer).to be == 'azure_image_reference_offer'
        expect(response.sku).to_not be nil
        expect(response.version).to_not be nil
      end
    end

    describe "get_os_disk" do
      it "successfully returns os disk response" do
        response = @service.get_os_disk(
          stub_vhd_get_response,
          @params[:azure_os_disk_name],
          @params[:azure_os_disk_caching],
          @params[:azure_os_disk_create_option])
        expect(response.name).to be == 'azureosdiskname'
        expect(response.vhd.uri).to be == 'vhd_uri'
        expect(response.caching).to_not be nil
        expect(response.create_option).to_not be nil
      end
    end

    describe 'create_network_profile' do
      context 'vnet and subnet does not exist' do
        it 'successfully returns network profile response' do
          # following alllow statements stubs vnet_exist? and subnet_exist? methods
          allow(@network_client).to receive_message_chain(:virtual_networks, :get).and_return(@network_promise)
          allow(@network_promise).to receive_message_chain(:value!, :body).and_return(nil)

          allow(@network_client).to receive_message_chain(:subnets, :get).and_return(@network_promise)
          allow(@network_promise).to receive_message_chain(:value!, :body).and_return(nil)

          @platform = 'Linux'
          expect(@service).to receive(
            :create_virtual_network).and_return(
              stub_virtual_network_create_response)
          expect(@service).to receive(
            :create_subnet).and_return(
              stub_subnet_create_response)
          expect(@service).to receive(
            :create_network_interface).and_return(
              stub_network_interface_create_response)
          response = @service.create_network_profile(@params)
          expect(response.network_interfaces).to_not be nil
          expect(response.network_interfaces).to be_a(Array)
        end
      end

      context 'vnet and subnet already exist' do
        it 'successfully returns network profile response' do
          # following alllow statements stubs vnet_exist? and subnet_exist? methods
          allow(@network_client).to receive_message_chain(:virtual_networks, :get).and_return(@network_promise)
          allow(@network_promise).to receive_message_chain(:value!, :body).and_return(stub_vnet_get_response)

          allow(@network_client).to receive_message_chain(:subnets, :get).and_return(@network_promise)
          allow(@network_promise).to receive_message_chain(:value!, :body).and_return(stub_subnet_get_response)

          @platform = 'Linux'
          expect(@service).not_to receive(:create_virtual_network)
          expect(@service).not_to receive(:create_subnet)
          expect(@service).to receive(:create_network_interface).and_return(stub_network_interface_create_response)
          @service.create_network_profile(@params)
        end
      end
    end

    describe "create_virtual_network" do
      it "successfully creates virtual network" do
        expect(@service).to receive(:network_resource_client).and_return(stub_network_resource_client('NA'))
        response = @service.create_virtual_network(
          @params[:azure_resource_group_name],
          @params[:azure_vnet_name],
          @params[:azure_service_location])
        expect(response.name).to_not be nil
        expect(response.id).to_not be nil
        expect(response.location).to_not be nil
        expect(response.properties).to_not be nil
        expect(response.properties.address_space).to be == 'vnet_address_space'
      end
    end

    describe "create_subnet" do
      it "successfully creates subnet" do
        expect(@service).to receive(:network_resource_client).and_return(stub_network_resource_client('NA'))
        response = @service.create_subnet(
          @params[:azure_resource_group_name],
          @params[:azure_vnet_subnet_name],
          stub_virtual_network_create_response)
        expect(response.name).to_not be nil
        expect(response.id).to_not be nil
        expect(response.location).to_not be nil
        expect(response.properties).to_not be nil
        expect(response.properties.address_prefix).to be == 'sbn_address_prefix'
      end
    end

    describe "create_network_interface" do
      it "successfully creates network interface" do
        expect(@service).to receive(:network_resource_client).and_return(stub_network_resource_client('NA'))
        expect(@service).to receive(
          :create_public_ip_config).and_return(
            stub_public_ip_config_create_response)
        expect(@service).to receive(
          :create_network_security_group).and_return(
            stub_network_security_group_create_response)
        response = @service.create_network_interface(
          @params[:azure_resource_group_name],
          @params[:azure_vm_name],
          @params[:azure_service_location],
          stub_subnet_create_response)
        expect(response.name).to_not be nil
        expect(response.id).to_not be nil
        expect(response.location).to_not be nil
        expect(response.properties).to_not be nil
        expect(response.properties.ip_configurations).to_not be nil
        expect(response.properties.ip_configurations).to be_a(Array)
        expect(response.properties.network_security_group).to_not be nil
      end
    end

    describe "create_public_ip_config" do
      it "successfully creates public ip configuration" do
        expect(@service).to receive(:network_resource_client).and_return(stub_network_resource_client('NA'))
        response = @service.create_public_ip_config(
          @params[:azure_resource_group_name],
          @params[:azure_vm_name],
          @params[:azure_service_location])
        expect(response.name).to_not be nil
        expect(response.id).to_not be nil
        expect(response.location).to_not be nil
        expect(response.properties).to_not be nil
        expect(response.properties.public_ipallocation_method).to_not be nil
        expect(response.properties.public_ipallocation_method).to be == 'Dynamic'
      end
    end

    describe "create_network_security_group" do
      it "successfully creates network security group" do
        @platform = 'NA'
        expect(@service).to receive(:network_resource_client).and_return(stub_network_resource_client('NA'))
        expect(@service).to receive(
          :add_security_rule).and_return(
            stub_default_security_rule_add_response('NA'))
        response = @service.create_network_security_group(
          @params[:azure_resource_group_name],
          @params[:azure_vm_name],
          @params[:azure_service_location])
        expect(response.name).to_not be nil
        expect(response.id).to_not be nil
        expect(response.location).to_not be nil
        expect(response.properties).to_not be nil
        expect(response.properties.default_security_rules).to be_a(Array)
        expect(response.properties.default_security_rules).to be == ['nsg_default_security_rules']
        expect(response.properties.security_rules).to be nil
      end
    end

    describe "add_security_rule" do
      context "for Linux" do
        before do
          @platform = 'Linux'
        end

        it "successfully adds default security rule" do
          expect(@service).to receive(:network_resource_client).and_return(stub_network_resource_client(@platform))
          response = @service.add_security_rule(
            @params[:ssh_port],
            "Port desc",
            "1000",
            @params[:azure_resource_group_name],
            @params[:azure_vm_name],
            stub_network_security_group_create_response)
          expect(response.name).to_not be nil
          expect(response.id).to_not be nil
          expect(response.location).to_not be nil
          expect(response.properties).to_not be nil
          expect(response.properties.description).to be == 'Linux port.'
          expect(response.properties.destination_port_range).to be == '22'
          expect(response.properties.protocol).to be == 'Tcp'
          expect(response.properties.source_port_range).to be == '*'
          expect(response.properties.source_address_prefix).to be == '*'
          expect(response.properties.destination_address_prefix).to be == '*'
          expect(response.properties.access).to be == 'Allow'
          expect(response.properties.priority).to be == 1000
          expect(response.properties.direction).to be == 'Inbound'
        end
      end

      context "for Windows" do
        before do
          @platform = 'Windows'
        end

        it "successfully adds default security rule" do
          expect(@service).to receive(:network_resource_client).and_return(stub_network_resource_client(@platform))
          response = @service.add_security_rule(
            @params[:rdp_port],
            "Port desc",
            "1000",
            @params[:azure_resource_group_name],
            @params[:azure_vm_name],
            stub_network_security_group_create_response)
            expect(response.name).to_not be nil
            expect(response.id).to_not be nil
            expect(response.location).to_not be nil
            expect(response.properties).to_not be nil
            expect(response.properties.description).to be == 'Windows port.'
            expect(response.properties.destination_port_range).to be == '3389'
            expect(response.properties.protocol).to be == 'Tcp'
            expect(response.properties.source_port_range).to be == '*'
            expect(response.properties.source_address_prefix).to be == '*'
            expect(response.properties.destination_address_prefix).to be == '*'
            expect(response.properties.access).to be == 'Allow'
            expect(response.properties.priority).to be == 1000
            expect(response.properties.direction).to be == 'Inbound'
        end
      end
    end

    describe "create_vm_extension" do
      context "when user has supplied chef extension version value" do
        it "successfully creates virtual machine extension with the user supplied version value" do
          expect(@service).to receive(:compute_management_client).and_return(stub_compute_management_client('yes'))
          expect(@service).to_not receive(:get_latest_chef_extension_version)
          response = @service.create_vm_extension(@params)
          expect(response.name).to be == 'test-vm-ext'
          expect(response.id).to_not be nil
          expect(response.type).to be == 'Microsoft.Compute/virtualMachines/extensions'
          expect(response.location).to_not be nil
          expect(response.properties).to_not be nil
          expect(response.properties.publisher).to be == 'Ext_Publisher'
          expect(response.properties.type).to be == 'Ext_Type'
          expect(response.properties.type_handler_version).to be == '11.10.1'
          expect(response.properties.provisioning_state).to be == 'Succeeded'
        end
      end

      context "when user has not supplied chef extension version value" do
        before do
          @params.delete(:chef_extension_version)
        end

        it "successfully creates virtual machine extension with the latest version" do
          expect(@service).to receive(:get_latest_chef_extension_version)
          expect(@service).to receive(:compute_management_client).and_return(stub_compute_management_client('no'))
          response = @service.create_vm_extension(@params)
          expect(response.name).to be == 'test-vm-ext'
          expect(response.id).to_not be nil
          expect(response.type).to be == 'Microsoft.Compute/virtualMachines/extensions'
          expect(response.location).to_not be nil
          expect(response.properties).to_not be nil
          expect(response.properties.publisher).to be == 'Ext_Publisher'
          expect(response.properties.type).to be == 'Ext_Type'
          expect(response.properties.type_handler_version).to be == '1210.12'
          expect(response.properties.provisioning_state).to be == 'Succeeded'
        end
      end
    end

    describe "get_latest_chef_extension_version" do
      it "successfully returns latest Chef Extension version" do
        expect(@service).to receive(:compute_management_client).and_return(stub_compute_management_client('NA'))
        response = @service.get_latest_chef_extension_version(@params)
        expect(response).to be == '1210.12'
      end
    end

    describe "bootstrap protocol cloud-api" do
      before do
        allow(@arm_server_instance).to receive(:msg_server_summary)
        Chef::Config[:knife][:run_list] = ["getting-started"]
        Chef::Config[:knife][:validation_client_name] = "testorg-validator"
        Chef::Config[:knife][:chef_server_url] = "https://api.opscode.com/organizations/testorg"
      end

      after do
        Chef::Config[:knife].delete(:run_list)
        Chef::Config[:knife].delete(:validation_client_name)
        Chef::Config[:knife].delete(:chef_server_url)
      end

      context "parameters test" do
        context "for chef_extension parameter" do
          before do
            allow(@arm_server_instance).to receive(
              :is_image_windows?).and_return(false)
          end

          it "sets correct value for Linux platform" do
            allow(@arm_server_instance).to receive(
              :is_image_windows?).and_return(false)
            @server_params = @arm_server_instance.create_server_def
            expect(@server_params[:chef_extension]).to be == 'LinuxChefClient'
          end

          it "sets correct value for Windows platform" do
            allow(@arm_server_instance).to receive(
              :is_image_windows?).and_return(true)
            @server_params = @arm_server_instance.create_server_def
            expect(@server_params[:chef_extension]).to be == 'ChefClient'
          end
        end

        it "sets correct value for chef_extension_publisher parameter" do
          @server_params = @arm_server_instance.create_server_def
          expect(@server_params[:chef_extension_publisher]).to be == 'Chef.Bootstrap.WindowsAzure'
        end

        it "sets user supplied value for chef_extension_version parameter" do
          Chef::Config[:knife][:azure_chef_extension_version] = '1210.12'
          @server_params = @arm_server_instance.create_server_def
          expect(@server_params[:chef_extension_version]).to be == '1210.12'
        end

        it "sets nil value for chef_extension_version parameter when user has not supplied any value for it" do
          Chef::Config[:knife].delete(:azure_chef_extension_version)
          @server_params = @arm_server_instance.create_server_def
          expect(@server_params[:chef_extension_version]).to be nil
        end

        it "sets correct config for chef_extension_public_param parameter" do
          allow(@arm_server_instance).to receive(
            :get_chef_extension_public_params).and_return(
              'public_params')
          @server_params = @arm_server_instance.create_server_def
          expect(@server_params[:chef_extension_public_param]).to be == 'public_params'
        end

        it "sets correct config for chef_extension_private_param parameter" do
          allow(@arm_server_instance).to receive(
            :get_chef_extension_private_params).and_return(
              'private_params')
          @server_params = @arm_server_instance.create_server_def
          expect(@server_params[:chef_extension_private_param]).to be == 'private_params'
        end
      end

      describe "get_chef_extension_name" do
        context "for Linux" do
          it "successfully returns chef extension name for Linux platform" do
            allow(@arm_server_instance).to receive(
              :is_image_windows?).and_return(false)
            response = @arm_server_instance.get_chef_extension_name
            expect(response).to be == 'LinuxChefClient'
          end
        end

        context "for Windows" do
          it "successfully returns chef extension name for Windows platform" do
            allow(@arm_server_instance).to receive(
              :is_image_windows?).and_return(true)
            response = @arm_server_instance.get_chef_extension_name
            expect(response).to be == 'ChefClient'
          end
        end
      end

      describe "get_chef_extension_publisher" do
        it "successfully returns chef extension publisher" do
          response = @arm_server_instance.get_chef_extension_publisher
          expect(response).to be == 'Chef.Bootstrap.WindowsAzure'
        end
      end

      context "get_chef_extension_public_params" do
        it "should set autoUpdateClient flag to true" do
          @arm_server_instance.config[:auto_update_client] = true
          public_config = {client_rb: "chef_server_url \t \"https://localhost:443\"\nvalidation_client_name\t\"chef-validator\"", runlist: "\"getting-started\"", autoUpdateClient: "true", deleteChefConfig: "false", uninstallChefClient: "false", extendedLogs: "false", custom_json_attr: {}, hints: ["vm_name", "public_fqdn", "platform"], bootstrap_options: { chef_server_url: "https://localhost:443", validation_client_name: "chef-validator"}}

          response = @arm_server_instance.get_chef_extension_public_params
          expect(response).to be == public_config
        end

        it "should set autoUpdateClient flag to false" do
          @arm_server_instance.config[:auto_update_client] = false

          public_config = {client_rb: "chef_server_url \t \"https://localhost:443\"\nvalidation_client_name\t\"chef-validator\"", runlist: "\"getting-started\"", autoUpdateClient: "false", deleteChefConfig: "false", uninstallChefClient: "false", extendedLogs: "false", custom_json_attr: {}, hints: ["vm_name", "public_fqdn", "platform"], bootstrap_options: { chef_server_url: "https://localhost:443", validation_client_name: "chef-validator"}}

          response = @arm_server_instance.get_chef_extension_public_params
          expect(response).to be == public_config
        end

        it "sets deleteChefConfig flag to true" do
          @arm_server_instance.config[:delete_chef_extension_config] = true
          public_config = {client_rb: "chef_server_url \t \"https://localhost:443\"\nvalidation_client_name\t\"chef-validator\"", runlist: "\"getting-started\"", autoUpdateClient: "false", deleteChefConfig: "true", uninstallChefClient: "false", extendedLogs: "false", custom_json_attr: {}, hints: ["vm_name", "public_fqdn", "platform"], bootstrap_options: { chef_server_url: "https://localhost:443", validation_client_name: "chef-validator"}}

          response = @arm_server_instance.get_chef_extension_public_params
          expect(response).to be == public_config

        end

        it "sets deleteChefConfig flag to false" do
          @arm_server_instance.config[:delete_chef_extension_config] = false
          public_config = {client_rb: "chef_server_url \t \"https://localhost:443\"\nvalidation_client_name\t\"chef-validator\"", runlist: "\"getting-started\"", autoUpdateClient: "false", deleteChefConfig: "false", uninstallChefClient: "false", extendedLogs: "false", custom_json_attr: {}, hints: ["vm_name", "public_fqdn", "platform"], bootstrap_options: { chef_server_url: "https://localhost:443", validation_client_name: "chef-validator"}}

          response = @arm_server_instance.get_chef_extension_public_params
          expect(response).to be == public_config
        end

        it "sets bootstrapVersion variable in public_config" do
          @arm_server_instance.config[:bootstrap_version] = '12.4.2'
          public_config = {:client_rb=>"chef_server_url \t \"https://localhost:443\"\nvalidation_client_name\t\"chef-validator\"", :runlist=>"\"getting-started\"", :autoUpdateClient=>"false", :deleteChefConfig=>"false", :uninstallChefClient=>"false", extendedLogs: "false", :custom_json_attr=>{}, :hints=>["vm_name", "public_fqdn", "platform"], :bootstrap_options=>{:chef_server_url=>"https://localhost:443", :validation_client_name=>"chef-validator", :bootstrap_version=>"12.4.2"}}

          response = @arm_server_instance.get_chef_extension_public_params
          expect(response).to be == public_config
        end

        it "sets uninstallChefClient flag to false" do
          @arm_server_instance.config[:uninstall_chef_client] = false
          public_config = {:client_rb=>"chef_server_url \t \"https://localhost:443\"\nvalidation_client_name\t\"chef-validator\"", :runlist=>"\"getting-started\"", :autoUpdateClient=>"false", :deleteChefConfig=>"false", :uninstallChefClient=>"false", extendedLogs: "false", :custom_json_attr=>{}, :hints=>["vm_name", "public_fqdn", "platform"], :bootstrap_options=>{:chef_server_url=>"https://localhost:443", :validation_client_name=>"chef-validator"}}

          response = @arm_server_instance.get_chef_extension_public_params
          expect(response).to be == public_config
        end

        it "sets uninstallChefClient flag to true" do
          @arm_server_instance.config[:uninstall_chef_client] = true
          public_config = {:client_rb=>"chef_server_url \t \"https://localhost:443\"\nvalidation_client_name\t\"chef-validator\"", :runlist=>"\"getting-started\"", :autoUpdateClient=>"false", :deleteChefConfig=>"false", :uninstallChefClient=>"true", extendedLogs: "false", :custom_json_attr=>{}, :hints=>["vm_name", "public_fqdn", "platform"], :bootstrap_options=>{:chef_server_url=>"https://localhost:443", :validation_client_name=>"chef-validator"}}

          response = @arm_server_instance.get_chef_extension_public_params
          expect(response).to be == public_config
        end

        it "sets encrypted_databag_secret in public config" do
          @arm_server_instance.config[:secret] = "secrettext"
          public_config = {:client_rb=>"chef_server_url \t \"https://localhost:443\"\nvalidation_client_name\t\"chef-validator\"", :runlist=>"\"getting-started\"", :autoUpdateClient=>"false", :deleteChefConfig=>"false", :uninstallChefClient=>"false", extendedLogs: "false", :custom_json_attr=>{}, :hints=>["vm_name", "public_fqdn", "platform"], :bootstrap_options=>{:encrypted_data_bag_secret=>"secrettext", :chef_server_url=>"https://localhost:443", :validation_client_name=>"chef-validator"}}

          response = @arm_server_instance.get_chef_extension_public_params
          expect(response).to be == public_config
        end

        it "sets encrypted_databag_secret_file in public config" do
          @arm_server_instance.config[:secret_file] = File.dirname(__FILE__) + "/assets/secret_file"
          public_config = {:client_rb=>"chef_server_url \t \"https://localhost:443\"\nvalidation_client_name\t\"chef-validator\"", :runlist=>"\"getting-started\"", :autoUpdateClient=>"false", :deleteChefConfig=>"false", :uninstallChefClient=>"false", extendedLogs: "false", :custom_json_attr=>{}, :hints=>["vm_name", "public_fqdn", "platform"], :bootstrap_options=>{:encrypted_data_bag_secret=>"PgIxStCmMDsuIw3ygRhmdMtStpc9EMiWisQXoP", :chef_server_url=>"https://localhost:443", :validation_client_name=>"chef-validator"}}
          response = @arm_server_instance.get_chef_extension_public_params
          expect(response).to be == public_config
        end

        it "should set extendedLogs flag to true" do
          @arm_server_instance.config[:extended_logs] = true
          public_config = {client_rb: "chef_server_url \t \"https://localhost:443\"\nvalidation_client_name\t\"chef-validator\"", runlist: "\"getting-started\"", autoUpdateClient: "false", deleteChefConfig: "false", uninstallChefClient: "false", extendedLogs: "true", custom_json_attr: {}, :hints=>["vm_name", "public_fqdn", "platform"], bootstrap_options: { chef_server_url: "https://localhost:443", validation_client_name: "chef-validator"}}
          response = @arm_server_instance.get_chef_extension_public_params
          expect(response).to be == public_config
        end

        context 'service is an instance_of ARM' do
          it 'invokes ohai_hints method' do
            expect(@arm_server_instance).to receive(:ohai_hints)
            @arm_server_instance.get_chef_extension_public_params
          end
        end

        context 'service is not an instance_of ARM' do
          before do
            allow(@service).to receive(:instance_of?).and_return(false)
          end

          it 'does not invoke ohai_hints method' do
            expect(@arm_server_instance).to_not receive(:ohai_hints)
            @arm_server_instance.get_chef_extension_public_params
          end
        end
      end

      context 'when validation key is not present', :chef_gte_12_only do
        before do
          allow(File).to receive(:exist?).and_return(false)
          Chef::Config[:knife] = { chef_node_name: 'foo.example.com' }
        end

        it 'calls get chef extension private params and adds client pem in json object' do
          allow_any_instance_of(Chef::Knife::Bootstrap::ClientBuilder).to receive(:run)
          allow_any_instance_of(Chef::Knife::Bootstrap::ClientBuilder).to receive(:client_path)
          allow(File).to receive(:read).and_return('foo')
          pri_config = { client_pem: 'foo' }
          response = @arm_server_instance.get_chef_extension_private_params
          expect(response).to be == pri_config
        end
      end

      context 'when SSL certificate file option is passed but file does not exist physically' do
        before do
          allow_any_instance_of(Chef::Knife::Bootstrap::ClientBuilder).to receive(:run)
          allow_any_instance_of(Chef::Knife::Bootstrap::ClientBuilder).to receive(:client_path)
          allow(File).to receive(:exist?).and_return(false)
          allow(File).to receive(:read).and_return('foo')
          @arm_server_instance.config[:cert_path] = '~/my_cert.crt'
        end

        it 'raises an error and exits' do
          expect(@arm_server_instance.ui).to receive(:error).with('Specified SSL certificate does not exist.')
          expect { @arm_server_instance.get_chef_extension_private_params }.to raise_error(SystemExit)
        end
      end

      context 'when SSL certificate file option is passed and file exist physically' do
        before do
          allow_any_instance_of(Chef::Knife::Bootstrap::ClientBuilder).to receive(:run)
          allow_any_instance_of(Chef::Knife::Bootstrap::ClientBuilder).to receive(:client_path)
          allow(File).to receive(:exist?).and_return(true)
          allow(File).to receive(:read).and_return('foo')
          @arm_server_instance.config[:cert_path] = '~/my_cert.crt'
        end

        it "copies SSL certificate contents into chef_server_crt attribute of extension's private params" do
          pri_config = { validation_key: 'foo', chef_server_crt: 'foo' }
          response = @arm_server_instance.get_chef_extension_private_params
          expect(response).to be == pri_config
        end
      end

      context "when validation key is not present, using chef 11", :chef_lt_12_only do
        before do
          allow(File).to receive(:exist?).and_return(false)
        end

        it 'raises an exception if validation_key is not present in chef 11' do
          expect(@arm_server_instance.ui).to receive(:error)
          expect { @arm_server_instance.run }.to raise_error(SystemExit)
        end
      end
    end
  end

  describe "set_default_image_reference" do
    it "calls validation for all 4 image reference parameters when os_type without sku is specified by user" do
      @arm_server_instance.config[:azure_image_os_type] = "ubuntu"
      expect(@arm_server_instance).to receive(:validate_arm_keys!).with(
        :azure_image_reference_publisher,
        :azure_image_reference_offer,
        :azure_image_reference_sku,
        :azure_image_reference_version)
      expect(@arm_server_instance.ui).to_not receive(:error)
      @arm_server_instance.send(:set_default_image_reference!)
    end

    it "calls validation for all 4 image reference parameters when os_type with sku is specified by user" do
      @arm_server_instance.config[:azure_image_os_type] = "ubuntu"
      @arm_server_instance.config[:azure_image_reference_sku] = "14.04.2-LTS"
      expect(@arm_server_instance).to receive(:validate_arm_keys!).with(
        :azure_image_reference_publisher,
        :azure_image_reference_offer,
        :azure_image_reference_sku,
        :azure_image_reference_version)
      expect(@arm_server_instance.ui).to_not receive(:error)
      @arm_server_instance.send(:set_default_image_reference!)
    end

    it "validate_arm_keys! raises error and exits if azure_image_os_type is not specified" do
      @arm_server_instance.config.delete(:azure_image_os_type)
      expect(@arm_server_instance.ui).to receive(:error)
      expect{@arm_server_instance.validate_arm_keys!(
        :azure_image_os_type)}.to raise_error(SystemExit)
    end

    it "validate_arm_keys! raises error and exits if image reference parameters are not specified" do
      expect(@arm_server_instance.ui).to receive(:error).thrice
      expect{@arm_server_instance.validate_arm_keys!(
        :azure_image_reference_publisher,
        :azure_image_reference_offer,
        :azure_image_reference_sku,
        :azure_image_reference_version)}.to raise_error(SystemExit)
    end

    it "calls validation for azure_image_os_type if azure_image_os_type and other image reference parameters are not given" do
      @arm_server_instance.config.delete(:azure_image_os_type)
      expect(@arm_server_instance).to receive(
        :validate_arm_keys!).with(
          :azure_image_os_type).and_raise(SystemExit)
      @arm_server_instance.send(:set_default_image_reference!)
    end

    it "raises error and exits if azure_image_os_type or other image reference parameters are not specified" do
      @arm_server_instance.config.delete(:azure_image_os_type)
      expect(@arm_server_instance.ui).to receive(:error)
      expect{@arm_server_instance.send(:set_default_image_reference!)}.to raise_error(SystemExit)
    end

    it "raises error and exits if both azure_image_os_type and other image reference parameters like publisher or offer are specified" do
      @arm_server_instance.config[:azure_image_os_type] = "ubuntu"
      @arm_server_instance.config[:azure_image_reference_publisher] = "azure_image_reference_publisher"
      expect(@arm_server_instance.ui).to receive(:error)
      expect{@arm_server_instance.send(:set_default_image_reference!)}.to raise_error(SystemExit)
    end

    it "sets default image reference parameters for azure_image_os_type=ubuntu" do
      @arm_server_instance.config[:azure_image_os_type] = "ubuntu"
      @arm_server_instance.send(:set_default_image_reference!)
      expect(@arm_server_instance.config[:azure_image_reference_publisher]).to be == "Canonical"
      expect(@arm_server_instance.config[:azure_image_reference_offer]).to be == "UbuntuServer"
      expect(@arm_server_instance.config[:azure_image_reference_sku]).to be == "14.04.2-LTS"
      expect(@arm_server_instance.default_config[:azure_image_reference_version]).to be == 'latest'
    end

    it "sets default image reference parameters for azure_image_os_type=centos" do
      @arm_server_instance.config[:azure_image_os_type] = "centos"
      @arm_server_instance.config[:azure_image_reference_version] = "6.5"
      @arm_server_instance.send(:set_default_image_reference!)
      expect(@arm_server_instance.config[:azure_image_reference_publisher]).to be == "OpenLogic"
      expect(@arm_server_instance.config[:azure_image_reference_offer]).to be == "CentOS"
      expect(@arm_server_instance.config[:azure_image_reference_sku]).to be == "7.1"
      expect(@arm_server_instance.config[:azure_image_reference_version]).to be == '6.5'
    end

    it "sets default image reference parameters for azure_image_os_type=rhel" do
      @arm_server_instance.config[:azure_image_os_type] = "rhel"
      @arm_server_instance.send(:set_default_image_reference!)
      expect(@arm_server_instance.config[:azure_image_reference_publisher]).to be == "RedHat"
      expect(@arm_server_instance.config[:azure_image_reference_offer]).to be == "RHEL"
      expect(@arm_server_instance.config[:azure_image_reference_sku]).to be == "7.2"
      expect(@arm_server_instance.config[:azure_image_reference_version]).to be == 'latest'
    end

    it "sets default image reference parameters for azure_image_os_type=debian" do
      @arm_server_instance.config[:azure_image_os_type] = "debian"
      @arm_server_instance.send(:set_default_image_reference!)
      expect(@arm_server_instance.config[:azure_image_reference_publisher]).to be == "credativ"
      expect(@arm_server_instance.config[:azure_image_reference_offer]).to be == "Debian"
      expect(@arm_server_instance.config[:azure_image_reference_sku]).to be == "7"
      expect(@arm_server_instance.config[:azure_image_reference_version]).to be == 'latest'
    end

    it "sets default image reference parameters for azure_image_os_type=windows" do
      @arm_server_instance.config[:azure_image_os_type] = "windows"
      @arm_server_instance.send(:set_default_image_reference!)
      expect(@arm_server_instance.config[:azure_image_reference_publisher]).to be == "MicrosoftWindowsServer"
      expect(@arm_server_instance.config[:azure_image_reference_offer]).to be == "WindowsServer"
      expect(@arm_server_instance.config[:azure_image_reference_sku]).to be == "2012-R2-Datacenter"
      expect(@arm_server_instance.default_config[:azure_image_reference_version]).to be == 'latest'
    end

    it "overrides sku value for os_type when both azure_image_os_type and azure_image_reference_sku are given" do
      @arm_server_instance.config[:azure_image_os_type] = "windows"
      @arm_server_instance.config[:azure_image_reference_sku] = "2008-R2-SP1"
      @arm_server_instance.send(:set_default_image_reference!)
      expect(@arm_server_instance.config[:azure_image_reference_publisher]).to be == "MicrosoftWindowsServer"
      expect(@arm_server_instance.config[:azure_image_reference_offer]).to be == "WindowsServer"
      expect(@arm_server_instance.config[:azure_image_reference_sku]).to be == "2008-R2-SP1"
      expect(@arm_server_instance.default_config[:azure_image_reference_version]).to be == 'latest'
    end

    it "uses all 4 user supplied values for image reference parameters when os_type is not given" do
      @arm_server_instance.config.delete(:azure_image_os_type)
      @arm_server_instance.config[:azure_image_reference_publisher] = "OpenLogic"
      @arm_server_instance.config[:azure_image_reference_offer] = "CentOS"
      @arm_server_instance.config[:azure_image_reference_sku] = "6.7"
      @arm_server_instance.config[:azure_image_reference_version] = "6.7.20150815"
      @arm_server_instance.send(:set_default_image_reference!)
      expect(@arm_server_instance.config[:azure_image_reference_publisher]).to be == "OpenLogic"
      expect(@arm_server_instance.config[:azure_image_reference_offer]).to be == "CentOS"
      expect(@arm_server_instance.config[:azure_image_reference_sku]).to be == "6.7"
      expect(@arm_server_instance.config[:azure_image_reference_version]).to be == "6.7.20150815"
    end

    it "uses default value for version when other 3 image reference parameters are given by user except os_type" do
      @arm_server_instance.config.delete(:azure_image_os_type)
      @arm_server_instance.config.delete(:azure_image_reference_version)
      @arm_server_instance.config[:azure_image_reference_publisher] = "Canonical"
      @arm_server_instance.config[:azure_image_reference_offer] = "UbuntuServer"
      @arm_server_instance.config[:azure_image_reference_sku] = "12.04.5-LTS"
      @arm_server_instance.send(:set_default_image_reference!)
      expect(@arm_server_instance.config[:azure_image_reference_publisher]).to be == "Canonical"
      expect(@arm_server_instance.config[:azure_image_reference_offer]).to be == "UbuntuServer"
      expect(@arm_server_instance.config[:azure_image_reference_sku]).to be == "12.04.5-LTS"
      expect(@arm_server_instance.default_config[:azure_image_reference_version]).to be == "latest"
    end

    it "throws error if invalid azure_image_os_type is given" do
      @arm_server_instance.config[:azure_image_os_type] = "abc"
      @arm_server_instance.config.delete(:azure_image_reference_publisher)
      @arm_server_instance.config.delete(:azure_image_reference_offer)
      @arm_server_instance.config.delete(:azure_image_reference_sku)
      @arm_server_instance.config.delete(:azure_image_reference_version)
      expect(@arm_server_instance.ui).to receive(:error)
      expect{@arm_server_instance.send(:set_default_image_reference!)}.to raise_error(SystemExit)
    end
  end

  describe "create_multiple_virtual_machine_using_template" do
    before do
      @params[:server_count] = 3
      allow(@service).to receive(:resource_management_client).and_return(@resource_client)
    end

    it "creates deployment template and deployment parameters" do
      expect(@service).to receive(:create_deployment_template).with(@params)
      expect(@service).to receive(:create_deployment_parameters)
      expect(@resource_client).to receive_message_chain(
          :deployments, :create_or_update).and_return(
            @resource_promise)
      @service.create_virtual_machine_using_template(@params)
    end

    it "raises exception if deployment is not successful" do
      expect(@service).to receive(:create_deployment_template).with(@params)
      expect(@service).to receive(:create_deployment_parameters)
      allow(@resource_client).to receive_message_chain(
          :deployments, :create_or_update).and_raise(Exception)
      expect(Chef::Log).to receive(:error)
      expect(Chef::Log).to receive(:debug)
      @service.create_virtual_machine_using_template(@params)
    end

    after do
      @params.delete(:server_count)
    end
  end

  describe "create_deployment_template" do
    before do
      bootstrap_options = {:chef_server_url => "url",
        :validation_client_name => "client_name"}
      @params[:chef_extension_public_param] = { :hints =>
        ['vm_name', 'public_fqdn', 'platform'],
        :bootstrap_options => bootstrap_options
      }

      {
        :azure_image_reference_publisher => 'OpenLogic',
        :azure_image_reference_offer => 'CentOS',
        :azure_image_reference_sku => '6.5',
        :azure_image_reference_version => 'latest',
        :ssh_user => 'ssh_user',
        :server_count => 3
      }.each do |key, value|
          @params[key] = value
        end

      @hints_json = { "vm_name" => "[reference(resourceId('Microsoft.Compute/virtualMachines', concat(variables('vmName'),copyIndex()))).osProfile.computerName]",
        "public_fqdn" => "[reference(resourceId('Microsoft.Network/publicIPAddresses',concat(variables('publicIPAddressName'),copyIndex()))).dnsSettings.fqdn]",
        "platform" => "[concat(reference(resourceId('Microsoft.Compute/virtualMachines', concat(variables('vmName'),copyIndex()))).storageProfile.imageReference.offer, concat(' ', reference(resourceId('Microsoft.Compute/virtualMachines', concat(variables('vmName'),copyIndex()))).storageProfile.imageReference.sku))]"
      }
    end

    it "sets the parameters which are passed in the template" do
      template = @service.create_deployment_template(@params)

      expect(template["variables"]["imagePublisher"]).to be == "OpenLogic"
      expect(template["variables"]["imageOffer"]).to be == "CentOS"
      expect(template["variables"]["OSDiskName"]).to be == "azureosdiskname"
      expect(template["variables"]["nicName"]).to be == "test-vm"
      expect(template["variables"]["subnetName"]).to be == "azure_subnet_name"
      expect(template["variables"]["storageAccountType"]).to be == "azure_storage_account_type"
      expect(template["variables"]["publicIPAddressName"]).to be == "test-vm"
      expect(template["variables"]["vmStorageAccountContainerName"]).to be == "test-vm"
      expect(template["variables"]["vmName"]).to be == "test-vm"
      expect(template["variables"]["vmSize"]).to be == "Standard_D1"
      expect(template["variables"]["virtualNetworkName"]).to be == "azure_virtual_network_name"
      expect(template["variables"]["vmExtensionName"]).to be == "chef_extension"

      extension = ""
      template["resources"].each do |resource|
        extension = resource if resource["type"] == "Microsoft.Compute/virtualMachines/extensions"
      end

      expect(extension["name"]).to be == "[concat(variables('vmName'),copyIndex(),'/', variables('vmExtensionName'))]"
      expect(extension["properties"]["publisher"]).to be == "chef_extension_publisher"
      expect(extension["properties"]["type"]).to be == "chef_extension"
      expect(extension["properties"]["typeHandlerVersion"]).to be == "11.10.1"
      expect(extension["properties"]["settings"]["bootstrap_options"]["chef_node_name"]).to be(nil)
      expect(extension["properties"]["settings"]["bootstrap_options"]["chef_server_url"]).to be == "[parameters('chef_server_url')]"
      expect(extension["properties"]["settings"]["bootstrap_options"]["validation_client_name"]).to be == "[parameters('validation_client_name')]"
      expect(extension["properties"]["settings"]["runlist"]).to be == "[parameters('runlist')]"
      expect(extension["properties"]["settings"]["autoUpdateClient"]).to be == "[parameters('autoUpdateClient')]"
      expect(extension["properties"]["settings"]["deleteChefConfig"]).to be == "[parameters('deleteChefConfig')]"
      expect(extension["properties"]["settings"]["uninstallChefClient"]).to be == "[parameters('uninstallChefClient')]"
      expect(extension["properties"]["settings"]["hints"]).to be == @hints_json
    end

    after do
      @params.delete(:server_count)
    end
  end

  describe "create_deployment_parameters" do
    before do
      bootstrap_options = {:chef_server_url => "url",
        :validation_client_name => "client_name"}
      @params[:chef_extension_public_param] = {:bootstrap_options => bootstrap_options}
      @params[:chef_extension_private_param] = {:validation_key => "validation_key"}
      {
        :azure_image_reference_publisher => 'OpenLogic',
        :azure_image_reference_offer => 'CentOS',
        :azure_image_reference_sku => '6.5',
        :azure_image_reference_version => 'latest',
        :ssh_user => 'ssh_user',
        :server_count => 3
      }.each do |key, value|
          @params[key] = value
        end
    end

    it "sets the parameters which are passed in the template" do
      parameters = @service.create_deployment_parameters(@params, "Windows")

      expect(parameters["adminUserName"]["value"]).to be == "winrm_user"
      expect(parameters["adminPassword"]["value"]).to be == "admin_password"
      expect(parameters["dnsLabelPrefix"]["value"]).to be == "test-vm"
      expect(parameters["imageSKU"]["value"]).to be == "6.5"
      expect(parameters["numberOfInstances"]["value"]).to be == 3
      expect(parameters["validation_key"]["value"]).to be == "validation_key"
      expect(parameters["chef_server_url"]["value"]).to be == "url"
      expect(parameters["validation_client_name"]["value"]).to be == "client_name"
      expect(parameters["runlist"]["value"]).to be == ""
      expect(parameters["autoUpdateClient"]["value"]).to be == ""
      expect(parameters["deleteChefConfig"]["value"]).to be == ""
      expect(parameters["uninstallChefClient"]["value"]).to be == ""
    end

    after do
      @params.delete(:server_count)
    end
  end

  describe "set chef extension version parameter" do
    before do
      @params[:server_count] = 3
      allow(@service).to receive(:resource_management_client).and_return(@resource_client)
    end

    context "when user has supplied chef extension version value" do
      it "successfully creates virtual machine extension with the user supplied version value" do
        expect(@service).to receive(:compute_management_client).and_return(stub_compute_management_client('yes'))
        expect(@service).to_not receive(:get_latest_chef_extension_version)
        expect(params[:chef_extension_version]) == '11.10.1'
        @service.create_virtual_machine_using_template(@params)
      end
    end

    context "when user has not supplied chef extension version value" do
      before do
        @params.delete(:chef_extension_version)
      end

      it "successfully creates virtual machine extension with the latest version" do
        expect(@service).to receive(:get_latest_chef_extension_version)
        expect(@service).to receive(:compute_management_client).and_return(stub_compute_management_client('no'))
        expect(params[:chef_extension_version]) == '1210.12'
        @service.create_virtual_machine_using_template(@params)
      end
    end
  end

  describe 'supported_ohai_hints' do
    it 'returns the list of supported values' do
      response = @arm_server_instance.supported_ohai_hints
      expect(response).to be == ohai_hints_values
    end
  end

  describe 'format_ohai_hints' do
    context 'no input given by user' do
      it 'formats the default input for Ohai Hints where the expected result is same as the default value' do
        response = @arm_server_instance.format_ohai_hints('default')
        expect(response).to be == 'default'
      end
    end

    context 'input given by user in correct format' do
      it 'formats the user input for Ohai Hints where the expected result is same as the user\'s input' do
        response = @arm_server_instance.format_ohai_hints('public_fqdn,vm_name')
        expect(response).to be == 'public_fqdn,vm_name'
      end
    end

    context 'input given by user with incorrect syntax' do
      it 'formats the user input for Ohai Hints where the expected result is the value with correct syntax' do
        response = @arm_server_instance.format_ohai_hints('public_fqdn,vm_name,')
        expect(response).to be == 'public_fqdn,vm_name'
      end
    end

    context 'input given by user in incorrect syntax and incorrect format' do
      it 'formats the user input for Ohai Hints where the expected result is the value in correct syntax and correct format' do
        response = @arm_server_instance.format_ohai_hints('public_fqdn , vm_name, platform ,,')
        expect(response).to be == 'public_fqdn,vm_name,platform'
      end
    end

    context 'input given by user in incorrect format' do
      it 'formats the user input for Ohai Hints where the expected result is the value in correct format' do
        response = @arm_server_instance.format_ohai_hints(' public_fqdn ,platform , vm_name ')
        expect(response).to be == 'public_fqdn,platform,vm_name'
      end
    end
  end

  describe 'is_supported_ohai_hint?' do
    context 'supported value given by user' do
      it 'returns true' do
        response = @arm_server_instance.is_supported_ohai_hint?('platform')
        expect(response).to be true
      end
    end

    context 'unsupported value given by user' do
      it 'returns false' do
        response = @arm_server_instance.is_supported_ohai_hint?('mac_address')
        expect(response).to be false
      end
    end
  end

  describe 'validate_ohai_hints' do
    context 'correct input by user' do
      before do
        @arm_server_instance.config[:ohai_hints] = 'vm_name,platform'
      end

      it 'does not raise error' do
        expect { @arm_server_instance.validate_ohai_hints }.to_not raise_error
      end
    end

    context 'incorrect input by user' do
      before do
        @arm_server_instance.default_config[:ohai_hints] = 'public_fqdn,vm_name,platform,mac_address'
      end

      it 'do raise error' do
        expect { @arm_server_instance.validate_ohai_hints }.to raise_error(
          ArgumentError)
      end
    end
  end

  describe 'default_hint_options' do
    it 'returns the list of default hint values' do
      response = @arm_server_instance.default_hint_options
      expect(response).to be == ohai_hints_values
    end
  end

  describe 'ohai_hints in bootstrapper' do
    context 'no input given by user' do
      it 'returns default values for Ohai Hints' do
        response = @arm_server_instance.ohai_hints
        expect(response).to be == ohai_hints_values
      end
    end

    context 'input given by user' do
      before do
        @arm_server_instance.config[:ohai_hints] = 'platform,vm_name'
      end

      it 'returns the input given by user' do
        response = @arm_server_instance.ohai_hints
        expect(response[0]).to be == 'platform'
        expect(response[1]).to be == 'vm_name'
      end
    end
  end

  describe 'ohai_hints in arm_deployment_template' do
    before do
      @hint_names = ohai_hints_values
      @resource_ids = { "vmId" =>
        "resourceId('Microsoft.Compute/virtualMachines', variables('vmName'))",
        "pubId" => "resourceId('Microsoft.Network/publicIPAddresses',variables('publicIPAddressName'))" }
    end

    it 'returns the json for the given hint names to be set in the template for Ohai Hints configuration' do
      response = @service.ohai_hints(@hint_names, @resource_ids)
      expect(response['vm_name']).to be == "[reference(resourceId('Microsoft.Compute/virtualMachines', variables('vmName'))).osProfile.computerName]"
      expect(response['public_fqdn']).to be == "[reference(resourceId('Microsoft.Network/publicIPAddresses',variables('publicIPAddressName'))).dnsSettings.fqdn]"
      expect(response['platform']).to be == "[concat(reference(resourceId('Microsoft.Compute/virtualMachines', variables('vmName'))).storageProfile.imageReference.offer, concat(' ', reference(resourceId('Microsoft.Compute/virtualMachines', variables('vmName'))).storageProfile.imageReference.sku))]"
    end
  end

  def ohai_hints_values
    [
      'vm_name',
      'public_fqdn',
      'platform'
    ]
  end
end
