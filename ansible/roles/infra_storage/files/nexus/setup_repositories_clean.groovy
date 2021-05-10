import groovy.json.JsonSlurper
import org.sonatype.nexus.repository.Repository
import org.sonatype.nexus.repository.config.WritePolicy
import org.sonatype.nexus.blobstore.api.BlobStoreManager

parsed_args = new JsonSlurper().parseText(args)
List<String> installedRepositories = []
List<String> userRepositories = ['npm-internal', 'npm-hub', 'npm-all',
                                 'docker-internal', 'docker-hub', 'docker-all',
                                 'artifacts']

repository.repositoryManager.browse().each { Repository repo ->
  installedRepositories.add(repo.name)
}

repository.repositoryManager.browse().each { Repository repo ->
  if(userRepositories.contains(repo.name) == false)
  {
    repository.repositoryManager.delete(repo.name)
    log.info("Repository $repo.name should be removed")
  }
}
