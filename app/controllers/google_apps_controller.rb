require 'gapps_openid'

class GoogleAppsController < AccountController
  unloadable

  AX_EMAIL = 'http://axschema.org/contact/email'
  AX_FIRST = 'http://axschema.org/namePerson/first'
  AX_LAST = 'http://axschema.org/namePerson/last'

  def login
    domain = AuthSourceGoogleApp.find params[:id]
    authenticate domain
  end

  protected

  def authenticate(domain)
    attributes = [AX_EMAIL, AX_FIRST, AX_LAST]
    oid = "https://www.google.com/accounts/o8/site-xrds?hd=#{domain.host}"

    authenticate_with_open_id(oid, :return_to => request.url, :required => attributes) do |result, identity_url|
      if result.successful?
        user = User.find_or_initialize_by_identity_url(identity_url)

        if user.new_record?
          ax_response = OpenID::AX::FetchResponse.from_success_response(request.env[Rack::OpenID::RESPONSE])
          email, first, last = [ax_response[AX_EMAIL], ax_response[AX_FIRST], ax_response[AX_LAST]].map(&:first)

          user.login       = email[/^[^@]*/] unless email.nil?
          user.mail        = email
          user.firstname   = first
          user.lastname    = last
          user.auth_source = domain
          user.random_password
          user.register

          if domain.onthefly_register?
            register_automatically(user) do
              onthefly_creation_failed(user)
            end
          else
            flash[:error] = l(:notice_account_with_googleapps_openid_not_exists)
            return redirect_to :controller => :account, :action => :login
          end

        else
          # Existing record
          if user.active?
            successful_authentication(user)
          else
            account_pending
          end
        end
      else
        logger.warn "Failed login with domain '#{domain.host}' from #{request.remote_ip} at #{Time.now.utc}"
        flash[:error] = result.message
        return redirect_to :controller => :account, :action => :login
      end
    end
  end
end