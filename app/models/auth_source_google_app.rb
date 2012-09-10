class AuthSourceGoogleApp < AuthSource
  unloadable

  validates :name, :host, presence: true, length: { maximum: 60 }

  def test_connection
    true
  end

  def auth_method_name
    "Google App"
  end
  
end