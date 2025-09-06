module Postprocessors
  class References
    attr_reader :completed

    def initialize(meeting_record, bluf)
      @completed = bluf + references(meeting_record)
    end

    private

    def references(meeting_record)
      references = "\n\n### **References:**\n\n"

      meeting_record.references.map do |reference|
        if reference.class.name == "Video"
          references << "* [#{meeting_record.title} - Recording - #{meeting_record.start_datetime}](#{reference.link})\n"
        end

        if reference.class.name == "Document"
          references << "* [#{meeting_record.title} - #{reference.title} - #{meeting_record.start_datetime}](#{reference.link})\n"
        end
      end

      references
    end
  end
end
