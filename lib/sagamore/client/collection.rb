module Sagamore
  class Client
    module Collection
      include ::Enumerable

      ##
      # Iterates over all results from the collection and yields each one to
      # the block, fetching pages as needed.
      def each(&block)
        call_client(:each, &block)
      end

      ##
      # Iterates over each page of results and yields the page to the block,
      # fetching as needed.
      def each_page(&block)
        call_client(:each_page, &block)
      end

      ##
      # Performs a request and returns the number of resources in the collection.
      def count
        call_client(:count)
      end

      ##
      # Returns a new resource with the given filters added to the query string
      def filter(new_filters)
        new_filters = JSON.parse(new_filters) if new_filters.is_a?(String)
        if filters = query['_filter']
          filters = JSON.parse(filters)
          filters = [filters] unless filters.is_a?(Array)
          filters.push(new_filters)
        else
          filters = new_filters
        end
        query('_filter' => filters.to_json)
      end

      ##
      # Returns a new resource with the given sorts added to the query string
      def sort(*sorts)
        query('sort' => sorts)
      end

      ##
      # Performs a request to get the first result of the first page of the 
      # collection and returns it.
      def first
        response = query(:per_page => 1, :page => 1).get!
        response[:results].first
      end

      ##
      # Performs repeated GET requests to the resource and yields results to
      # the given block as long as the response includes more results.
      def while_results(&block)
        loop do
          results = get![:results]
          break if results.nil? || results.empty?
          results.each(&block)
        end
      end
    end
  end
end
