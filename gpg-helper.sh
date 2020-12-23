#!/bin/sh
#title        :gpg-helper.sh
#description  :Wraps a sub set of GnuPG (gpg) and provides usage hints
#author       :Max Goltzsche
#license      :MIT
#note         :GnuPG >=2.1.11 is required
#date         :20170103
#version      :0.9


usage() {
	MANLOOKUP=
	if [ "$COMMAND" ]; then
		MANLOOKUP="    $COMMAND "
	else
		echo "Invalid arguments: $ARGS" >&2
	fi
	(
	cat <<-EOF
		gpg-helper is a simple wrapper script around $GNUPG (GnuPG). [GNUPG]
		It simplifies usage and encorporates some best practices.
		GnuPG configuration and keyring is stored in $GNUPGHOME. [GNUPGHOME]

		Usage: $0 COMMAND
		  COMMAND
		    help                      Shows this help text.
		    gpgconfig                 Writes gpg.conf and dirmngr.conf interactively.
		    listkeys [KEYID|UID]      Lists all keys in your keyring.
		    listsecretkeys            Lists your secret keys.
		    genkey                    Generates a new key pair interactively.
		    editkey KEYID [CMD]       Edit the key interactively.
		    deletekey KEYID           Delete the key from the local keyring.
		    deletesecretkey KEYID     Delete the secret key from the local keyring.
		    genrevoke KEYID FILE      Generates a key revocation certificate.
		    fingerprint KEYID         Shows the key's fingerprint.
		    signkey KEYID             Signs a key in the keyring and prints it to stdout.
		    fexport KEYID [FILE]      Exports the public key to the provided file or stdout.
		    exportsecret KEYID [FILE] Exports the secret sub key to the proviced file or stdout.
		    fimport FILE              Imports the keys from a file into your keyring.
		    export KEYID…             Exports keys from your keyring to key servers.
		    import KEYID…             Imports keys from the key servers into your keyring.
		    search UID                Searches for available keys by UID on key servers.
		    refresh [KEYID]           Reloads all imported keys from the key servers.
		    encrypt -r UID… [FILE]    Encrypts the file using the recipient's public key.
		    decrypt [FILE]            Decrypts the file using your private key.
		    clearsign [FILE [OUT]]    Create signature containing plaintext content.
		    sign FILE [OUTSIGFILE]    Create detached signature using your private key.
		    verify [SIGFILE [FILE]]   Verify file using signature + signer's public key.
		  PARAMETERS
		    UID                    A user's identifier or name.
		                           For instance 'Max Mustermann' or user@example.org.
		    KEYID                  A keypair identified by hexadecimal ID.

		Examples:
		  Generate a keypair and a revocation certificate:
		    $0 genkey
		    pgp> 4 (creates RSA master key for key signing only, use 4096bit)
		    pgp> 4096 (choose high key strength for master)
		    pgp> 2y (do not choose more than 2 years, you can always extend time later)
		    ...
		    $0 genrevoke SUBKEYID OUTPUTREVOKECERTFILE
		  Generate a sub key to be used for encryption only + revoke certificate:
		    $0 editkey KEYID addkey
		    pgp> 6 (choose RSA encryption key)
		    pgp> 2048 (choose only 2048bit strength for faster computing ...)
		    pgp> 1y   (... since it expires in a year)
		    pgp> save (save the key in the local keyring)
		    $0 genrevoke SUBKEYID OUTREVOKECERTFILE
		  Export your key to the public key servers:
		    $0 export KEYID
		  Search for a person's key on the key servers:
		    $0 search 'John Doe'
		  Import John's key, check its fingerprint, mark it as trusted and sign it:
		    $0 import 0xD954726E5B31B1DC
		    $0 fingerprint 0xD954726E5B31B1DC # Call John to confirm
		    $0 editkey 0xD954726E5B31B1DC trust # See OWNER TRUST
		    $0 signkey 0xD954726E5B31B1DC > enc-signed-key-john.asc
		    (Send the encrypted signed key file back to John so his key gains trust)
		  Encrypt a file for a specific recipient:
		    echo 'Hello!' | $0 encrypt -r 0xD954726E5B31B1DC
		  Encrypt a file for multiple recipients by name (resolved by UIDs in keyring):
		    $0 encrypt -r 'John Doe' -r user@example.org /secret/file
		  Decrypt an encrypted file (works only if you have the matching private key):
		    $0 decrypt /secret/file.asc
		  Extend a key's expiration date:
		    $0 editkey 0xA3E57D6E5B31B1FB
		    gpg> key 1
		    gpg> expire
		    Key is valid for? (0) 2y
		    gpg> save
		    $0 export 0xA3E57D6E5B31B1FB
		  Mark compromised key as revoked using your initially created revocation cert:
		    $0 fimport REVOCATIONCERTFILE
		    $0 export KEYID
		  Export a secret sub key with a separate password (to automate signing or for encryption on a mobile device):
			$0 exportsecret KEYID [OUTFILE]
		Run $GNUPG --help for more options.

		Key type identifiers as listed in $GNUPG output:
		  sec: SECret key
		  ssb: Secret SuBkey
		  pub: PUBlic key
		  sub: public SUBkey
		  If a key type identifier is suffixed with '#' it means it could not be
		  found on the disk (e.g. sec#). This should be the case for the sec key on
		  laptops and build servers that only need to work with ssb and sub keys.

		Key roles as listed in $GNUPG output:
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
		      sudo rm -rf $GNUPGHOME/dirmngr-cache.d; dirmngr </dev/null
		  If you still cannot reach hkps key servers use hkp servers in dirmngr.conf:
		      keyserver hkp://pool.sks-keyservers.net
		  If the key server responds with 'no data' to a key search request try again.
		  Some keyservers do not (yet) have all keys.
	EOF
	) | grep -E "^$MANLOOKUP" >&2
	exit 1
}

gpgVersion() {
	"$GNUPG" --version | head -1 | sed -E 's/^[^0-9]+([0-9\.]+)$/\1/'
}

listEffectiveConfig() {
	grep -Ev '^(#|\s*$)' "$1" 2>/dev/null | sed -E 's/^/  /g' | sort
}

defaultDirmngrConf() {
	cat <<-EOF
		keyserver hkps://hkps.pool.sks-keyservers.net
		hkp-cacert $SKSKEYSERVERCA
	EOF
}

defaultGpgConf() {
	cat <<-EOF
		no-emit-version
		keyid-format 0xlong
		with-fingerprint
		list-options show-uid-validity
		verify-options show-uid-validity
		use-agent
		keyserver-options no-honor-keyserver-url
		keyserver-options include-revoked
		personal-cipher-preferences AES256 AES192 AES CAST5
		personal-digest-preferences SHA512 SHA384 SHA256 SHA224
		cert-digest-algo SHA512
		default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed
	EOF
}

checkAndFixDirmngrConf() {
	SKSKEYSERVERCA=/usr/share/gnupg2/sks-keyservers.netCA.pem
	if [ ! -f "$SKSKEYSERVERCA" ]; then
		SKSKEYSERVERCA="$GNUPGHOME/sks-keyservers.netCA.pem"
		([ -f "$SKSKEYSERVERCA" ] || curl -fSL -o "$SKSKEYSERVERCA" 'https://sks-keyservers.net/sks-keyservers.netCA.pem') || return 1
	fi
	if [ ! "$(defaultDirmngrConf)" = "$(cat "$GNUPGHOME/dirmngr.conf" 2>/dev/null)" ]; then
		if [ -f "$GNUPGHOME/dirmngr.conf" ]; then
			# Backup and replace dirmngr.conf after confirmation prompt
			echo 'Your dirmngr.conf does not equal the default. Current:'
			listEffectiveConfig "$GNUPGHOME/dirmngr.conf" || return 1
			echo 'Will be replaced with:'
			echo "$(defaultDirmngrConf)" | sed -E 's/^/  /g' | sort
			read -p 'Do you like to backup dirmngr.conf and overwrite it? [y|N] ' CONFIRM
			[ "$CONFIRM" = 'y' ] || return 0
			mv "$GNUPGHOME/dirmngr.conf" "$GNUPGHOME/dirmngr.conf.bak" || return 1
		fi
		echo "$(defaultDirmngrConf)" > "$GNUPGHOME/dirmngr.conf" &&
		echo
	fi
}

checkAndFixGpgConf() {
	if [ ! "$(defaultGpgConf)" = "$(cat "$GNUPGHOME/gpg.conf" 2>/dev/null)" ]; then
		if [ -f "$GNUPGHOME/gpg.conf" ]; then
			echo 'Current gpg.conf:'
			listEffectiveConfig "$GNUPGHOME/gpg.conf" || return 1
			echo 'Will be replaced with:'
			defaultGpgConf | sed -E 's/^/  /g' | sort
			read -p 'Do you like to backup gpg.conf and overwrite it? [y|N] ' CONFIRM
			[ "$CONFIRM" = 'y' ] || return 0
			mv "$GNUPGHOME/gpg.conf" "$GNUPGHOME/gpg.conf.bak" || return 1
		fi
		defaultGpgConf > "$GNUPGHOME/gpg.conf" &&
		echo
	fi
}

keyserverConnectionTroubleshooting() {
	echo >&2 <<-EOF
		If you cannot connect to your key server due to a general error
		but you have configured the correct key servers run
		    sudo kill all dirmngr
		    sudo dirmngr < /dev/null
		and retry
	EOF
}

checkAndFixConf() {
	mkdir -p "$GNUPGHOME" &&
	chmod 700 "$GNUPGHOME" &&
	checkAndFixGpgConf &&
	checkAndFixDirmngrConf
}

pubKeyType() {
	[ "$1" ] && "$GNUPG" $OPTS --list-keys "$1" | grep "/$1 " | grep -Eo '^[^ ]+'
}


GNUPG="${GNUPG:-gpg2}" # If it differs on your system: export GNUPG=yourgpg
GNUPGHOME=${GNUPGHOME:-~/.gnupg}
OPTS=${GPG_OPTS:-' --openpgp'}
COMMAND="$1"
ARGS="$@"

# Check gnupg2 and curl are installed
if ! "$GNUPG" --help >/dev/null || ! curl --help >/dev/null; then
	cat >&2 <<-EOF
		$GNUPG or curl is not installed on your system! Set location in GNUPG or
		install it by typing e.g. apt-get install gnupg2 curl
	EOF
	exit 1
fi

# Check gpg version is >=2
[ $(gpgVersion | cut -d . -f 1) -ge 2 ] ||
	(echo "gpg >=2 required but $(gpgVersion) installed. Please update!" >&2; false) || exit 1

# Check and fix configuration
([ -f "$GNUPGHOME/.wrapper-checked" ] || (checkAndFixConf >&2 && touch "$GNUPGHOME/.wrapper-checked")) &&
"$GNUPG" --list-keys >/dev/null || exit 1 # Make sure GNUPGHOME is initialized

# Refresh keys onca a day the script is used
#REFRESHFILE="$GNUPGHOME/.refreshed-$(date +%Y-%m-%d)"
#if [ ! -f "$REFRESHFILE" ]; then
#	"$GNUPG" $OPTS --refresh-keys >&2 &&
#	(rm "$GNUPGHOME"/.refreshed-* 2>/dev/null || true) &&
#	touch "$REFRESHFILE"
#fi

[ $# -eq 0 ] || shift


case "$COMMAND" in
	help|--help)
		COMMAND=
		usage
	;;
	gpgconfig)
		checkAndFixConf
	;;
	listkeys)
		"$GNUPG" $OPTS --list-keys "$@"
	;;
	listsecretkeys)
		[ $# -eq 0 ] || usage
		"$GNUPG" $OPTS --list-secret-keys
	;;
	fingerprint)
		[ $# -eq 1 ] || usage
		"$GNUPG" $OPTS --fingerprint "$1"
	;;
	signkey)
		[ $# -eq 1 ] || usage
		"$GNUPG" $OPTS --sign-key "$1" >&2 &&
		"$GNUPG" $OPTS -a -o - --export "$1" | "$GNUPG" -a -o - --encrypt --recipient "$1"
	;;
	genkey)
		[ $# -eq 0 ] || usage
		cat <<-EOF

			HINT:
			  Use RSA with >=4096 bit!
			  Use limited validity duration <=2y to avoid immortal orphan keys!
			  You can always extend your key's duration later.
			  Consider using a separate subkey for each operation or machine
			  since you can revoke it in case one key gets compromised.
			  Generate a revokation certificate for all of your subkeys and store it
			  in a safe-deposit box since this is the only way to revoke a key you 
			  do not have anymore in case gets stolen (e.g. with your laptop).
			  Otherwise somebody else can do everything with your identity as long as
			  the key is valid.

		EOF
		"$GNUPG" $OPTS --full-gen-key
	;;
	editkey)
		[ $# -ge 1 ] || usage
		"$GNUPG" $OPTS --edit-key "$@"
	;;
	deletekey)
		[ $# -eq 1 ] || usage
		"$GNUPG" $OPTS --delete-key "$1"
	;;
	deletesecretkey)
		[ $# -eq 1 ] || usage
		"$GNUPG" $OPTS --delete-secret-key "$1"
	;;
	genrevoke)
		[ $# -eq 2 ] || usage
		cat <<-EOF

			Generates a key revocation certificate that can be used to revoke a compromised key.
			The certificate should be stored in a safe-deposit box and can 
			also be used to revoke a key you do not have anymore.
			This is your only help in case the key gets stolen with your laptop.

		EOF
		"$GNUPG" $OPTS -a -o "$2" --gen-revoke "$1" &&
		cat <<-EOF

			HINT: To revoke your key:
			  2. Invalidate the key in your keyring by importing the revocation certificate:
			      $0 fimport \$REVOCATIONCERT
			  3. Export your key to the servers again to revoke it there too:
			      $0 export $1

			Note that your key neither will be removed in your keyring nor on the servers
			but marked as revoked so that others can get that information when they
			refresh their keys.
		EOF
	;;
	fimport)
		[ $# -eq 1 ] || usage
		"$GNUPG" $OPTS --import "$1"
	;;
	fexport)
		[ $# -eq 1 -o $# -eq 2 ] || usage
		"$GNUPG" $OPTS -a -o "${2:--}" --export "$1"
	;;
	exportsecret)
		[ $# -eq 1 -o $# -eq 2 ] || usage
		# Export a secret sub key only (!) and encrypt it with a separate password
		stty -echo
		echo "Exporting secret sub key $1 to ${2:--}" >&2
		printf 'Enter current key password: ' >&2
		read -r CURR_PASSWD
		printf '\nEnter new key password: ' >&2
		read -r NEW_PASSWD
		printf '\nRepeat new key password: ' >&2
		read -r NEW_PASSWD_REPEAT
		stty echo
		echo >&2
		[ "$NEW_PASSWD" = "$NEW_PASSWD_REPEAT" ] || (echo New passwords did not match >&2; false) || exit 1
		TMPDIR=$(mktemp -d) && (
			set -e
			# Export sub key from current key ring into a temporary one
			echo "$CURR_PASSWD" | "$GNUPG" $OPTS --pinentry-mode loopback --command-fd 0 -a -o $TMPDIR/secret-subkey.pgp --export-secret-subkeys "$1!" || exit 1
			export GNUPGHOME=$TMPDIR/gnupg
			mkdir -m700 $GNUPGHOME &&
			echo "$CURR_PASSWD" | "$GNUPG" $OPTS --pinentry-mode loopback --command-fd 0 --import $TMPDIR/secret-subkey.pgp &&
			# Set the new password within the temporary key ring
			printf '%s\n%s\n%s\n' "$CURR_PASSWD" "$NEW_PASSWD" "$NEW_PASSWD_REPEAT" | "$GNUPG" $OPTS --pinentry-mode loopback --command-fd 0 --edit-key "$1" passwd &&
			# Export the key
			echo "$NEW_PASSWD" | "$GNUPG" $OPTS --pinentry-mode loopback --command-fd 0 -a -o "${2:--}" --export-secret-subkeys "$1!"
		) || STATUS=1
		rm -rf $TMPDIR
		exit $STATUS
	;;
	search)
		[ $# -ge 1 ] || usage
		"$GNUPG" $OPTS --search-keys "$@"
	;;
	'export')
		[ $# -ge 1 ] || usage
		"$GNUPG" $OPTS --send-keys "$@"
	;;
	import)
		[ $# -ge 1 ] || usage
		"$GNUPG" $OPTS --recv-keys "$@"
	;;
	refresh)
		"$GNUPG" $OPTS --refresh-keys "$@"
	;;
	encrypt)
		[ $# -ge 2 ] || usage
		"$GNUPG" $OPTS -a -o - --encrypt "$@"
	;;
	decrypt)
		[ $# -le 1 ] || usage
		if [ "$1" ]; then
			"$GNUPG" $OPTS -o - --decrypt "$1"
		else # Use stdin
			"$GNUPG" $OPTS -o - --decrypt
		fi
	;;
	sign)
		[ $# -eq 1 -o $# -eq 2 ] || usage
		"$GNUPG" $OPTS -a -o "${2:--}" --detach-sign "$1"
	;;
	clearsign)
		[ $# -le 2 ] || usage
		if [ $# -ge 1 ]; then
			"$GNUPG" $OPTS -a -o "${2:--}" --clearsign "$1"
		else # Use stdin
			"$GNUPG" $OPTS -a -o "${1:--}" --clearsign
		fi
	;;
	verify)
		[ $# -le 2 ] || usage
		"$GNUPG" $OPTS -a -o - --verify "$@"
	;;
	*)
		if [ "$COMMAND" ]; then
			"$GNUPG" $OPTS "$COMMAND" "$@"
		else
			usage
		fi
	;;
esac

# TODO: Use symmetric encryption for large files
