require 'net/http'
require 'net/https'
require 'json'
require 'config'

module PaypalAdaptive
  class IpnNotification

    def initialize(env=nil)
      @env = env
      @@config ||= PaypalAdaptive::Config.new(@env)
      @@paypal_base_url ||= @@config.paypal_base_url
      @@ssl_ca_cert_path ||= @@config.ssl_ca_cert_path
      @@ssl_cert_file ||= @@config.ssl_cert_file
    end

    def send_back(data)
      data = "cmd=_notify-validate&#{data}"
      url = URI.parse @@paypal_base_url
      http = Net::HTTP.new(url.host, 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER

      if @@ssl_cert_file
        cert = File.read(@@ssl_cert_file)
        http.cert = OpenSSL::X509::Certificate.new(cert)
        http.key = OpenSSL::PKey::RSA.new(cert)
      end

      if ssl_ca_cert_path
        http.ca_path = @@ssl_ca_cert_path unless @@ssl_ca_cert_path.nil? #/etc/ssl/certs'
      end

      path = "#{@@paypal_base_url}/cgi-bin/webscr"
      resp, response_data = http.post(path, data)

      @verified = response_data == "VERIFIED"
    end

    def verified?
      @verified
    end

  end
end
