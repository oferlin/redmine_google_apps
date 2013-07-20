require 'redmine'

require_dependency 'google_apps/hooks'

Redmine::Plugin.register :google_apps do
  name 'Google Apps plugin'
  author 'Juan Wajnerman'
  description 'Google Apps user integration'
  version '0.1'
  url 'https://github.com/waj/redmine_google_apps'
  author_url 'http://weblogs.manas.com.ar/waj'
end

Redmine::MenuManager.map(:admin_menu).delete(:ldap_authentication)
Redmine::MenuManager.map(:admin_menu).push :ldap_authentication, {:controller => 'auth_sources', :action => 'index'},
            :html => {:class => 'server_authentication'}, :caption => I18n.t(:label_authentication_modes) 

