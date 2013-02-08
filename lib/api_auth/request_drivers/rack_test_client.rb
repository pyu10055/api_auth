module ApiAuth

  module RequestDrivers # :nodoc:

    class RackTestClientRequest # :nodoc:

      include ApiAuth::Helpers

      def initialize(request)
        @request = request
        @headers = fetch_headers
        true
      end

      def set_auth_header(header)
        @request.env.merge!({ "Authorization" => header })
        @headers = fetch_headers
        @request
      end

      def calculated_md5
        Digest::MD5.base64digest("")
      end

      def populate_content_md5
        if ['POST', 'PUT'].include?(method)
          @headers["Content-MD5"] = calculated_md5
        end
      end

      def md5_mismatch?
        if ['POST', 'PUT'].include?(method)
          calculated_md5 != content_md5
        else
          false
        end
      end

      def fetch_headers
        @request.metadata[:headers] ||= {}
        capitalize_keys @request.metadata[:headers]
      end

      def content_type
        value = find_header(%w(CONTENT-TYPE CONTENT_TYPE HTTP_CONTENT_TYPE))
        value.nil? ? "" : value
      end

      def content_md5
        value = find_header(%w(CONTENT-MD5 CONTENT_MD5))
        value.nil? ? "" : value
      end

      def request_uri
        @request.url
      end

      def set_date
        @headers.merge!({ "DATE" => Time.now.utc.httpdate })
      end

      def timestamp
        value = find_header(%w(DATE HTTP_DATE))
        value.nil? ? "" : value
      end

      def authorization_header
        find_header %w(Authorization AUTHORIZATION HTTP_AUTHORIZATION)
      end

    private

      def find_header(keys)
        keys.map {|key| @headers[key] }.compact.first
      end

    end

  end

end
