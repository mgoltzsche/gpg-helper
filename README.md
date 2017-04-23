# gpg-helper
Do you want to make sure your privacy stays untouched? Use PGP!

This small wrapper script around GnuPG (gpg2) aims to help you understand and use PGP. It configures gpg2 using best practices. The parameters are human readable - different to those of gpg. The help text covers most frequently used workflows.

## Requirements
GnuPG >=2.1.11

## GnuPG configuration changes
To improve security the script overwrites the local gpg configuration in GNUPGHOME (default: ~/.gnupg) after a prompt.
The configuration written by this script is not GnuPG 1 (gpg) compatible. If you have a GnuPG 1 keystore it will be converted to a GnuPG 2 keystore.
The changes include:
- the use of high available key servers via the HKPS protocol: hkps://hkps.pool.sks-keyservers.net
- strong cipher algorithm preference
- output of longer keyids (hashes)
- output of fingerprints with each key

## TL;DR
`$ ./gpg-helper.sh help`
gpg-helper is a simple wrapper script around gpg2 (GnuPG). [GNUPG]
It simplifies usage and encorporates some best practices.
GnuPG configuration and keyring is stored in /home/max/.gnupg. [GNUPGHOME]

Usage: ./gpg-helper.sh COMMAND
  COMMAND
    help                   Shows this help text.
    gpgconfig              Writes gpg.conf and dirmngr.conf interactively.
    listkeys [KEYID|UID]   Lists all keys in your keyring.
    listsecretkeys         Lists your secret keys.
    genkey                 Generates a new key pair interactively.
    editkey KEYID [CMD]    Edit the key interactively.
    deletekey KEYID        Delete the key from the local keyring.
    deletesecretkey KEYID  Delete the secret key from the local keyring.
    genrevoke KEYID FILE   Generates a key revocation certificate.
    fingerprint KEYID      Shows the key's fingerprint.
    signkey KEYID          Signs a key in the keyring and prints it to stdout.
    fexport KEYID [FILE]   Exports the key to the file provided or stdout.
    fimport FILE           Imports the keys from a file into your keyring.
    export KEYID…          Exports keys from your keyring to key servers.
    import KEYID…          Imports keys from the key servers into your keyring.
    search UID             Searches for available keys by UID on key servers.
    refresh [KEYID]        Reloads all imported keys from the key servers.
    encrypt -r UID… [FILE] Encrypts the file using the recipient's public key.
    decrypt [FILE]         Decrypts the file using your private key.
    clearsign [FILE [OUT]] Create signature containing plaintext content.
    sign FILE [OUTSIGFILE] Create detached signature with your private key.
    verify [SIGFILE [FILE]]Verify file using signature + signer's public key.
  PARAMETERS
    UID                    A user's identifier or name.
                           For instance 'Max Mustermann' or user@example.org.
    KEYID                  A keypair identified by hexadecimal ID.

Examples:
  Generate a keypair and a revocation certificate:
    ./gpg-helper.sh genkey
    pgp> 4 (creates RSA master key for key signing only, use 4096bit)
    pgp> 4096 (choose high key strength for master)
    pgp> 2y (do not choose more than 2 years, you can always extend time later)
    ...
    ./gpg-helper.sh genrevoke SUBKEYID OUTPUTREVOKECERTFILE
  Generate a sub key to be used for encryption only + revoke certificate:
    ./gpg-helper.sh editkey KEYID addkey
    pgp> 6 (choose RSA encryption key)
    pgp> 2048 (choose only 2048bit strength for faster computing ...)
    pgp> 1y   (... since it expires in a year)
    pgp> save (save the key in the local keyring)
    ./gpg-helper.sh genrevoke SUBKEYID OUTREVOKECERTFILE
  Export your key to the public key servers:
    ./gpg-helper.sh export KEYID
  Search for a person's key on the key servers:
    ./gpg-helper.sh search 'John Doe'
  Import John's key, check its fingerprint, mark it as trusted and sign it:
    ./gpg-helper.sh import 0xD954726E5B31B1DC
    ./gpg-helper.sh fingerprint 0xD954726E5B31B1DC # Call John to confirm
    ./gpg-helper.sh editkey 0xD954726E5B31B1DC trust # See OWNER TRUST
    ./gpg-helper.sh signkey 0xD954726E5B31B1DC > enc-signed-key-john.asc
    (Send the encrypted signed key file back to John so his key gains trust)
  Encrypt a file for a specific recipient:
    echo 'Hello!' | ./gpg-helper.sh encrypt -r 0xD954726E5B31B1DC
  Encrypt a file for multiple recipients by name (resolved by UIDs in keyring):
    ./gpg-helper.sh encrypt -r 'John Doe' -r user@example.org /secret/file
  Decrypt an encrypted file (works only if you have the matching private key):
    ./gpg-helper.sh decrypt /secret/file.asc
  Extend a key's expiration date:
    ./gpg-helper.sh editkey 0xA3E57D6E5B31B1FB
    gpg> key 1
    gpg> expire
    Key is valid for? (0) 2y
    gpg> save
    ./gpg-helper.sh export 0xA3E57D6E5B31B1FB
  Mark compromised key as revoked using your initially created revocation cert:
    ./gpg-helper.sh fimport REVOCATIONCERTFILE
    ./gpg-helper.sh export KEYID
Run gpg2 --help for more options.

Key type identifiers as listed in gpg2 output:
  sec: SECret key
  ssb: Secret SuBkey
  pub: PUBlic key
  sub: public SUBkey
  If a key type identifier is suffixed with '#' it means it could not be
  found on the disk (e.g. sec#). This should be the case for the sec key on
  laptops and build servers that only need to work with ssb and sub keys.

Key roles as listed in gpg2 output:
  A: key for authentication
  C: key for certifying signatures
  E: key for encryption
  S: key for signing

Best practices:
  Your MASTER KEY (sec, pub) is your identity and should be kept very secret.
  Use it for key creation, key signing and key revocation only!
  Create SUB KEYS (ssb, sub) of your master key and use them for encryption and
  signing! You can use a separate sub key per machine to sign files but to
  decrypt files on multiple machines you need to copy one sub key to all
  (see https://wiki.debian.org/Subkeys). Do not store your private master key
  on your laptop but in a safe location! You can revoke a single sub key
  without revoking all. If you revoke the master key you have to rebuild all
  trust. To be able to revoke a key you don't have anymore create a revocation
  cert together with the key and store it in a safer location. Refresh your
  keys to minimize the risk of using a friend's compromised key for encryption!
  Expand the WEB OF TRUST by letting a friend sign your public identity key and
  sign his. Your friend gets your key from a key server, confirms the key's
  fingerprint e.g. during a phone call with you, signs the key and sends it
  encrypted back to you where you import it and the other way around
  (see https://wiki.debian.org/Keysigning).
  Both may send the signed keys to key servers to gain their SIGNATORY TRUST.
  A 3rd person that trusts one of you completely in her local keyring
  (OWNER TRUST) may now also trust in the other implicitly.
  The more people have signed your key the more authentic your key becomes on
  the key servers to people who don't know you directly.
  Note: If your friend's key gets compromised or is unsafe the trust chain is
  broken (without your knowledge). Also your key metadata is visible in the
  public and you can never remove it or your old keys from the key servers.
  Therefore think twice before you attach a picture to your key - which is also
  possible.

Troubleshooting:
  If you cannot reach hkps key servers due to 'general error' restart dirmngr:
      sudo killall dirmngr && sleep 7;
      sudo rm -rf /home/max/.gnupg/dirmngr-cache.d; dirmngr </dev/null
  If you still cannot reach hkps key servers use hkp servers in dirmngr.conf:
      keyserver hkp://pool.sks-keyservers.net
  If the key server responds with 'no data' to a key search request try again.
  Some keyservers do not (yet) have all keys.
