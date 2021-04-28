import groovy.json.JsonSlurper
import org.sonatype.nexus.security.realm.RealmManager

// Enable Realm for docker token
realmManager = container.lookup(RealmManager.class.getName())
was = realmManager.getConfiguration().getRealmNames()
realmManager.enableRealm("NpmToken")
realmManager.enableRealm("DockerToken")
now = realmManager.getConfiguration().getRealmNames()
return was != now
