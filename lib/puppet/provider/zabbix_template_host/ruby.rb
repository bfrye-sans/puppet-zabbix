# frozen_string_literal: true

require_relative '../zabbix'
Puppet::Type.type(:zabbix_template_host).provide(:ruby, parent: Puppet::Provider::Zabbix) do
  desc 'Puppet provider that manages the association between Zabbix templates and hosts. It allows creating, checking the existence of, and deleting the association between a Zabbix template and a host, using the Zabbix API.'
  confine feature: :zabbixapi
  def template_name
    @template_name ||= @resource[:name].split('@')[0]
  end

  def template_id
    @template_id ||= zbx.templates.get_id(host: template_name)
  end

  def hostname
    @hostname ||= @resource[:name].split('@')[1]
  end

  def hostid
    @hostid ||= zbx.hosts.get_id(host: hostname)
  end

  def create
    zbx.hosts.link_templates(
    # mass_add depreciated in favor of link_templates for zabbix api 6.4
    # zbx.templates.mass_add(
      hosts_id: [hostid],
      templates_id: [template_id]
    )
  end

  def exists?
    zbx.templates.get_ids_by_host(hostids: [hostid]).include?(template_id.to_s)
  end

  def destroy
    zbx.templates.mass_remove(
      hosts_id: [hostid],
      templates_id: [template_id]
    )
  end
end
