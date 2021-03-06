require "erb"

# TODO - timing between state changes
# TODO - timeout values for a state

# Root ProjectOccam namespace
module ProjectOccam
  module ModelTemplate
    # Root Model object
    # @abstract
    class UbuntuOneric < Ubuntu
      include(ProjectOccam::Logging)

      def initialize(hash)
        super(hash)
        # Static config
        @hidden = false
        @name = "ubuntu_oneiric"
        @description = "Ubuntu Oneiric Model"
        # Metadata vars
        @hostname_prefix = nil
        # State / must have a starting state
        @current_state = :init
        # Image UUID
        @image_uuid = true
        # Image prefix we can attach
        @image_prefix = "os"
        # Enable agent brokers for this model
        @broker_plugin = :agent
        @osversion = 'oneiric'
        @final_state = :os_complete
        from_hash(hash) unless hash == nil
      end

    end
  end
end
