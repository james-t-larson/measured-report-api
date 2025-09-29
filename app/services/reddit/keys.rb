module Reddit
  class Keys
    class << self
      def post_history(url:)
        "post_history:link:#{url}"
      end
    end
  end
end
