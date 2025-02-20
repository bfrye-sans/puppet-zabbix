# frozen_string_literal: true

require_relative '../zabbix'
Puppet::Type.type(:zabbix_template).provide(:ruby, parent: Puppet::Provider::Zabbix) do
  desc 'Puppet provider that manages Zabbix templates by importing and exporting them in XML format, and creating, updating, or deleting various Zabbix configuration objects. It includes conditional logic based on the Zabbix version being used.'
  confine feature: :zabbixapi

  def create
    zbx.configurations.import(
      format: 'yaml',
      rules: {
        # application parameter was removed on Zabbix 5.4
        (@resource[:zabbix_version] =~ %r{[45]\.[02]} ? :applications : nil) => {
          deleteMissing: (@resource[:delete_missing_applications].nil? ? false : @resource[:delete_missing_applications]),
          createMissing: true
        },
        discoveryRules: {
          createMissing: true,
          deleteMissing: (@resource[:delete_missing_drules].nil? ? false : @resource[:delete_missing_drules]),
          updateExisting: true
        },
        graphs: {
          createMissing: true,
          deleteMissing: (@resource[:delete_missing_graphs].nil? ? false : @resource[:delete_missing_graphs]),
          updateExisting: true
        },
# this object depreciated on zabbix 6+
#        groups: {
#          createMissing: true
#        },
        host_groups: {
          createMissing: true,
          updateExisting: true,
        },
        template_groups: {
          createMissing: true,
          updateExisting: true,
        },
        hosts: {
          createMissing: true,
          updateExisting: true,
        },
        httptests: {
          createMissing: true,
          deleteMissing: (@resource[:delete_missing_httptests].nil? ? false : @resource[:delete_missing_httptests]),
          updateExisting: true
        },
        images: {
          createMissing: true,
          updateExisting: true
        },
        items: {
          createMissing: true,
          deleteMissing: (@resource[:delete_missing_items].nil? ? false : @resource[:delete_missing_items]),
          updateExisting: true
        },
        maps: {
          createMissing: true,
          updateExisting: true
        },
        # screens parameter was removed on Zabbix 5.4
        (@resource[:zabbix_version] =~ %r{[45]\.[02]} ? :screens : nil) => {
          createMissing: true,
          updateExisting: true
        },
        mediaTypes: {
          createMissing: true,
          updateExisting: true,
        },
        templateLinkage: {
          createMissing: true
        },
        templates: {
          createMissing: true,
          updateExisting: true
        },
        templateDashboards: {
          createMissing: true,
          deleteMissing: (@resource[:delete_missing_templatescreens].nil? ? false : @resource[:delete_missing_templatescreens]),
          updateExisting: true
        },
        triggers: {
          createMissing: true,
          deleteMissing: (@resource[:delete_missing_triggers].nil? ? false : @resource[:delete_missing_triggers]),
          updateExisting: true
        },
        valueMaps: {
          createMissing: true
        }
      }.delete_if { |key, _| key.nil? },
      source: template_contents
    )
  end

  def destroy
    id = zbx.templates.get_id(host: @resource[:template_name])
    zbx.templates.delete(id)
  end

  def exists?
    zbx.templates.get_id(host: @resource[:template_name])
  end

  def xml
    zbx.configurations.export(
      format: 'xml',
      options: {
        templates: [zbx.templates.get_id(host: @resource[:template_name])]
      }
    )
  end

  def template_contents
    file = File.new(@resource[:template_source], 'rb')
    file.read
  end
end
