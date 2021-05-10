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
if(installedRepositories.contains('npm-internal') == false)
{
  repository.createNpmHosted('npm-internal',          // name
                              "default",              // blobstore
                              true,                   // strict content type validation
                              WritePolicy.ALLOW_ONCE  // writePolicy
                            )
  log.info('Create npm-internal repository')
}

// create proxy repo of Npm registry
if(installedRepositories.contains('npm-hub') == false)
{
  repository.createNpmProxy('npm-hub',                   // name
                             'https://registry.npm.org', // remoteUrl
                             'default'                   // blobstore
                             )
   log.info('Create npm-hub repository')
}

// create group and allow access via http
if(installedRepositories.contains('npm-all') == false)
{
  def groupMembers = ['npm-hub', 'npm-internal']
  repository.createNpmGroup('npm-all',                  // name
                             groupMembers,              // group of repository
                            'default'                   // blobstore
                             )
  log.info('Create npm-group repository')
}
