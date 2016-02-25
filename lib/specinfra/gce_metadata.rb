# -*- coding: utf-8 -*-

require 'json'

module Specinfra
  class GceMetadata
    def initialize(host_inventory)
      @host_inventory = host_inventory

      @base_uri = 'http://metadata.google.internal/computeMetadata/v1/'
      @headers = { 'Metadata-Flavor' => 'Google' }
      @instance_metadata = {}
      @project_metadata = {}
      @metadata = { instance: @instance_metadata, project: @project_metadata }
    end

    def get
      @metadata[:instance] = @instance_metadata = get_instance_metadata
      @metadata[:project]  = @project_metadata  = get_project_metadata
      self
    end

    def [](key)
      @metadata[key]
    end

    def empty?
      @instance_metadata.empty? && @project_metadata.empty?
    end

    def each
      keys.each do |k|
        yield k, @metadata[k]
      end
    end

    def each_key
      keys.each do |k|
        yield k
      end
    end

    def each_value
      keys.each do |k|
        yield @metadata[k]
      end
    end

    def keys
      @metadata.keys
    end

    def inspect
      @metadata
    end

    private
    def get_instance_metadata
      headers = @headers.map{|k,v| "-H#{k}:#{v}"}.join(' ')
      instance_metadata = JSON.parse(@host_inventory.backend.run_command("curl #{headers} -s #{@base_uri}/instance/?recursive=true").stdout)
      instance_metadata
    end

    def get_project_metadata
      headers = @headers.map{|k,v| "-H#{k}:#{v}"}.join(' ')
      project_metadata = JSON.parse(@host_inventory.backend.run_command("curl #{headers} -s #{@base_uri}/project/?recursive=true").stdout)
      project_metadata
    end
  end
end
