require 'open-uri'

module SigfoxClient

  class Client
    API_SIGFOX_URL = "https://backend.sigfox.com/api/"
    attr_accessor :username, :password

    def initialize(username, password)
      if username.empty? || password.empty?
        raise ArgumentError, 'username and password are required'
      end
      self.password = password
      self.username = username
    end

    def get_groups
      data = get_json('groups')
      puts data
    end

    def get_devicetypes
      res = get_json('devicetypes')
      device_types_json = JSON.parse(res)['data']
      devicetypes = []
      device_types_json.each do |d|
          devicetypes.push SigfoxClient::Devicetype.new(d)
      end
      devicetypes
    end

    def get_devices(devicetype)
      devices_json = []
      api_url = "devicetypes/#{devicetype.id}/devices"
      has_pag = true
      while has_pag
        res = JSON.parse(get_json(api_url))
        devices_json+= res['data']
        has_pag = res['paging'].present?
        api_url = res['paging']['next'].split('/api/').last if has_pag
      end
      devices_json.map! { |d| SigfoxClient::Device.new(d)}
    end


    def get_messages(device)
      res = get_json("devices/#{device.id}/messages")
      messages = []
      if JSON.parse(res)['data']
        messages_json = JSON.parse(res)['data']
        messages_json.each do |m|
          messages.push SigfoxClient::Message.new(m)
        end
      end
      messages
    end


    def get_raw_query(query)
      return get_json(query)
    end

    private

      def get_json(api_uri)
        url = API_SIGFOX_URL + api_uri
        auth = {username: username, password:password}
        result = HTTParty.get(url, {basic_auth: auth, follow_redirects: true} )
        result.body
      end

  end


end
