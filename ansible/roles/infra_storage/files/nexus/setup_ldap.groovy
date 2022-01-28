import groovy.json.JsonSlurper
import org.sonatype.nexus.ldap.persist.*
import org.sonatype.nexus.ldap.persist.entity.*
import org.sonatype.nexus.security.SecuritySystem
import org.sonatype.nexus.security.user.UserNotFoundException

// Arguments are passed through json with following keys:
// - host: ldap host:port.
// - bind_name: Username.
// - bind_password: Bind password.
// - search_base: LDAP location.
// - ldap_secure: bool, use ldaps if set.

parsed_args = new JsonSlurper().parseText(args)

String host = parsed_args.host.split(":")[0]
String port = parsed_args.host.split(":")[1]
def ldapManager = container.lookup(LdapConfigurationManager.class.name)

def ldapConfig = ldapManager.newConfiguration()
ldapConfig.setName(host)
log.info('new connection...')

connection = new Connection()
if(parsed_args.ldap_secure.toBoolean())
{
  connection.setHost(new Connection.Host(Connection.Protocol.ldaps, host, port.toInteger()))
}
else {
  connection.setHost(new Connection.Host(Connection.Protocol.ldap, host, port.toInteger()))
}
connection.setConnectionTimeout(30)
connection.setConnectionRetryDelay(300)
connection.setMaxIncidentsCount(3)
connection.setSearchBase(parsed_args.search_base)
connection.setAuthScheme("simple")
connection.setSystemUsername(parsed_args.bind_name)
connection.setSystemPassword(parsed_args.bind_password)
connection.setUseTrustStore(true)
ldapConfig.setConnection(connection)

// Mapping
mapping = new Mapping()
mapping.setUserBaseDn('')
mapping.setUserSubtree(true)
mapping.setUserObjectClass('user')
mapping.setLdapFilter('')
mapping.setUserIdAttribute('sAMAccountName')
mapping.setUserRealNameAttribute('displayname')
mapping.setEmailAddressAttribute('mail')
mapping.setUserPasswordAttribute('')
mapping.setLdapGroupsAsRoles(true)
mapping.setUserMemberOfAttribute('memberOf')
ldapConfig.setMapping(mapping)

log.info('set mapping')

was = null
ldapManager.listLdapServerConfigurations().each { it ->
   if (it.name == host) {
       ldapConfig.id = it.id
       was = [connection: it.connection.properties.findAll {entry -> !(entry.key in ["entityMetadata", "host"])},
              mapping: it.mapping.properties.findAll {entry -> entry.key != "entityMetadata"},
              host: it.connection.host.properties.findAll {entry -> entry.key != "entityMetadata"}]
   }
}

if (!was) {
    ldapManager.addLdapServerConfiguration(ldapConfig)
    try {
        // Request a user to activate LDAP in nexus
        SecuritySystem securitySystem = container.lookup(SecuritySystem.class.name)
        securitySystem.getUser("jenkins")
    } catch (UserNotFoundException ignored) {
    }

    return true
} else {
    ldapManager.updateLdapServerConfiguration(ldapConfig)
    now = [connection: ldapConfig.connection.properties.findAll {entry -> !(entry.key in ["entityMetadata", "host"])},
           mapping: ldapConfig.mapping.properties.findAll {entry -> entry.key != "entityMetadata"},
           host: ldapConfig.connection.host.properties.findAll {entry -> entry.key != "entityMetadata"}]
    return was != now
}
