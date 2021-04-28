import groovy.json.JsonSlurper

parsed_args = new JsonSlurper().parseText(args)

if(parsed_args.anonymous_access) {
  security.setAnonymousAccess(true)
  log.info('Anonymous access enabled')
}
else {
  security.setAnonymousAccess(false)
  log.info('Anonymous access disabled')
}

def user = security.securitySystem.getUser(parsed_args.get('admin_name'))
user.setEmailAddress(parsed_args.get('admin_email'))
security.securitySystem.updateUser(user)
security.securitySystem.changePassword(parsed_args.get('admin_name'), parsed_args.get('admin_password'))
log.info('Default email and password of admin user changed')
