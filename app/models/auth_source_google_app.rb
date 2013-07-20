class AuthSourceGoogleApp < AuthSource
  unloadable

  validates :host, presence: true, length: { maximum: 60 }

  def test_connection
    @discovery = OpenID::GoogleDiscovery.new
    info = @discovery.perform_discovery(host)
    unless info
      raise AuthSourceException.new(I18n.t(:error_google_apps_discovery_info_not_found, host: host))
    end
  end

  def auth_method_name
    "Google App"
  end
end