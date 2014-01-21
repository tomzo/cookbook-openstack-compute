# encoding: UTF-8

require_relative 'spec_helper'

describe 'openstack-compute::libvirt' do
  before do
    compute_stubs

    # This is stubbed b/c systems without '/boot/grub/menul.lst`,
    # fail to pass tests.  This can be removed if a check verifies
    # the files existence prior to File#open.
    ::File.stub(:open).and_call_original
  end

  describe 'suse' do
    before do
      @chef_run = ::ChefSpec::Runner.new ::OPENSUSE_OPTS
      @chef_run.converge 'openstack-compute::libvirt'
    end

    it 'installs libvirt packages' do
      expect(@chef_run).to install_package 'libvirt'
    end

    it 'starts libvirt' do
      expect(@chef_run).to start_service 'libvirtd'
    end

    it 'starts libvirt on boot' do
      expect(@chef_run).to enable_service 'libvirtd'
    end

    it 'does not install /etc/sysconfig/libvirtd' do
      expect(@chef_run).not_to create_template('/etc/sysconfig/libvirtd')
    end

    it 'installs kvm packages' do
      expect(@chef_run).to install_package 'kvm'
    end

    it 'installs qemu packages' do
      @chef_run.node.set['openstack']['compute']['libvirt']['virt_type'] = 'qemu'
      @chef_run.converge 'openstack-compute::libvirt'
      expect(@chef_run).to install_package 'kvm'
    end

    it 'installs xen packages' do
      @chef_run.node.set['openstack']['compute']['libvirt']['virt_type'] = 'xen'
      @chef_run.converge 'openstack-compute::libvirt'
      ['kernel-xen', 'xen', 'xen-tools'].each do |pkg|
        expect(@chef_run).to install_package pkg
      end
    end

    describe 'lxc' do
      before do
        @chef_run.node.set['openstack']['compute']['libvirt']['virt_type'] = 'lxc'
        @chef_run.converge 'openstack-compute::libvirt'
      end

      it 'installs packages' do
        expect(@chef_run).to install_package 'lxc'
      end

      it 'starts boot.cgroupslxc' do
        expect(@chef_run).to start_service 'boot.cgroup'
      end

      it 'starts boot.cgroups on boot' do
        expect(@chef_run).to enable_service 'boot.cgroup'
      end
    end
  end
end
