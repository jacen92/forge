import groovy.json.JsonSlurper
import org.sonatype.nexus.repository.Repository
import org.sonatype.nexus.repository.config.WritePolicy
import org.sonatype.nexus.blobstore.api.BlobStoreManager

parsed_args = new JsonSlurper().parseText(args)
List<String> installedRepositories = []
List<String> rawRepositories = ['artifacts']
repository.repositoryManager.browse().each { Repository repo ->
  installedRepositories.add(repo.name)
}

// and create a first raw hosted repository for artifacts using the new blob store
rawRepositories.each { String name ->
  if(installedRepositories.contains(name) == false)
  {
    repository.createRawHosted(name, BlobStoreManager.DEFAULT_BLOBSTORE_NAME)
    log.info('Create ' + name + ' raw repository')
  }
  config = repository.repositoryManager.get(name).configuration.copy()
  config.attributes.storage.writePolicy = WritePolicy.ALLOW_ONCE
  repository.repositoryManager.update(config)
}
