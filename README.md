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
> gpg-helper is a simple wrapper script around gpg2 (GnuPG). [GNUPG]
> It simplifies usage and encorporates some best practices.
> GnuPG configuration and keyring is stored in /home/max/.gnupg. [GNUPGHOME]
> 
> Usage: ./gpg-helper.sh COMMAND
> &nbsp;&nbsp;COMMAND
> &nbsp;&nbsp;&nbsp;&nbsp;help&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Shows this help text.
> &nbsp;&nbsp;&nbsp;&nbsp;gpgconfig&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Writes gpg.conf and dirmngr.conf interactively.
> &nbsp;&nbsp;&nbsp;&nbsp;listkeys [KEYID|UID]&nbsp;&nbsp; Lists all keys in your keyring.
> &nbsp;&nbsp;&nbsp;&nbsp;listsecretkeys&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Lists your secret keys.
> &nbsp;&nbsp;&nbsp;&nbsp;genkey&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Generates a new key pair interactively.
> &nbsp;&nbsp;&nbsp;&nbsp;editkey KEYID [CMD]&nbsp;&nbsp;&nbsp;&nbsp;Edit the key interactively.
> &nbsp;&nbsp;&nbsp;&nbsp;deletekey KEYID&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Delete the key from the local keyring.
> &nbsp;&nbsp;&nbsp;&nbsp;deletesecretkey KEYID&nbsp;&nbsp;Delete the secret key from the local keyring.
> &nbsp;&nbsp;&nbsp;&nbsp;genrevoke KEYID FILE&nbsp;&nbsp; Generates a key revocation certificate.
> &nbsp;&nbsp;&nbsp;&nbsp;fingerprint KEYID&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Shows the key's fingerprint.
> &nbsp;&nbsp;&nbsp;&nbsp;signkey KEYID&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Signs a key in the keyring and prints it to stdout.
> &nbsp;&nbsp;&nbsp;&nbsp;fexport KEYID [FILE]&nbsp;&nbsp; Exports the key to the file provided or stdout.
> &nbsp;&nbsp;&nbsp;&nbsp;fimport FILE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Imports the keys from a file into your keyring.
> &nbsp;&nbsp;&nbsp;&nbsp;export KEYID…&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Exports keys from your keyring to key servers.
> &nbsp;&nbsp;&nbsp;&nbsp;import KEYID…&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Imports keys from the key servers into your keyring.
> &nbsp;&nbsp;&nbsp;&nbsp;search UID&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Searches for available keys by UID on key servers.
> &nbsp;&nbsp;&nbsp;&nbsp;refresh [KEYID]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Reloads all imported keys from the key servers.
> &nbsp;&nbsp;&nbsp;&nbsp;encrypt -r UID… [FILE] Encrypts the file using the recipient's public key.
> &nbsp;&nbsp;&nbsp;&nbsp;decrypt [FILE]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Decrypts the file using your private key.
> &nbsp;&nbsp;&nbsp;&nbsp;clearsign [FILE [OUT]] Create signature containing plaintext content.
> &nbsp;&nbsp;&nbsp;&nbsp;sign FILE [OUTSIGFILE] Create detached signature with your private key.
> &nbsp;&nbsp;&nbsp;&nbsp;verify [SIGFILE [FILE]]Verify file using signature + signer's public key.
> &nbsp;&nbsp;PARAMETERS
> &nbsp;&nbsp;&nbsp;&nbsp;UID&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A user's identifier or name.
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; For instance 'Max Mustermann' or user@example.org.
> &nbsp;&nbsp;&nbsp;&nbsp;KEYID&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A keypair identified by hexadecimal ID.
> 
> Examples:
> &nbsp;&nbsp;Generate a keypair and a revocation certificate:
> &nbsp;&nbsp;&nbsp;&nbsp;./gpg-helper.sh genkey
> &nbsp;&nbsp;&nbsp;&nbsp;pgp> 4 (creates RSA master key for key signing only, use 4096bit)
> &nbsp;&nbsp;&nbsp;&nbsp;pgp> 4096 (choose high key strength for master)
> &nbsp;&nbsp;&nbsp;&nbsp;pgp> 2y (do not choose more than 2 years, you can always extend time later)
> &nbsp;&nbsp;&nbsp;&nbsp;...
> &nbsp;&nbsp;&nbsp;&nbsp;./gpg-helper.sh genrevoke SUBKEYID OUTPUTREVOKECERTFILE
> &nbsp;&nbsp;Generate a sub key to be used for encryption only + revoke certificate:
> &nbsp;&nbsp;&nbsp;&nbsp;./gpg-helper.sh editkey KEYID addkey
> &nbsp;&nbsp;&nbsp;&nbsp;pgp> 6 (choose RSA encryption key)
> &nbsp;&nbsp;&nbsp;&nbsp;pgp> 2048 (choose only 2048bit strength for faster computing ...)
> &nbsp;&nbsp;&nbsp;&nbsp;pgp> 1y&nbsp;&nbsp; (... since it expires in a year)
> &nbsp;&nbsp;&nbsp;&nbsp;pgp> save (save the key in the local keyring)
> &nbsp;&nbsp;&nbsp;&nbsp;./gpg-helper.sh genrevoke SUBKEYID OUTREVOKECERTFILE
> &nbsp;&nbsp;Export your key to the public key servers:
> &nbsp;&nbsp;&nbsp;&nbsp;./gpg-helper.sh export KEYID
> &nbsp;&nbsp;Search for a person's key on the key servers:
> &nbsp;&nbsp;&nbsp;&nbsp;./gpg-helper.sh search 'John Doe'
> &nbsp;&nbsp;Import John's key, check its fingerprint, mark it as trusted and sign it:
> &nbsp;&nbsp;&nbsp;&nbsp;./gpg-helper.sh import 0xD954726E5B31B1DC
> &nbsp;&nbsp;&nbsp;&nbsp;./gpg-helper.sh fingerprint 0xD954726E5B31B1DC # Call John to confirm
> &nbsp;&nbsp;&nbsp;&nbsp;./gpg-helper.sh editkey 0xD954726E5B31B1DC trust # See OWNER TRUST
> &nbsp;&nbsp;&nbsp;&nbsp;./gpg-helper.sh signkey 0xD954726E5B31B1DC > enc-signed-key-john.asc
> &nbsp;&nbsp;&nbsp;&nbsp;(Send the encrypted signed key file back to John so his key gains trust)
> &nbsp;&nbsp;Encrypt a file for a specific recipient:
> &nbsp;&nbsp;&nbsp;&nbsp;echo 'Hello!' | ./gpg-helper.sh encrypt -r 0xD954726E5B31B1DC
> &nbsp;&nbsp;Encrypt a file for multiple recipients by name (resolved by UIDs in keyring):
> &nbsp;&nbsp;&nbsp;&nbsp;./gpg-helper.sh encrypt -r 'John Doe' -r user@example.org /secret/file
> &nbsp;&nbsp;Decrypt an encrypted file (works only if you have the matching private key):
> &nbsp;&nbsp;&nbsp;&nbsp;./gpg-helper.sh decrypt /secret/file.asc
> &nbsp;&nbsp;Extend a key's expiration date:
> &nbsp;&nbsp;&nbsp;&nbsp;./gpg-helper.sh editkey 0xA3E57D6E5B31B1FB
> &nbsp;&nbsp;&nbsp;&nbsp;gpg> key 1
> &nbsp;&nbsp;&nbsp;&nbsp;gpg> expire
> &nbsp;&nbsp;&nbsp;&nbsp;Key is valid for? (0) 2y
> &nbsp;&nbsp;&nbsp;&nbsp;gpg> save
> &nbsp;&nbsp;&nbsp;&nbsp;./gpg-helper.sh export 0xA3E57D6E5B31B1FB
> &nbsp;&nbsp;Mark compromised key as revoked using your initially created revocation cert:
> &nbsp;&nbsp;&nbsp;&nbsp;./gpg-helper.sh fimport REVOCATIONCERTFILE
> &nbsp;&nbsp;&nbsp;&nbsp;./gpg-helper.sh export KEYID
> Run gpg2 --help for more options.
> 
> Key type identifiers as listed in gpg2 output:
> &nbsp;&nbsp;sec: SECret key
> &nbsp;&nbsp;ssb: Secret SuBkey
> &nbsp;&nbsp;pub: PUBlic key
> &nbsp;&nbsp;sub: public SUBkey
> &nbsp;&nbsp;If a key type identifier is suffixed with '#' it means it could not be
> &nbsp;&nbsp;found on the disk (e.g. sec#). This should be the case for the sec key on
> &nbsp;&nbsp;laptops and build servers that only need to work with ssb and sub keys.
> 
> Key roles as listed in gpg2 output:
> &nbsp;&nbsp;A: key for authentication
> &nbsp;&nbsp;C: key for certifying signatures
> &nbsp;&nbsp;E: key for encryption
> &nbsp;&nbsp;S: key for signing
> 
> Best practices:
> &nbsp;&nbsp;Your MASTER KEY (sec, pub) is your identity and should be kept very secret.
> &nbsp;&nbsp;Use it for key creation, key signing and key revocation only!
> &nbsp;&nbsp;Create SUB KEYS (ssb, sub) of your master key and use them for encryption and
> &nbsp;&nbsp;signing! You can use a separate sub key per machine to sign files but to
> &nbsp;&nbsp;decrypt files on multiple machines you need to copy one sub key to all
> &nbsp;&nbsp;(see https://wiki.debian.org/Subkeys). Do not store your private master key
> &nbsp;&nbsp;on your laptop but in a safe location! You can revoke a single sub key
> &nbsp;&nbsp;without revoking all. If you revoke the master key you have to rebuild all
> &nbsp;&nbsp;trust. To be able to revoke a key you don't have anymore create a revocation
> &nbsp;&nbsp;cert together with the key and store it in a safer location. Refresh your
> &nbsp;&nbsp;keys to minimize the risk of using a friend's compromised key for encryption!
> &nbsp;&nbsp;Expand the WEB OF TRUST by letting a friend sign your public identity key and
> &nbsp;&nbsp;sign his. Your friend gets your key from a key server, confirms the key's
> &nbsp;&nbsp;fingerprint e.g. during a phone call with you, signs the key and sends it
> &nbsp;&nbsp;encrypted back to you where you import it and the other way around
> &nbsp;&nbsp;(see https://wiki.debian.org/Keysigning).
> &nbsp;&nbsp;Both may send the signed keys to key servers to gain their SIGNATORY TRUST.
> &nbsp;&nbsp;A 3rd person that trusts one of you completely in her local keyring
> &nbsp;&nbsp;(OWNER TRUST) may now also trust in the other implicitly.
> &nbsp;&nbsp;The more people have signed your key the more authentic your key becomes on
> &nbsp;&nbsp;the key servers to people who don't know you directly.
> &nbsp;&nbsp;Note: If your friend's key gets compromised or is unsafe the trust chain is
> &nbsp;&nbsp;broken (without your knowledge). Also your key metadata is visible in the
> &nbsp;&nbsp;public and you can never remove it or your old keys from the key servers.
> &nbsp;&nbsp;Therefore think twice before you attach a picture to your key - which is also
> &nbsp;&nbsp;possible.
> 
> Troubleshooting:
> &nbsp;&nbsp;If you cannot reach hkps key servers due to 'general error' restart dirmngr:
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sudo killall dirmngr && sleep 7;
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sudo rm -rf /home/max/.gnupg/dirmngr-cache.d; dirmngr </dev/null
> &nbsp;&nbsp;If you still cannot reach hkps key servers use hkp servers in dirmngr.conf:
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;keyserver hkp://pool.sks-keyservers.net
> &nbsp;&nbsp;If the key server responds with 'no data' to a key search request try again.
> &nbsp;&nbsp;Some keyservers do not (yet) have all keys.
