Google Apps login for Redmine
=============================

This Redmine plugin allows you to login using your Google Apps domain's user.

Differences from original plugin by Juan Wajnerman
------------

* Full support Redmine 2.x
* "On the fly user creation" option

Requirements
------------

* Redmine 2.0.x or newer
* The gems 'ruby-openid' and 'ruby-openid-apps-discovery' installed
* ... a Google Apps domain ;-)

Install
-------

Clone the plugin source code into your Redmine's plugin directory.

    git clone git://github.com/dmitrynop/redmine_google_apps.git plugins/google_apps

**NOTE:** Make sure the plugin directory is name `google_apps`.

Setup
-----

Login with your administrator account, go to the Administration section and now you should see the 'Google Apps' link. Add your Google Apps domain like 'example.com'. (Note, it's not www.example.com).

Logout and go to the login page again. Now a link to login with your Google Apps domain should be visible.

Troubleshooting
-----

**NOTE:** Current plugin tested on the Redmine 2.0.3 and trunk version 2.1 at 10 sep 2012

"OpenID verification failed"
* check permissions on [redmine]/tmp/cache - try to set 777
* check gem list, it should contains a ruby-openid-apps-discovery (tested with 1.2.0)
* ...
