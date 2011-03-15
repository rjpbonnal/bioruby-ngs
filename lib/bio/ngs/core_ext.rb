class Thor
  module CoreExt #:nodoc:
    class HashWithIndifferentAccess
      def symbolize_keys
        self.inject({}) do |hash, item|
          hash[item[0].to_sym] = item[1]
          hash
        end
      end
    end #HashWithIndifferentAccess
  end # CoreExt
end #Thor