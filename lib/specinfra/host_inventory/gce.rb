require 'specinfra/gce_metadata'

module Specinfra
  class HostInventory
    class Gce < Base
      def get
        Specinfra::GceMetadata.new(@host_inventory).get
      end
    end
  end
end
