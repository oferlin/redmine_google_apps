require 'gapps_openid'

class GoogleAppsController < AccountController
  unloadable

  AX_EMAIL = 'http://axschema.org/contact/email'
  AX_FIRST = 'http://axschema.org/namePerson/first'
  AX_LAST = 'http://axschema.org/namePerson/last'

  def login
    domain = AuthSourceGoogleApp.find params[:id]
    oid = "https://www.google.com/accounts/o8/site-xrds?hd=#{domain.name}"
    attributes = [AX_EMAIL, AX_FIRST, AX_LAST]

    authenticate_with_open_id(oid, :return_to => request.url, :required => attributes) do |result, identity_url, profile_data|
      unless result.successful?
        flash[:error] = result.message
        return redirect_to :controller => :account, :action => :login
      end
      
      ax_response = OpenID::AX::FetchResponse.from_success_response(request.env[Rack::OpenID::RESPONSE])

      email = ax_response[AX_EMAIL].first # profile_data
      first = ax_response[AX_FIRST].first
      last = ax_response[AX_LAST].first

      user = domain.users.find_by_mail email
      if user.nil?
        unless domain.onthefly_register?
          flash[:error] = l(:notice_account_with_googleapps_openid_not_exists)
          return redirect_to :controller => :account, :action => :login
        end

        login = email[/^[^@]*/]
        begin
          user = User.new :firstname => first, :lastname => last, :mail => email
          user.login = login
          user.auth_source = domain
          user.save!
        rescue
          flash[:error] = l(:notice_account_with_googleapps_openid_failed)
          return redirect_to :controller => :account, :action => :login
        end
      end
      user.update_attribute(:last_login_on, Time.now)
      successful_authentication user
    end
  end
end