import groovy.json.JsonSlurper
import org.sonatype.nexus.security.user.UserManager
import org.sonatype.nexus.security.user.UserNotFoundException
import org.sonatype.nexus.security.user.User

// Arguments are passed through json with following keys:
// - state: 'present' (default) or 'absent'
// - username: unique username
// - first_name: First name of the local user
// - last_name: Last name of the local user
// - email: email of the local user
// - password: Password for the user
// - roles: roles the user is included into

parsed_args = new JsonSlurper().parseText(args)
state = parsed_args.state == null ? 'present' : parsed_args.state
roles = (parsed_args.roles == null ? new HashSet() : parsed_args.roles.toSet())

try {
    User user = security.securitySystem.getUser(parsed_args.username)
    was = user.properties.clone()
    formatted_roles = []
    was.roles.each{v -> formatted_roles.add(v.roleId)}
    was.roles = formatted_roles.clone()
    if ( state == 'absent' ) {
        security.securitySystem.deleteUser(parsed_args.username, UserManager.DEFAULT_SOURCE)
        now = null
    } else {
        user.setFirstName(parsed_args.first_name)
        user.setLastName(parsed_args.last_name)
        user.setEmailAddress(parsed_args.email)
        now = user.properties.clone()
        if (was != now) {
            security.securitySystem.updateUser(user)
        }
        if (was.roles != roles) {
            now.roles = roles.toList()
            security.setUserRoles(parsed_args.username, now.roles)
        }
        // Password change not detectable
        security.securitySystem.changePassword(parsed_args.username, parsed_args.password)
    }
} catch (UserNotFoundException ignored) {
    was = null
    if ( state != 'absent' ) {
        User user = security.addUser(parsed_args.username, parsed_args.first_name, parsed_args.last_name, parsed_args.email, true, parsed_args.password, parsed_args.roles)
        now = user.properties
    } else {
        now = null
    }
}
return was != now
