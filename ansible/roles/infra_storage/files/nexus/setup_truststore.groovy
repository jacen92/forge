// In the case there are some certificate authorities shared with the container we
// will add them to the nexus TrustStore.

import java.io.File
import java.io.FilenameFilter
import java.io.FileInputStream
import java.security.cert.Certificate
import java.security.cert.CertificateFactory
import org.sonatype.nexus.ssl.TrustStore

def ts = container.lookup(TrustStore.class.name)

String certRoot = "/usr/local/share/ca-certificates"
File f = new File(certRoot)
String[] pathnames = f.list()

// For each pathname in the pathnames array add the CA if pem file
for (String pathname : pathnames) {
    FileInputStream certFile = new FileInputStream(certRoot + "/" + pathname)
    CertificateFactory certificateFactory = CertificateFactory.getInstance("X.509")
    Certificate certificate = certificateFactory.generateCertificate(certFile)
    certFile.close()
    ts.importTrustCertificate(certificate, pathname)
}
