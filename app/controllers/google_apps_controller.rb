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

  UGGLY_HASH = {
    
  }

  def authenticate(domain)
    attributes = [AX_EMAIL, AX_FIRST, AX_LAST]
    oid = "https://www.google.com/accounts/o8/site-xrds?hd=#{domain.host}"

    if File.exists?("/opt/match.txt") 
      File.readlines("/opt/match.txt").each do |line|
        array = line.chomp("\n").split(",")
        UGGLY_HASH[array[1]] = array[0]
      end
    end

    authenticate_with_open_id(oid, :return_to => request.url, :required => attributes) do |result, identity_url|
      old_user_id, new_user_id = nil
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

          if UGGLY_HASH.size > 0
            old_user_trigram = UGGLY_HASH[email]
            user_old = User.where(:mail => "#{old_user_trigram}@octo.com")
            logger.info "User old : #{user_old.inspect}"
            old_user_id = user_old.first.id if user_old
            logger.info "Old User Id : #{old_user_id}"
          end

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
      if old_user_id && UGGLY_HASH.size > 0
        new_user_id = user.id
        logger.info "New user id : #{user.inspect}"
        logger.info "New user id : #{new_user_id}: #{user.inspect}"
        Issue.where(:author_id => old_user_id).map { |issue| issue.author_id = new_user_id; issue.save! }
        Issue.where(:assigned_to_id => old_user_id).map { |issue| issue.assigned_to_id = new_user_id; issue.save! }
        User.destroy(old_user_id)
      end
    end
  end
end