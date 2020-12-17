import groovy.json.JsonSlurper
import org.sonatype.nexus.security.user.UserManager
import org.sonatype.nexus.security.role.NoSuchRoleException
import org.sonatype.nexus.security.role.Role

// Arguments are passed through json with following keys:
// - state: 'present' (default) or 'absent'
// - id: unique identifier of the role
// - name: name of the role
// - description: description of the role
// - privileges: list of privileges for the role
// - roles: list of included roles for the role

parsed_args = new JsonSlurper().parseText(args)
state = parsed_args.state == null ? 'present' : parsed_args.state
authManager = security.getSecuritySystem().getAuthorizationManager(UserManager.DEFAULT_SOURCE)
privileges = (parsed_args.privileges == null ? new HashSet() : parsed_args.privileges.toSet())
roles = (parsed_args.roles == null ? new HashSet() : parsed_args.roles.toSet())

try {
    Role existingRole = authManager.getRole(parsed_args.id)
    was = existingRole.properties.clone()
    if ( state == 'absent' ) {
        // Not tested
        authManager.deleteRole(parsed_args.id)
        now = null
    } else {
        existingRole.setName(parsed_args.name)
        existingRole.setDescription(parsed_args.description)
        existingRole.setPrivileges(privileges)
        existingRole.setRoles(roles)
        now = existingRole.properties.clone()
        if (was != now) {
            // To avoid increment role version if nothing changed
            authManager.updateRole(existingRole)
        }
    }
} catch (NoSuchRoleException ignored) {
    was = null
    if ( state != 'absent' ) {
        new_role = security.addRole(parsed_args.id, parsed_args.name, parsed_args.description, privileges.toList(), roles.toList())
        now = new_role.properties
    } else {
        now = null
    }
}
return was != now
