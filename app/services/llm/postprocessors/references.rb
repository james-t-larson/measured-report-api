module Llm
  module Postprocessors
    class References
      attr_reader :completed

      def initialize(meeting_record, bluf)
        @completed = bluf + add_references(meeting_record)
      end

      private

      def add_references(meeting_record)
        references = "### **References:**"

        meeting_record.references.map do |reference|
          if reference.class.name == "Video"
            references << "* [#{meeting_record.title} - Recording - #{meeting_record.start_datetime}](#{reference.link})"
          end

          if reference.class.name == "Document"
            references << "* [#{meeting_record.title} - #{reference.title} - #{meeting_record.start_datetime}](#{reference.link})"
          end
        end

        references
      end
    end
  end
end
