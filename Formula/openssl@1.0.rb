# Extraced from pre- https://github.com/Homebrew/homebrew-core/pull/46876
class OpensslAT10 < Formula
  desc "SSL/TLS cryptography library"
  homepage "https://openssl.org/"
  url "https://www.openssl.org/source/openssl-1.0.2t.tar.gz"
  mirror "https://dl.bintray.com/homebrew/mirror/openssl-1.0.2t.tar.gz"
  mirror "https://www.mirrorservice.org/sites/ftp.openssl.org/source/openssl-1.0.2t.tar.gz"
  sha256 "14cb464efe7ac6b54799b34456bd69558a749a4931ecfd9cf9f71d7881cac7bc"

  # bottle do
  #   sha256 "c9c5e017edabe41ae55ed10ba5b94b834ee494e7f362d7245fbb0b137c876810" => :catalina
  #   sha256 "9874b2baf00f845355b163cb63b5c98a94a5cf7c08cda1d19876899b11b585c6" => :mojave
  #   sha256 "20fa4d39cbc0ba091aed2ce72a4404e87c3bc323243ab3f92ccfd75c48cbe132" => :high_sierra
  #   sha256 "bdbc44c56f63f27ab4dc12583b7f46a6485500f2a583dc8c9b848c4063f58927" => :sierra
  # end

  keg_only :provided_by_macos,
    "Apple has deprecated use of OpenSSL in favor of its own TLS and crypto libraries"

  def install
    # OpenSSL will prefer the PERL environment variable if set over $PATH
    # which can cause some odd edge cases & isn't intended. Unset for safety,
    # along with perl modules in PERL5LIB.
    ENV.delete("PERL")
    ENV.delete("PERL5LIB")

    ENV.deparallelize
    args = %W[
      --prefix=#{prefix}
      --openssldir=#{openssldir}
      no-ssl2
      no-ssl3
      no-zlib
      shared
      enable-cms
      darwin64-x86_64-cc
      enable-ec_nistp_64_gcc_128
    ]
    system "perl", "./Configure", *args
    system "make", "depend"
    system "make"
    system "make", "test"
    system "make", "install", "MANDIR=#{man}", "MANSUFFIX=ssl"
  end

  def openssldir
    etc/"openssl"
  end

  def post_install
    ohai "Regenerating CA certificate bundle from keychain, this may take a while..."

    keychains = %w[
      /Library/Keychains/System.keychain
      /System/Library/Keychains/SystemRootCertificates.keychain
    ]

    certs_list = `security find-certificate -a -p #{keychains.join(" ")}`
    certs = certs_list.scan(
      /-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----/m,
    )

    # Check that the certificate has not expired
    valid_certs = certs.select do |cert|
      IO.popen("#{bin}/openssl x509 -inform pem -checkend 0 -noout &>/dev/null", "w") do |openssl_io|
        openssl_io.write(cert)
        openssl_io.close_write
      end

      $CHILD_STATUS.success?
    end

    # Check that the certificate is trusted in keychain
    trusted_certs = begin
      tmpfile = Tempfile.new

      valid_certs.select do |cert|
        tmpfile.rewind
        tmpfile.write cert
        tmpfile.truncate cert.size
        tmpfile.flush
        IO.popen("/usr/bin/security verify-cert -l -L -R offline -c #{tmpfile.path} &>/dev/null")

        $CHILD_STATUS.success?
      end
    ensure
      tmpfile&.close!
    end

    openssldir.mkpath
    (openssldir/"cert.pem").atomic_write(trusted_certs.join("\n") << "\n")
  end

  def caveats; <<~EOS
    A CA file has been bootstrapped using certificates from the SystemRoots
    keychain. To add additional certificates (e.g. the certificates added in
    the System keychain), place .pem files in
      #{openssldir}/certs

    and run
      #{opt_bin}/c_rehash
  EOS
  end

  test do
    # Make sure the necessary .cnf file exists, otherwise OpenSSL gets moody.
    assert_predicate HOMEBREW_PREFIX/"etc/openssl/openssl.cnf", :exist?,
            "OpenSSL requires the .cnf file for some functionality"

    # Check OpenSSL itself functions as expected.
    (testpath/"testfile.txt").write("This is a test file")
    expected_checksum = "e2d0fe1585a63ec6009c8016ff8dda8b17719a637405a4e23c0ff81339148249"
    system "#{bin}/openssl", "dgst", "-sha256", "-out", "checksum.txt", "testfile.txt"
    open("checksum.txt") do |f|
      checksum = f.read(100).split("=").last.strip
      assert_equal checksum, expected_checksum
    end
  end
end
