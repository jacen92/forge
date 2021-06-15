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
if(installedRepositories.contains('pypi-internal') == false)
{
  repository.createPyPiHosted('pypi-internal',        // name
                              "default",              // blobstore
                              true,                   // strict content type validation
                              WritePolicy.ALLOW_ONCE  // writePolicy
                            )
  log.info('Create pypi-internal repository')
}

// create proxy repo of Npm registry
if(installedRepositories.contains('pypi-hub') == false)
{
  repository.createPyPiProxy('pypi-hub',                  // name
                             'https://pypi.org/',         // remoteUrl
                             'default',                   // blobstore
                             true                         // strict content type validation
                             )
   log.info('Create pypi-hub repository')
}

// create group and allow access via http
if(installedRepositories.contains('pypi-all') == false)
{
  def groupMembers = ['pypi-hub', 'pypi-internal']
  repository.createPyPiGroup('pypi-all',                // name
                             groupMembers,              // group of repository
                            'default'                   // blobstore
                             )
  log.info('Create pypi-group repository')
}
