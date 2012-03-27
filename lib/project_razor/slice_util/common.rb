# EMC Confidential Information, protected under EMC Bilateral Non-Disclosure Agreement.
# Copyright © 2012 EMC Corporation, All Rights Reserved

require "json"

module ProjectRazor
  module SliceUtil
    module Common


      # Gets a selection of objects for slice
      # @param noun [String] name of the object for logging
      # @param collection [Symbol] collection for object

      def get_object(noun, collection)
        logger.debug "Query #{noun} called"

        # Check if REST-driven request
        if @web_command

          # Get request filter JSON string
          @filter_json_string = @command_array.shift
          # Check if we were passed a filter string
          if @filter_json_string != "{}" && @filter_json_string != nil
            @command = "query_with_filter"
            begin
              # Render our JSON to a Hash
              return return_object_using_filter(JSON.parse(@filter_json_string), collection)
            rescue StandardError => e
              # We caught an error / likely JSON. We return the error text as a Slice error.
              slice_error(e.message, false)
            end
          else
            @command = "#{noun}_query_all"
            return return_objects(collection)
          end
          # Is CLI driven
        else
          return_objects(collection)
        end
      end

      # Return objects using a filter
      # @param filter [Hash] contains key/values used for filtering
      # @param collection [Symbol] collection symbol
      def return_object_using_filter(collection, filter_hash)
        setup_data
        @data.fetch_objects_by_filter(filter_hash, collection)
      end

      # Return all objects (no filtering)
      def return_objects(collection)
        setup_data
        @data.fetch_all_objects(collection)
      end


      def print_object_details_cli(obj)
        obj.instance_variables.each do
        |iv|
          unless iv.to_s.start_with?("@_")
            key = iv.to_s.sub("@", "")
            print "#{key}: "
            print "#{obj.instance_variable_get(iv)}  ".green
          end
        end
        print "\n"
      end




      ########### Common Slice Printing ###########

      # Handles printing of image details to CLI
      # @param [Array] images_array
      #def print_policy_rules(rules_array)
      #  unless @web_command
      #    puts "Policy Rules:"
      #
      #    #unless @verbose
      #    #  rules_array.each do
      #    #  |rule|
      #    #    rule.print_image_info(@data.config.image_svc_path)
      #    #    print "\n"
      #    #  end
      #    #else
      #    rules_array.each { |rule| print_object_details_cli(rule) }
      #  else
      #    rules_array = rules_array.collect { |rule| rule.to_hash }
      #    slice_success(rules_array, false)
      #  end
      #end

      def print_policy_rules(rules_array)
        unless @web_command
          puts "Policy Rules:"
          unless @verbose
            rules_array.each do |rule|
              print "   Order: " + "#{rule.line_number}".yellow
              print "  Label: " + "#{rule.label}".yellow
              print "  Type: " + "#{rule.policy_type}".yellow
              print "  Model label: " + "#{rule.model.label}".yellow
              print "  Model type: " + "#{rule.model.model_type}".yellow
              print "  Tags: " + "#{rule.tags.join(",")}\n".yellow
              print "  UUID: " + "#{rule.uuid}\n\n".yellow
            end
          else
            rules_array.each { |rule| print_object_details_cli(rule) }
          end
        else
          rules_array = rules_array.collect { |rule| rule.to_hash }
          slice_success(rules_array, false)
        end
      end

      def print_policy_rules_bound(rules_array)
        unless @web_command
          puts "Bound Policy:"
          unless @verbose
            rules_array.each do |rule|
              print "    Label: " + "#{rule.label}".yellow
              print "  Type: " + "#{rule.policy_type}".yellow
              print "  Model label: " + "#{rule.model.label}".yellow
              print "  Model type: " + "#{rule.model.model_type}".yellow
              print "  Tags: " + "#{rule.tags.join(",")}\n".yellow
              print "    UUID: " + "#{rule.uuid}".yellow
              print "  Node UUID: " + "#{rule.node_uuid}".yellow
              print "  Current state: " + "#{rule.model.current_state}\n\n".yellow
            end
          else
            rules_array.each { |rule| print_object_details_cli(rule) }
          end
        else
          rules_array = rules_array.collect { |rule| rule.to_hash }
          slice_success(rules_array, false)
        end
      end

      def print_policy_types(types_array)
        unless @web_command
          puts "Valid Policy Types:"
          unless @verbose
            types_array.each { |type| puts "\t#{type.policy_type} ".yellow + " :  #{type.description}" }
          else
            types_array.each { |type| print_object_details_cli(type) }
          end
        else
          types_array = types_array.collect { |type| type.to_hash }
          slice_success(types_array, false)
        end
      end

      def print_model_configs(model_array)
        unless @web_command
          puts "Model Configs:"
          unless @verbose
            model_array.each do |model|
              print "   Label: " + "#{model.label}".yellow
              print "  Type: " + "#{model.name}".yellow
              print "  Description: " + "#{model.description}".yellow
              print "\n  Model UUID: " + "#{model.uuid}".yellow
              print "  Image UUID: " + "#{model.image_uuid}".yellow if model.instance_variable_get(:@image_uuid) != nil
              print "\n\n"
            end
          else
            model_array.each { |model| print_object_details_cli(model) }
          end
        else
          model_array = model_array.collect { |model| model.to_hash }
          slice_success(model_array, false)
        end
      end

      def print_model_types(types_array)
        if @web_command
          types_array = types_array.collect { |type| type.to_hash }
          slice_success(types_array, false)
        else
          puts "Valid Model Types:"
          if @verbose
            types_array.each { |type| print_object_details_cli(type) }
          else
            types_array.each { |type| puts "\t#{type.name} ".yellow + " :  #{type.description}" }
          end
        end
      end

      # Handles printing of image details to CLI
      # @param [Array] images_array
      def print_images(images_array)
        unless @web_command
          puts "Images:"

          unless @verbose
            images_array.each do
            |image|
              image.print_image_info(@data.config.image_svc_path)
              print "\n"
            end
          else
            images_array.each do
            |image|
              image.instance_variables.each do
              |iv|
                unless iv.to_s.start_with?("@_")
                  key = iv.to_s.sub("@", "")
                  print "#{key}: "
                  print "#{image.instance_variable_get(iv)}  ".green
                end
              end
              print "\n"
            end
          end
        else
          images_array = images_array.collect { |image| image.to_hash }
          slice_success(images_array, false)
        end
      end

      # Handles printing of node details to CLI or REST
      # @param [Hash] node_array
      def print_node(node_array)
        unless @web_command
          puts "Nodes:"

          unless @verbose
            node_array.each do
            |node|
              print "\tuuid: "
              print "#{node.uuid}  ".green
              print "last state: "
              print "#{node.last_state}  ".green
              print "name: " unless node.name == nil
              print "#{node.name}  ".green unless node.name == nil
              print "\n"
            end
          else
            node_array.each do
            |node|
              node.instance_variables.each do
              |iv|
                unless iv.to_s.start_with?("@_")
                  key = iv.to_s.sub("@", "")
                  print "#{key}: "
                  print "#{node.instance_variable_get(iv)}  ".green
                end
              end
              print "\n"
            end
          end
        else
          node_array = node_array.collect { |node| node.to_hash }
          slice_success(node_array,false)
        end
      end

      def print_policy_bound_log(bound_policy)
        unless @web_command
          puts "Bound policy log for Node(#{bound_policy.node_uuid}):"

          unless @verbose
            print "\t" + "(Model call) (Action) | (Original state) => (New state) | (Time)\n".yellow.underline
            bound_policy.model.log.each do
            |log_item|
              print "\t#{log_item["method"]}##{log_item["action"]} | ".green
              print "#{log_item["old_state"]} => #{log_item["state"]}".green
              print " | #{Time.at(log_item["timestamp"].to_i)}\n".green
            end

          else
            bound_policy.model.log.each do
            |log_item|
              log_item.instance_variables.each do
              |iv|
                unless iv.to_s.start_with?("@_")
                  key = iv.to_s.sub("@", "")
                  print "#{key}: "
                  print "#{log_item.instance_variable_get(iv)}  ".green
                end
              end
              print "\n"
            end
          end
        else
          slice_success(bound_policy.model.log, false)
        end
      end

      def print_tag_rule_old(rule_array)
        if rule_array.respond_to?(:each)
          rule_array = rule_array.collect { |rule| rule.to_hash }
          slice_success(rule_array, false)
        else
          slice_success(rule_array.to_hash, false)
        end

      end

      def print_tag_rule(object_array)
        unless @web_command
          puts "Tag Rules:"

          unless @verbose

            print_array = []
            header = []
            line_color = :green
            header_color = :white

            object_array.each do
            |rule|
              print_array << rule.print_items
              header = rule.print_header
              line_color = rule.line_color
              header_color = rule.header_color
            end

            print_array.unshift header if header != []
            print_table(print_array, line_color, header_color)
          else
            object_array.each do
            |rule|
              rule.instance_variables.each do
              |iv|
                unless iv.to_s.start_with?("@_")
                  key = iv.to_s.sub("@", "")
                  print "#{key}: "
                  print "#{rule.instance_variable_get(iv)}  ".green
                end
              end
              print "\n"
            end
          end
        else
          object_array = object_array.collect { |rule| rule.to_hash }
          slice_success(object_array, false)
        end
      end

      def print_tag_matcher(object_array)
        unless @web_command
          puts "\t\tTag Matchers:"

          unless @verbose
            object_array.each do
            |matcher|
              print "   Key: " + "#{matcher.key}".yellow
              print "  Compare: " + "#{matcher.compare}".yellow
              print "  Value: " + "#{matcher.value}".yellow
              print "  Inverse: " + "#{matcher.inverse}".yellow
              print "\n"
            end
          else
            object_array.each do
            |matcher|
              matcher.instance_variables.each do
              |iv|
                unless iv.to_s.start_with?("@_")
                  key = iv.to_s.sub("@", "")
                  print "#{key}: "
                  print "#{matcher.instance_variable_get(iv)}  ".green
                end
              end
              print "\n"
            end
          end
        else
          object_array = object_array.collect { |matcher| matcher.to_hash }
          slice_success(object_array, false)
        end
      end

      # Checks to make sure an arg is a format that supports a noun (uuid, etc))
      def validate_arg(arg)
        arg != nil && (arg =~ /^\{.*\}$/) == nil && arg != ''
      end


      def print_object_array(object_array, title = nil)
        unless @web_command
          puts title if title
          unless @verbose
            print_array = []
            header = []
            line_color = :green
            header_color = :white

            object_array.each do
            |rule|
              print_array << rule.print_items
              header = rule.print_header
              line_color = rule.line_color
              header_color = rule.header_color
            end

            print_array.unshift header if header != []
            puts print_table(print_array, line_color, header_color)
          else
            object_array.each do
            |rule|
              rule.instance_variables.each do
              |iv|
                unless iv.to_s.start_with?("@_")
                  key = iv.to_s.sub("@", "")
                  print "#{key}: "
                  print "#{rule.instance_variable_get(iv)}  ".green
                end
              end
              print "\n"
            end
          end
        else
          object_array = object_array.collect { |rule| rule.to_hash }
          slice_success(object_array)
        end
      end


      def print_table(print_array, line_color, header_color)
        table = ""
        print_array.each_with_index do
        |line, li|
          line_string = ""
          line.each_with_index do
          |col, ci|
            max_col = print_array.collect {|x| x[ci].length}.max
            if li == 0
              line_string << "#{col.center(max_col)}  ".send(header_color)
            else
              line_string << "#{col.ljust(max_col)}  ".send(line_color)
            end
          end
          table << line_string + "\n"
        end
        table
      end
    end
  end
end

