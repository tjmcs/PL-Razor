# ProjectOccam Policy Base class
# Root abstract
require 'project_occam/policy/base'

module ProjectOccam
  module PolicyTemplate
    class LinuxDeploy < ProjectOccam::PolicyTemplate::Base
      include(ProjectOccam::Logging)

      # @param hash [Hash]
      def initialize(hash)
        super(hash)
        @hidden = false
        @template = :linux_deploy
        @description = "Policy for deploying a Linux-based operating system."

        from_hash(hash) unless hash == nil
      end


      def mk_call(node)
        model.mk_call(node, @uuid)
      end


      def boot_call(node)
        model.boot_call(node, @uuid)
      end

    end
  end
end
