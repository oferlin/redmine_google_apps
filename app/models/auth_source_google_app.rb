class AuthSourceGoogleApp < AuthSource
  unloadable

  validates :host, presence: true, length: { maximum: 60 }

  def test_connection
    true
  end

  def auth_method_name
    "Google App"
  end
end