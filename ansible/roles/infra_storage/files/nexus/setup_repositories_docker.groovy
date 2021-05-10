import groovy.json.JsonSlurper
import org.sonatype.nexus.repository.Repository
import org.sonatype.nexus.repository.config.WritePolicy
import org.sonatype.nexus.blobstore.api.BlobStoreManager

parsed_args = new JsonSlurper().parseText(args)
List<String> installedRepositories = []
repository.repositoryManager.browse().each { Repository repo ->
  installedRepositories.add(repo.name)
}

// create hosted repo and expose via http to allow deployments
if(installedRepositories.contains('docker-internal') == false)
{
  repository.createDockerHosted('docker-internal',             // name
                                parsed_args.docker_push_port.toInteger(),  // httpPort
                                null                           // httpsPort
                                )
  log.info('Create docker-internal repository')
}

// create proxy repo of Docker Hub and enable v1 to get search to work
// no ports since access is only indirectly via group
if(installedRepositories.contains('docker-hub') == false)
{
  repository.createDockerProxy('docker-hub',                   // name
                               'https://registry-1.docker.io', // remoteUrl
                               'HUB',                          // indexType
                               null,                           // indexUrl
                               null,                           // httpPort
                               null,                           // httpsPort
                               BlobStoreManager.DEFAULT_BLOBSTORE_NAME, // blobStoreName
                               true, // strictContentTypeValidation
                               true  // v1Enabled
                               )
   log.info('Create docker-hub repository')
}

// create group and allow access via http
if(installedRepositories.contains('docker-all') == false)
{
  def groupMembers = ['docker-hub', 'docker-internal']
  repository.createDockerGroup('docker-all',                  // name
                               parsed_args.docker_pull_port.toInteger(),  // httpPort
                               null,                          // httpsPort
                               groupMembers,
                               true                           // v1Enabled
                               )
  log.info('Create docker-group repository')
}
