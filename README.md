Google Apps login for Redmine
=============================

* Changes by Mikrob

Manage import of existing users for Octo with an /opt/match.txt file to be set on the machine.
The file should contains lines with this format :
XXX, xylkdsmqd@email.com
YYY, xyjlmdsqdsq@email.com

If file isn't present behaviour is like forked plugin

This Redmine plugin allows you to login using your Google Apps domain's user.

Changes
--------------------------------------------------

* Full support Redmine 2.x
* "On the fly user creation" option
* Google App authentication mode moved to *Authentication modes* menu in an Administration zone (old LDAP Authentication menu field)
* Test connection link checks openid domain's discovery
* Plugin identifies the user by openid url, not email

Requirements
------------

* Redmine 2.3.x or newer
* Google Apps domain (your @gmail account will not work)

Install
-------

Clone the plugin source code into your Redmine's plugin directory.

    git clone git://github.com/mikrob/redmine_google_apps.git plugins/google_apps

**NOTE:** Make sure the plugin directory is name `google_apps`.

Copy plugin assets to a public directory.

    RAILS_ENV="production" rake redmine:plugins:assets

Setup
-----

Login with your administrator account, go to the Administration section and now you should see the 'Authentication modes' link. Add your Google Apps domain like 'example.com'. (Note, it's not www.example.com).

Logout and go to the login page again. Now a link to login with your Google Apps domain should be visible.

