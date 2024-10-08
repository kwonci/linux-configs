#compdef openssl
compdef _openssl openssl
# ------------------------------------------------------------------------------
# Copyright (c) 2011 Github zsh-users - https://github.com/zsh-users
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the zsh-users nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL ZSH-USERS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# ------------------------------------------------------------------------------

# openssl command [ command_opts ] [ command_args ]

_openssl() {
  local openssl_commands cmd cmds
  if [[ "$CURRENT" -lt 2 ]]; then
    # I do not think this can happen...
    return
  elif [[ "$CURRENT" -eq 2 ]]; then
    # first parameter, the command
    openssl_commands=(${(z)${${(f)"$(openssl help 2>&1)"}:#([A-Z]|openssl:Error:)*}})
    _describe 'openssl commands' openssl_commands
  else
    # $CURRENT -gt 2
    cmd="${words[2]}"
    # Note: we could use ${(k)functions} to get a list of all functions and
    # filter those that start with _openssl_
    # but that would mean defining a new function *somewhere* might mess with
    # the completion...
    cmds=(asn1parse ca ciphers cms crl crl2pkcs7 dgst dh dhparam dsa dsaparam \
          ec ecparam enc engine errstr gendh gendsa genpkey genrsa nseq ocsp \
          passwd pkcs12 pkcs7 pkcs8 pkey pkeyparam pkeyutl prime rand req rsa \
          rsautl s_client s_server s_time sess_id smime speed spkac srp ts \
          verify version x509)
    # check if $cmd is in $cmds, the list of supported commands
    if [[ "${cmds[(r)$cmd]}" == "${cmd}" ]]; then
      # we should be able to complete $cmd
      # run _openssl_$cmd with the remaining words from the command line
      shift words
      (( CURRENT-- ))
      _openssl_${cmd}
    elif [[ ${${=${"$(openssl help 2>&1)"/*Cipher commands[^)]#)/}}[(re)$cmd]} == "$cmd" ]]; then
      # $cmd is a cipher command, which is practically an alias to enc
      shift words
      (( CURRENT-- ))
      _openssl_enc
    elif [[ ${${=${${"$(openssl help 2>&1)"%%Cipher commands*}/*Message Digest commands[^)]#)/}}[(re)$cmd]} == "$cmd" ]]; then
      # $cmd is a message digest command, which is practically an alias to dgst
      shift words
      (( CURRENT-- ))
      _openssl_dgst
    fi
  fi
}


_openssl_asn1parse() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-inform[input format - one of DER PEM]:format:(DER PEM)' \
    '-in[input file]:file:_files' \
    '-out[output file (output format is always DER]:file:_files' \
    "-noout[don't produce any output]" \
    '-offset[offset into file]:number: ' \
    '-length[length of section in file]:number: ' \
    '-i[indent entries]' \
    '-dump[dump unknown data in hex form]' \
    '-dlimit[dump the first arg bytes of unknown data in hex form]:number: ' \
    '-oid[file of extra oid definitions]:file:_files' \
    "-strparse[a series of these can be used to 'dig' into multiple ASN1 blob wrappings]:offset:" \
    '-genstr[string to generate ASN1 structure from]:str:' \
    '-genconf[file to generate ASN1 structure from]:file:_files'
}


_openssl_ca() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-verbose[talk a lot while doing things]' \
    '-config[a config file]:file:_files' \
    '-name[the particular CA definition to use]:section: ' \
    '-gencrl[generate a new CRL]' \
    '-crldays[days is when the next CRL is due]:days: ' \
    '-crlhours[hours is when the next CRL is due]:hours: ' \
    '-startdate[certificate validity notBefore]:date: ' \
    '-enddate[certificate validity notAfter (overrides -days)]:date: ' \
    '-days[number of days to certify the certificate for]:days: ' \
    '-md[md to use, one of md2, md5, sha or sha1]:alg:(md2 md5 sha sha1)' \
    "-policy[the CA 'policy' to support]:policy: " \
    '-keyfile[private key file]:file:_files' \
    '-keyform[private key file format (PEM or ENGINE)]:format:(PEM ENGINE)' \
    '-key[key to decode the private key if it is encrypted]:password: ' \
    '-cert[the CA certificate]:file:_files' \
    '-selfsign[sign a certificate with the key associated with it]' \
    '-in[the input PEM encoded certificate request(s)]:file:_files' \
    '-out[where to put the output file(s)]:file:_files' \
    '-outdir[where to put output certificates]:dir:_files -/' \
    '-infiles[the last argument, requests to process]:*:files:_files' \
    '-spkac[file contains DN and signed public key and challenge]:file:_files' \
    '-ss_cert[file contains a self signed cert to sign]:file:_files' \
    "-preserveDN[don't re-order the DN]" \
    "-noemailDN[don't add the EMAIL field into certificate' subject]" \
    "-batch[don't ask questions]" \
    '-msie_hack[msie modifications to handle all those universal strings]' \
    '-revoke[revoke a certificate (given in file)]:file:_files' \
    "-subj[use arg instead of request's subject]:subject: " \
    '-utf8[input characters are UTF8 (default ASCII)]' \
    '-multivalue-rdn[enable support for multivalued RDNs]' \
    '-extensions[extension section (override value in config file)]:section: ' \
    '-extfile[configuration file with X509v3 extensions to add]:file:_files' \
    '-crlexts[CRL extension section (override value in config file)]:section: ' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    '-status[shows certificate status given the serial number]:serial: ' \
    '-updatedb[updates db for expired certificates]'
}


_openssl_ciphers() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-v[verbose mode, a textual listing of the SSL/TLS ciphers in OpenSSL]' \
    '-V[even more verbose]' \
    '-ssl2[SSL2 mode]' \
    '-ssl3[SSL3 mode]' \
    '-tls1[TLS1 mode]' \
    ':cipher suite:_list_ciphers'
}


_openssl_cms() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-encrypt[encrypt message]' \
    '-decrypt[decrypt encrypted message]' \
    '-sign[sign message]' \
    '-verify[verify signed message]' \
    '-cmsout[output CMS structure]' \
    '-des3[encrypt with triple DES]' \
    '-des[encrypt with DES]' \
    '-seed[encrypt with SEED]' \
    '-rc2-40[encrypt with RC2-40 (default)]' \
    '-rc2-64[encrypt with RC2-64]' \
    '-rc2-128[encrypt with RC2-128]' \
    '-aes128[encrypt PEM output with cbc aes]' \
    '-aes192[encrypt PEM output with cbc aes]' \
    '-aes256[encrypt PEM output with cbc aes]' \
    '-camellia128[encrypt PEM output with cbc camellia]' \
    '-camellia192[encrypt PEM output with cbc camellia]' \
    '-camellia256[encrypt PEM output with cbc camellia]' \
    "-nointern[don't search certificates in message for signer]" \
    "-nosigs[don't verify message signature]" \
    "-noverify[don't verify signers certificate]" \
    "-nocerts[don't include signers certificate when signing]" \
    '-nodetach[use opaque signing]' \
    "-noattr[don't include any signed attributes]" \
    "-binary[don't translate message to text]" \
    '-certfile[other certificates file]:file:_files' \
    '-certsout[certificate output file]:file:_files' \
    '-signer[signer certificate file]:file:_files' \
    '-recip[recipient certificate file for decryption]:file:_files' \
    '-keyid[use subject key identifier]' \
    '-in[input file]:file:_files' \
    '-inform[input format SMIME (default), PEM or DER]:format:(SMIME PEM DER)' \
    '-inkey[input private key (if not signer or recipient)]:file:_files' \
    '-keyform[input private key format (PEM or ENGINE)]:format:(PEM ENGINE)' \
    '-out[output file]:file:_files' \
    '-outform[output format SMIME (default), PEM or DER]:format:(SMIME PEM DER)' \
    '-content[supply or override content for detached signature]:file:_files' \
    '-to[to address mail head]:address: ' \
    '-from[from address mail head]:address: ' \
    '-subject[subject mail head]:subject: ' \
    '-text[include or delete text MIME headers]' \
    '-CApath[trusted certificates directory]:dir:_files -/' \
    '-CAfile[trusted certificates file]:file:_files' \
    "-crl_check[check revocation status of signer's certificate using CRLs]" \
    "-crl_check_all[check revocation status of signer's certificate chain using CRLs]" \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    '-passin[input file pass phrase source]:pass phrase source:_pass_phrase_source' \
    '-rand[files to use for random number input]:file:_rand_files' \
    '*:certificate:_files'
}


_openssl_crl() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-inform[input format - default PEM (DER or PEM)]:format:(PEM DER)' \
    '-outform[output format - default PEM]:format:(PEM DER)' \
    '-text[print out a text format version]' \
    '-in[input file - default stdin]:file:_files' \
    '-out[output file - default stdout]:file:_files' \
    '-hash[print hash value]' \
    '-hash_old[print old-style (MD5) hash value]' \
    '-fingerprint[print the crl fingerprint]' \
    '-issuer[print issuer DN]' \
    '-lastupdate[print lastUpdate field]' \
    '-nextupdate[print nextUpdate field]' \
    '-crlnumber[print CRL number]' \
    '-noout[no CRL output]' \
    '-CAfile[verify CRL using certificates in the specified file]:file:_files' \
    '-CApath[verify CRL using certificates in the specified directory]:dir:_files -/' \
    '*-nameopt[various certificate name options]:options:_nameopts'
}


_openssl_crl2pkcs7() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-inform[input format - DER or PEM]:format:(PEM DER)' \
    '-outform[output format - DER or PEM]:format:(PEM DER)' \
    '-in[input file]:file:_files' \
    '-out[output file]:file:_files' \
    '-certfile[certificates file of chain to a trusted CA (can be used more than once)]:file:_files' \
    "-nocrl[no crl to load, just certs from '-certfile']"
}


_openssl_dgst() {
  # written for openssl 1.0.1k
  local digests
  digests=(-dss1 -md4 -md5 -mdc2 -ripemd160 -sha -sha1 -sha224 -sha256 -sha384 -sha512 -whirlpool)
  # -hmac is listed twice because it's documented twice by openssl
  _arguments -C -A '-*' \
    '(-r -hex -binary)-c[to output the digest with separating colons]' \
    '(-c -hex -binary)-r[to output the digest in coreutils format]' \
    '-d[to output debug info]' \
    '(-c -r -binary)-hex[output as hex dump]' \
    '(-c -r -hex)-binary[output in binary form]' \
    '-hmac[set the HMAC key to arg]:key: ' \
    '-non-fips-allow[allow use of non FIPS digest]' \
    '-sign[sign digest using private key in the specified file]:file:_files' \
    '-verify[verify a signature using public key in the specified file]:file:_files' \
    '-prverify[verify a signature using private key in the specified file]:file:_files' \
    '-keyform[key file format (PEM or ENGINE)]:format:(PEM ENGINE)' \
    '-out[output to filename rather than stdout]:file:_files' \
    '-signature[signature to verify]:file:_files' \
    '-sigopt[signature parameter]:nm\:v: ' \
    '-hmac[create hashed MAC with key]:key: ' \
    '-mac[create MAC (not necessarily HMAC)]:algorithm: ' \
    '-macopt[MAC algorithm parameters or key]:nm\:v: ' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    "($digests)-dss1[use the dss1 message digest algorithm]" \
    "($digests)-md4[to use the md4 message digest algorithm]" \
    "($digests)-md5[to use the md5 message digest algorithm]" \
    "($digests)-mdc2[to use the mdc2 message digest algorithm]" \
    "($digests)-ripemd160[to use the ripemd160 message digest algorithm]" \
    "($digests)-sha[to use the sha message digest algorithm]" \
    "($digests)-sha1[to use the sha1 message digest algorithm]" \
    "($digests)-sha224[to use the sha224 message digest algorithm]" \
    "($digests)-sha256[to use the sha256 message digest algorithm]" \
    "($digests)-sha384[to use the sha384 message digest algorithm]" \
    "($digests)-sha512[to use the sha512 message digest algorithm]" \
    "($digests)-whirlpool[to use the whirlpool message digest algorithm]" \
    '*:file:_files'
}


_openssl_dh() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-inform[input format]:format:(PEM DER)' \
    '-outform[output format]:format:(PEM DER)' \
    '-in[input file]:file:_files' \
    '-out[output file]:file:_files' \
    '-check[check the DH parameters]' \
    '-text[print a text form of the DH parameters]' \
    '-C[output C code]' \
    '-noout[no output]' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines'
}


_openssl_dhparam() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-inform[input format]:format:(PEM DER)' \
    '-outform[output format]:format:(PEM DER)' \
    '-in[input file]:file:_files' \
    '-out[output file]:file:_files' \
    '-dsaparam[read or generate DSA parameters, convert to DH]' \
    '-check[check the DH parameters]' \
    '-text[print a text form of the DH parameters]' \
    '-C[output C code]' \
    '-2[generate parameters using  2 as the generator value]' \
    '-5[generate parameters using  5 as the generator value]' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    '-rand[files to use for random number input]:file:_rand_files' \
    '-noout[no output]' \
    ':numbits: '
}


_openssl_dsa() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-inform[input format]:format:(PEM DER)' \
    '-outform[output format]:format:(PEM DER)' \
    '-in[input file]:file:_files' \
    '-passin[input file pass phrase source]:file:_files' \
    '-out[output file]:file:_files' \
    '-passout[output file pass phrase source]:file:_files' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    '-des[encrypt PEM output with cbc des]' \
    '-des3[encrypt PEM output with ede cbc des using 168 bit key]' \
    '-idea[encrypt PEM output with cbc idea]' \
    '-aes128[encrypt PEM output with cbc aes]' \
    '-aes192[encrypt PEM output with cbc aes]' \
    '-aes256[encrypt PEM output with cbc aes]' \
    '-camellia128[encrypt PEM output with cbc camellia]' \
    '-camellia192[encrypt PEM output with cbc camellia]' \
    '-camellia256[encrypt PEM output with cbc camellia]' \
    '-seed[encrypt PEM output with cbc seed]' \
    '-text[print the key in text]' \
    "-noout[don't print key out]" \
    '-modulus[print the DSA public value]'
}


_openssl_dsaparam() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-inform[input format]:format:(PEM DER)' \
    '-outform[output format]:format:(PEM DER)' \
    '-in[input file]:file:_files' \
    '-out[output file]:file:_files' \
    '-text[print as text]' \
    '-C[output C code]' \
    '-noout[no output]' \
    '-genkey[generate a DSA key]' \
    '-rand[files to use for random number input]:file:_rand_files' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    ':numbits: '
}


_openssl_ec() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-inform[input format]:format:(PEM DER)' \
    '-outform[output format]:format:(PEM DER)' \
    '-in[input file]:file:_files' \
    '-passin[input file pass phrase source]:file:_files' \
    '-out[output file]:file:_files' \
    '-passout[output file pass phrase source]:file:_files' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    "-des[encrypt PEM output, instead of 'des' every other cipher supported by OpenSSL can be used]" \
    '-text[print the key]' \
    "-noout[don't print key out]" \
    '-param_out[print the elliptic curve parameters]' \
    '-conv_form[specifies the point conversion form]:form:(compressed uncompressed hybrid)' \
    '-param_enc[specifies the way the ec parameters are encoded in the asn1 der encoding]:encoding:(named_curve explicit)'
}


_openssl_ecparam() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-inform[input format]:format:(PEM DER)' \
    '-outform[output format]:format:(PEM DER)' \
    '-in[input file  - default stdin]:file:_files' \
    '-out[output file - default stdout]:file:_files' \
    '-noout[do not print the ec parameter]' \
    '-text[print the ec parameters in text form]' \
    '-check[validate the ec parameters]' \
    "-C[print a 'C' function creating the parameters]" \
    "-name[use the ec parameters with 'short name' name]:name: " \
    "-list_curves[prints a list of all currently available curve 'short names']" \
    '-conv_form[specifies the point conversion form]:form:(compressed uncompressed hybrid)' \
    '-param_enc[specifies the way the ec parameters are encoded in the asn1 der encoding]:encoding:(named_curve explicit)' \
    "-no_seed[if 'explicit' parameters are chosen do not use the seed]" \
    '-genkey[generate ec key]' \
    '-rand[files to use for random number input]:file:_rand_files' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines'
}


_openssl_enc() {
  # written for openssl 1.0.1k
  local ciphers
  ciphers=(-aes-128-cbc -aes-128-cbc-hmac-sha1 -aes-128-cfb -aes-128-cfb1 \
           -aes-128-cfb8 -aes-128-ctr -aes-128-ecb -aes-128-gcm -aes-128-ofb \
           -aes-128-xts -aes-192-cbc -aes-192-cfb -aes-192-cfb1 -aes-192-cfb8 \
           -aes-192-ctr -aes-192-ecb -aes-192-gcm -aes-192-ofb -aes-256-cbc \
           -aes-256-cbc-hmac-sha1 -aes-256-cfb -aes-256-cfb1 -aes-256-cfb8 \
           -aes-256-ctr -aes-256-ecb -aes-256-gcm -aes-256-ofb -aes-256-xts \
           -aes128 -aes192 -aes256 -bf -bf-cbc -bf-cfb -bf-ecb -bf-ofb \
           -blowfish -camellia-128-cbc -camellia-128-cfb -camellia-128-cfb1 \
           -camellia-128-cfb8 -camellia-128-ecb -camellia-128-ofb \
           -camellia-192-cbc -camellia-192-cfb -camellia-192-cfb1 \
           -camellia-192-cfb8 -camellia-192-ecb -camellia-192-ofb \
           -camellia-256-cbc -camellia-256-cfb -camellia-256-cfb1 \
           -camellia-256-cfb8 -camellia-256-ecb -camellia-256-ofb \
           -camellia128 -camellia192 -camellia256 -cast -cast-cbc -cast5-cbc \
           -cast5-cfb -cast5-ecb -cast5-ofb -des -des-cbc -des-cfb -des-cfb1 \
           -des-cfb8 -des-ecb -des-ede -des-ede-cbc -des-ede-cfb -des-ede-ofb \
           -des-ede3 -des-ede3-cbc -des-ede3-cfb -des-ede3-cfb1 \
           -des-ede3-cfb8 -des-ede3-ofb -des-ofb -des3 -desx -desx-cbc \
           -id-aes128-GCM -id-aes192-GCM -id-aes256-GCM -idea -idea-cbc \
           -idea-cfb -idea-ecb -idea-ofb -rc2 -rc2-40-cbc -rc2-64-cbc \
           -rc2-cbc -rc2-cfb -rc2-ecb -rc2-ofb -rc4 -rc4-40 -rc4-hmac-md5 \
           -rc5 -rc5-cbc -rc5-cfb -rc5-ecb -rc5-ofb -seed -seed-cbc -seed-cfb \
           -seed-ecb -seed-ofb)
  _arguments -C \
    '-in[input file]:file:_files' \
    '-out[output file]:file:_files' \
    '-pass[pass phrase source]:pass phrase source:_pass_phrase_source' \
    '-e[encrypt]' \
    '-d[decrypt]' \
    '(-a -base64)'{-a,-base64}'[base64 encode/decode, depending on encryption flag]' \
    '-k[the password to derive the key from]:password: ' \
    '-kfile[read the password to derive the key from the first line of the file]:file:_files' \
    '-md[the md to use to create a key from a passphrase]:alg:(md2 md5 sha sha1)' \
    '-S[the actual salt to use]:salt: ' \
    '-K[the actual key to use]:key: ' \
    '-iv[the actual IV to use]:IV: ' \
    '-p[print out the key and IV used]' \
    '-P[print out the key and IV used the exit]' \
    '-bufsize[set the buffer size for I/O]:size: ' \
    '-nopad[disable standard block padding]' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    "(${ciphers})-aes-128-cbc[cipher types]" \
    "(${ciphers})-aes-128-cbc-hmac-sha1[cipher types]" \
    "(${ciphers})-aes-128-cfb[cipher types]" \
    "(${ciphers})-aes-128-cfb1[cipher types]" \
    "(${ciphers})-aes-128-cfb8[cipher types]" \
    "(${ciphers})-aes-128-ctr[cipher types]" \
    "(${ciphers})-aes-128-ecb[cipher types]" \
    "(${ciphers})-aes-128-gcm[cipher types]" \
    "(${ciphers})-aes-128-ofb[cipher types]" \
    "(${ciphers})-aes-128-xts[cipher types]" \
    "(${ciphers})-aes-192-cbc[cipher types]" \
    "(${ciphers})-aes-192-cfb[cipher types]" \
    "(${ciphers})-aes-192-cfb1[cipher types]" \
    "(${ciphers})-aes-192-cfb8[cipher types]" \
    "(${ciphers})-aes-192-ctr[cipher types]" \
    "(${ciphers})-aes-192-ecb[cipher types]" \
    "(${ciphers})-aes-192-gcm[cipher types]" \
    "(${ciphers})-aes-192-ofb[cipher types]" \
    "(${ciphers})-aes-256-cbc[cipher types]" \
    "(${ciphers})-aes-256-cbc-hmac-sha1[cipher types]" \
    "(${ciphers})-aes-256-cfb[cipher types]" \
    "(${ciphers})-aes-256-cfb1[cipher types]" \
    "(${ciphers})-aes-256-cfb8[cipher types]" \
    "(${ciphers})-aes-256-ctr[cipher types]" \
    "(${ciphers})-aes-256-ecb[cipher types]" \
    "(${ciphers})-aes-256-gcm[cipher types]" \
    "(${ciphers})-aes-256-ofb[cipher types]" \
    "(${ciphers})-aes-256-xts[cipher types]" \
    "(${ciphers})-aes128[cipher types]" \
    "(${ciphers})-aes192[cipher types]" \
    "(${ciphers})-aes256[cipher types]" \
    "(${ciphers})-bf[cipher types]" \
    "(${ciphers})-bf-cbc[cipher types]" \
    "(${ciphers})-bf-cfb[cipher types]" \
    "(${ciphers})-bf-ecb[cipher types]" \
    "(${ciphers})-bf-ofb[cipher types]" \
    "(${ciphers})-blowfish[cipher types]" \
    "(${ciphers})-camellia-128-cbc[cipher types]" \
    "(${ciphers})-camellia-128-cfb[cipher types]" \
    "(${ciphers})-camellia-128-cfb1[cipher types]" \
    "(${ciphers})-camellia-128-cfb8[cipher types]" \
    "(${ciphers})-camellia-128-ecb[cipher types]" \
    "(${ciphers})-camellia-128-ofb[cipher types]" \
    "(${ciphers})-camellia-192-cbc[cipher types]" \
    "(${ciphers})-camellia-192-cfb[cipher types]" \
    "(${ciphers})-camellia-192-cfb1[cipher types]" \
    "(${ciphers})-camellia-192-cfb8[cipher types]" \
    "(${ciphers})-camellia-192-ecb[cipher types]" \
    "(${ciphers})-camellia-192-ofb[cipher types]" \
    "(${ciphers})-camellia-256-cbc[cipher types]" \
    "(${ciphers})-camellia-256-cfb[cipher types]" \
    "(${ciphers})-camellia-256-cfb1[cipher types]" \
    "(${ciphers})-camellia-256-cfb8[cipher types]" \
    "(${ciphers})-camellia-256-ecb[cipher types]" \
    "(${ciphers})-camellia-256-ofb[cipher types]" \
    "(${ciphers})-camellia128[cipher types]" \
    "(${ciphers})-camellia192[cipher types]" \
    "(${ciphers})-camellia256[cipher types]" \
    "(${ciphers})-cast[cipher types]" \
    "(${ciphers})-cast-cbc[cipher types]" \
    "(${ciphers})-cast5-cbc[cipher types]" \
    "(${ciphers})-cast5-cfb[cipher types]" \
    "(${ciphers})-cast5-ecb[cipher types]" \
    "(${ciphers})-cast5-ofb[cipher types]" \
    "(${ciphers})-des[cipher types]" \
    "(${ciphers})-des-cbc[cipher types]" \
    "(${ciphers})-des-cfb[cipher types]" \
    "(${ciphers})-des-cfb1[cipher types]" \
    "(${ciphers})-des-cfb8[cipher types]" \
    "(${ciphers})-des-ecb[cipher types]" \
    "(${ciphers})-des-ede[cipher types]" \
    "(${ciphers})-des-ede-cbc[cipher types]" \
    "(${ciphers})-des-ede-cfb[cipher types]" \
    "(${ciphers})-des-ede-ofb[cipher types]" \
    "(${ciphers})-des-ede3[cipher types]" \
    "(${ciphers})-des-ede3-cbc[cipher types]" \
    "(${ciphers})-des-ede3-cfb[cipher types]" \
    "(${ciphers})-des-ede3-cfb1[cipher types]" \
    "(${ciphers})-des-ede3-cfb8[cipher types]" \
    "(${ciphers})-des-ede3-ofb[cipher types]" \
    "(${ciphers})-des-ofb[cipher types]" \
    "(${ciphers})-des3[cipher types]" \
    "(${ciphers})-desx[cipher types]" \
    "(${ciphers})-desx-cbc[cipher types]" \
    "(${ciphers})-id-aes128-GCM[cipher types]" \
    "(${ciphers})-id-aes192-GCM[cipher types]" \
    "(${ciphers})-id-aes256-GCM[cipher types]" \
    "(${ciphers})-idea[cipher types]" \
    "(${ciphers})-idea-cbc[cipher types]" \
    "(${ciphers})-idea-cfb[cipher types]" \
    "(${ciphers})-idea-ecb[cipher types]" \
    "(${ciphers})-idea-ofb[cipher types]" \
    "(${ciphers})-rc2[cipher types]" \
    "(${ciphers})-rc2-40-cbc[cipher types]" \
    "(${ciphers})-rc2-64-cbc[cipher types]" \
    "(${ciphers})-rc2-cbc[cipher types]" \
    "(${ciphers})-rc2-cfb[cipher types]" \
    "(${ciphers})-rc2-ecb[cipher types]" \
    "(${ciphers})-rc2-ofb[cipher types]" \
    "(${ciphers})-rc4[cipher types]" \
    "(${ciphers})-rc4-40[cipher types]" \
    "(${ciphers})-rc4-hmac-md5[cipher types]" \
    "(${ciphers})-rc5[cipher types]" \
    "(${ciphers})-rc5-cbc[cipher types]" \
    "(${ciphers})-rc5-cfb[cipher types]" \
    "(${ciphers})-rc5-ecb[cipher types]" \
    "(${ciphers})-rc5-ofb[cipher types]" \
    "(${ciphers})-seed[cipher types]" \
    "(${ciphers})-seed-cbc[cipher types]" \
    "(${ciphers})-seed-cfb[cipher types]" \
    "(${ciphers})-seed-ecb[cipher types]" \
    "(${ciphers})-seed-ofb[cipher types]"
}


_openssl_engine() {
  # written for openssl 1.0.1k
  _arguments -C \
    '(-vv -vvv -vvvv)-v[verbose mode, for each engine, list its "control commands"]' \
    "(-v -vvv -vvvv)-vv[like -v, but additionally display each command's description]" \
    '(-v -vv -vvvv)-vvv[like -vv, but also add the input flags for each command]' \
    '(-v -vv -vvv)-vvvv[like -vvv, but also show internal input flags]' \
    '-c[for each engine, also list the capabilities]' \
    '(-tt)-t[for each engine, check that they are really available]' \
    '(-t)-tt[display error trace for unavailable engines]' \
    "-pre[runs command 'cmd' against the ENGINE before any attempts to load it (if -t is used)]:cmd: " \
    "-post[runs command 'cmd' against the ENGINE after loading it (only used if -t is also provided)]:cmd: " \
    '*:engine:_engines'
  # TODO: can cmd (for -pre and -post) be completed?
}


_openssl_errstr() {
  # written for openssl 1.0.1k
  # written for openssl 1.0.2a
  _arguments -C \
    '-stats' \
    ':errno: '
}


_openssl_gendh() {
  # written for openssl 1.0.1k
  _arguments -C \
    "-out[output the key to 'file']:file:_files" \
    '-2[use 2 as the generator value]' \
    '-5[use 5 as the generator value]' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    '-rand[files to use for random number input]:file:_rand_files' \
    ':numbits: '
}


_openssl_gendsa() {
  # written for openssl 1.0.1k
  _arguments -C \
    "-out[output the key to 'file']:file:_files" \
    '-des[encrypt the generated key with DES in cbc mode]' \
    '-des3[encrypt the generated key with DES in ede cbc mode (168 bit key)]' \
    '-idea[encrypt the generated key with IDEA in cbc mode]' \
    '-seed[encrypt PEM output with cbc seed]' \
    '-aes128[encrypt PEM output with cbc aes]' \
    '-aes192[encrypt PEM output with cbc aes]' \
    '-aes256[encrypt PEM output with cbc aes]' \
    '-camellia128[encrypt PEM output with cbc camellia]' \
    '-camellia192[encrypt PEM output with cbc camellia]' \
    '-camellia256[encrypt PEM output with cbc camellia]' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    '-rand[files to use for random number input]:file:_rand_files' \
    ':dsaparam-file:_files'
}


_openssl_genpkey() {
  # written for openssl 1.0.1k
  local ciphers cipher_opts
  if ! ciphers=( ${$(openssl list-cipher-algorithms | cut -d' ' -f1)} ) 2>/dev/null ; then
    ciphers=( ${$(openssl list -cipher-algorithms | cut -d' ' -f1)} )
  fi
  cipher_opts=()
  for alg in ${ciphers}; do
    cipher_opts=(${cipher_opts} "(${${(l:32:: ::-:)ciphers[@]}//  / })-${alg}[use this cipher to encrypt the key]")
  done
  _arguments -C \
    '-out[output file]:file:_files' \
    '-outform[output format]:format:(PEM DER)' \
    '-pass[output file pass phrase source]:pass phrase source:_pass_phrase_source' \
    $cipher_opts \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    '(-algorithm)-paramfile[parameters file]:file:_files' \
    '(-paramfile)-algorithm[the public key algorithm]:algorithm:(EC RSA DSA DH)' \
    '-pkeyopt[public key options]:option\:value: ' \
    '-genparam[generate parameters, not key]' \
    '-text[print the in text]'
  # NB: options order may be important!  See the manual page.
  # TODO: complete pkeyopts
  # However: "The precise set of options supported depends on the public key
  # algorithm used and its implementation."
}


_openssl_genrsa() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-des[encrypt the generated key with DES in cbc mode]' \
    '-des3[encrypt the generated key with DES in ede cbc mode (168 bit key)]' \
    '-idea[encrypt the generated key with IDEA in cbc mode]' \
    '-seed[encrypt PEM output with cbc seed]' \
    '-aes128[encrypt PEM output with cbc aes]' \
    '-aes192[encrypt PEM output with cbc aes]' \
    '-aes256[encrypt PEM output with cbc aes]' \
    '-camellia128[encrypt PEM output with cbc camellia]' \
    '-camellia192[encrypt PEM output with cbc camellia]' \
    '-camellia256[encrypt PEM output with cbc camellia]' \
    '-out[output the key to file]:file:_files' \
    '-passout[output file pass phrase source]:pass phrase source:_pass_phrase_source' \
    '-f4[use F4 (0x10001) for the E value]' \
    '-3[use 3 for the E value]' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    '-rand[files to use for random number input]:file:_rand_files' \
    ':numbits: '
}


_openssl_nseq() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-in[input file]:file:_files' \
    '-out[output file]:file:_files' \
    '-toseq[output NS Sequence file]'
}


_openssl_ocsp() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-out[output filename]:file:_files' \
    '-issuer[issuer certificate]:file:_files' \
    '-cert[certificate to check]:file:_files' \
    '-serial[serial number to check]:serial: ' \
    '-signer[certificate to sign OCSP request with]:file:_files' \
    '-signkey[private key to sign OCSP request with]:file:_files' \
    '-sign_other[additional certificates to include in signed request]:file:_files' \
    "-no_certs[don't include any certificates in signed request]" \
    '-req_text[print text form of request]' \
    '-resp_text[print text form of response]' \
    '-text[print text form of request and response]' \
    '-reqout[write DER encoded OCSP request to "file"]:file:_files' \
    '-respout[write DER encoded OCSP response to "file"]:file:_files' \
    '-reqin[read DER encoded OCSP request from "file"]:file:_files' \
    '-respin[read DER encoded OCSP response from "file"]:file:_files' \
    '-nonce[add OCSP nonce to request]' \
    "-no_nonce[don't add OCSP nonce to request]" \
    '-url[OCSP responder URL]:URL: ' \
    '-host[send OCSP request to given host on given port]:host\:port: ' \
    '-path[path to use in OCSP request]' \
    '-CApath[trusted certificates directory]:directory:_files -/' \
    '-CAfile[trusted certificates file]:file:_files' \
    '-VAfile[validator certificates file]:file:_files' \
    '-validity_period[maximum validity discrepancy in seconds]:seconds: ' \
    '-status_age[maximum status age in seconds]:seconds: ' \
    "-noverify[don't verify response at all]" \
    '-verify_other[additional certificates to search for signer]:file:_files' \
    "-trust_other[don't verify additional certificates]" \
    "-no_intern[don't search certificates contained in response for signer]" \
    "-no_signature_verify[don't check signature on response]" \
    "-no_cert_verify[don't check signing certificate]" \
    "-no_chain[don't chain verify response]" \
    "-no_cert_checks[don't do additional checks on signing certificate]" \
    '-port[port to run responder on]:port: ' \
    '-index[certificate status index file]:file:_files' \
    '-CA[CA certificate]:file:_files' \
    '-rsigner[responder certificate to sign responses with]:file:_files' \
    '-rkey[responder key to sign responses with]:file:_files' \
    '-rother[other certificates to include in response]:file:_files' \
    "-resp_no_certs[don't include any certificates in response]" \
    '-nmin[number of minutes before next update]:minutes: ' \
    '-ndays[number of days before next update]:days: ' \
    '-resp_key_id[identify response by signing certificate key ID]' \
    '-nrequest[number of requests to accept (default unlimited)]:limit: ' \
    '-dss1[use specified digest in the request]' \
    '-md4[use specified digest in the request]' \
    '-md5[use specified digest in the request]' \
    '-mdc2[use specified digest in the request]' \
    '-ripemd160[use specified digest in the request]' \
    '-ripemd[use specified digest in the request]' \
    '-rmd160[use specified digest in the request]' \
    '-sha1[use specified digest in the request]' \
    '-sha224[use specified digest in the request]' \
    '-sha256[use specified digest in the request]' \
    '-sha384[use specified digest in the request]' \
    '-sha512[use specified digest in the request]' \
    '-sha[use specified digest in the request]' \
    '-ssl2-md5[use specified digest in the request]' \
    '-ssl3-md5[use specified digest in the request]' \
    '-ssl3-sha1[use specified digest in the request]' \
    '-whirlpool[use specified digest in the request]' \
    '-timeout[timeout connection to OCSP responder after n seconds]:seconds: '
}


_openssl_passwd() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-crypt[standard Unix password algorithm (default)]' \
    '-1[MD5-based password algorithm]' \
    '-apr1[MD5-based password algorithm, Apache variant]' \
    '-salt[use provided salt]:salt: ' \
    '-in[read passwords from file]:file:_files' \
    '-stdin[read passwords from stdin]' \
    '-noverify[never verify when reading password from terminal]' \
    '-quiet[no warnings]' \
    '-table[format output as table]' \
    '-reverse[switch table columns]' \
    '*:password:'
}


_openssl_pkcs12() {
  # written for openssl 1.0.2d
  local algorithms
  algorithms=(aes-128-cbc aes-128-ecb aes-192-cbc aes-192-ecb aes-256-cbc \
              aes-256-ecb bf-cbc bf-cfb bf-ecb bf-ofb camellia-128-cbc \
              camellia-128-ecb camellia-192-cbc camellia-192-ecb \
              camellia-256-cbc camellia-256-ecb cast-cbc cast5-cbc cast5-cfb \
              cast5-ecb cast5-ofb des-cbc des-cfb des-ecb des-ede des-ede-cbc \
              des-ede-cfb des-ede-ofb des-ede3 des-ede3-cbc des-ede3-cfb \
              des-ede3-ofb des-ofb idea-cbc idea-cfb idea-ecb idea-ofb \
              rc2-40-cbc rc2-64-cbc rc2-cbc rc2-cfb rc2-ecb rc2-ofb rc4 \
              rc4-40 rc5-cbc rc5-cfb rc5-ecb rc5-ofb seed-cbc seed-cfb \
              seed-ecb seed-ofb PBE-MD2-DES PBE-MD5-DES PBE-SHA1-RC2-64 \
              PBE-MD2-RC2-64 PBE-MD5-RC2-64 PBE-SHA1-DES PBE-SHA1-RC4-128 \
              PBE-SHA1-RC4-40 PBE-SHA1-3DES PBE-SHA1-2DES PBE-SHA1-RC2-128 \
              PBE-SHA1-RC2-40)
  _arguments -C \
    '-export[output PKCS12 file]' \
    '-chain[add certificate chain]' \
    '-inkey[private key if not infile]:file:_files' \
    '-certfile[add all certs in the specified file]:file:_files' \
    "-CApath[PEM format directory of CA's]:file:_files" \
    "-CAfile[PEM format file of CA's]:file:_files" \
    '-name[use specified friendly name]:name: ' \
    '*-caname[use specified CA friendly name]:name: ' \
    '-in[input filename]:file:_files' \
    '-out[output filename]:file:_files' \
    "-noout[don't output anything, just verify]" \
    "-nomacver[don't verify MAC]" \
    "-nocerts[don't output certificates]" \
    '-clcerts[only output client certificates]' \
    '-cacerts[only output CA certificates]' \
    "-nokeys[don't output private keys]" \
    '-info[give info about PKCS#12 structure]' \
    '-des[encrypt private keys with DES]' \
    '-des3[encrypt private keys with triple DES (default)]' \
    '-idea[encrypt private keys with idea]' \
    '-seed[encrypt private keys with seed]' \
    '-aes128[encrypt PEM output with cbc aes]' \
    '-aes192[encrypt PEM output with cbc aes]' \
    '-aes256[encrypt PEM output with cbc aes]' \
    '-camellia128[encrypt PEM output with cbc camellia]' \
    '-camellia192[encrypt PEM output with cbc camellia]' \
    '-camellia256[encrypt PEM output with cbc camellia]' \
    "-nodes[don't encrypt private keys]" \
    "-noiter[don't use encryption iteration]" \
    "-nomaciter[don't use MAC iteration]" \
    '-maciter[use MAC iteration]' \
    "-nomac[don't generate MAC]" \
    '-twopass[separate MAC, encryption passwords]' \
    '-descert[encrypt PKCS#12 certificates with triple DES (default RC2-40)]' \
    "-certpbe[specify certificate PBE algorithm (default RC2-40)]:alg:(${algorithms})" \
    '-keypbe[specify private key PBE algorithm (default 3DES)]:alg:(${algorithms})' \
    '-macalg[digest algorithm used in MAC (default SHA1)]:alg:_list_message_digest_algorithms' \
    '-keyex[set MS key exchange type]' \
    '-keysig[set MS key signature type]' \
    '-password[set import/export password source]:pass phrase source:_pass_phrase_source' \
    '-passin[input file pass phrase source]:pass phrase source:_pass_phrase_source' \
    '-passout[output file pass phrase source]:pass phrase source:_pass_phrase_source' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    '-rand[files to use for random number input]:file:_rand_files' \
    '-CSP[Microsoft CSP name]:name: ' \
    '-LMK[add local machine keyset attribute to private key]'
}


_openssl_pkcs7() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-inform[input format]:format:(PEM DER)' \
    '-outform[output format]:format:(PEM DER)' \
    '-in[input file]:file:_files' \
    '-out[output file]:file:_files' \
    '-print_certs[print any certs or crl in the input]' \
    '-text[print full details of certificates]' \
    "-noout[don't output encoded data]" \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines'
}


_openssl_pkcs8() {
  # written for openssl 1.0.2d
  _arguments -C \
    '-in[input file]:file:_files' \
    '-inform[input format]:format:(PEM DER)' \
    '-passin[input file pass phrase source]:pass phrase source:_pass_phrase_source' \
    '-outform[output format]:format:(PEM DER)' \
    '-out[output file]:file:_files' \
    '-passout[output file pass phrase source]:pass phrase source:_pass_phrase_source' \
    '-topk8[output PKCS8 file]' \
    '-nooct[use (nonstandard) no octet format]' \
    '-embed[use (nonstandard) embedded DSA parameters format]' \
    '-nsdb[use (nonstandard) DSA Netscape DB format]' \
    '-noiter[use 1 as iteration count]' \
    '-nocrypt[use or expect unencrypted private key]' \
    '-v2[use PKCS#5 v2.0 and given cipher]:alg:(aes-128-cbc aes-128-ecb aes-192-cbc aes-192-ecb aes-256-cbc aes-256-ecb bf bf-cbc bf-cfb bf-ecb bf-ofb camellia-128-cbc camellia-128-ecb camellia-192-cbc camellia-192-ecb camellia-256-cbc camellia-256-ecb cast cast-cbc cast5-cbc cast5-cfb cast5-ecb cast5-ofb des des-cbc des-cfb des-ecb des-ede des-ede-cbc des-ede-cfb des-ede-ofb des-ede3 des-ede3-cbc des-ede3-cfb des-ede3-ofb des-ofb des3 desx idea idea-cbc idea-cfb idea-ecb idea-ofb rc2 rc2-40-cbc rc2-64-cbc rc2-cbc rc2-cfb rc2-ecb rc2-ofb rc4 rc4-40 rc5 rc5-cbc rc5-cfb rc5-ecb rc5-ofb seed seed-cbc seed-cfb seed-ecb seed-ofb)' \
    '-v2prf[set the PRF algorithm to use with PKCS#5 v2.0]:alg:(hmacWithMD5 hmacWithRMD160 hmacWithSHA1 hmacWithSHA224 hmacWithSHA256 hmacWithSHA384 hmacWithSHA512)' \
    '-v1[use PKCS#5 v1.5 and given cipher]:obj:(PBE-MD2-DES PBE-MD5-DES PBE-SHA1-RC2-64 PBE-MD2-RC2-64 PBE-MD5-RC2-64 PBE-SHA1-DES PBE-SHA1-RC4-128 PBE-SHA1-RC4-40 PBE-SHA1-3DES PBE-SHA1-2DES PBE-SHA1-RC2-128 PBE-SHA1-RC2-40)' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines'
}


_openssl_pkey() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-in[input file]:file:_files' \
    '-inform[input format]:format:(PEM DER)' \
    '-passin[input file pass phrase source]:pass phrase source:_pass_phrase_source' \
    '-outform[output format]:format:(PEM DER)' \
    '-out[output file]:file:_files' \
    '-passout[output file pass phrase source]:pass phrase source:_pass_phrase_source' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines'
}


_openssl_pkeyparam() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-in[the input filename to read parameters from]:file:_files' \
    '-out[the output filename to write parameters]:file:_files' \
    '-text[prints out the parameters in plain text in addition to the encoded version]' \
    '-noout[do not output the encoded version of the parameters]' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines'
}


_openssl_pkeyutl() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-in[input file]:file:_files' \
    '-out[output file]:file:_files' \
    '-sigfile[signature file (verify operation only)]:file:_files' \
    '-inkey[input key]:file:_files' \
    '-keyform[private key format]:format:(PEM DER)' \
    '-pubin[input is a public key]' \
    '-certin[input is a certificate carrying a public key]' \
    '-pkeyopt[public key options]:option\:value:_pkeyopts' \
    '-sign[sign with private key]' \
    '-verify[verify with public key]' \
    '-verifyrecover[verify with public key, recover original data]' \
    '-encrypt[encrypt with public key]' \
    '-decrypt[decrypt with private key]' \
    '-derive[derive shared secret]' \
    '-hexdump[hex dump output]' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    '-passin[pass phrase source]:pass phrase source:_pass_phrase_source'
}


_openssl_prime() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-hex[hex]' \
    '-checks[number of checks]:checks: ' \
    ':number:'
}


_openssl_rand() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-out[write to file]:file:_files' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    '-rand[files to use for random number input]:file:_rand_files' \
    '-base64[base64 encode output]' \
    '-hex[hex encode output]' \
    ':num:'
}


_openssl_req() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-inform[input format]:format:(PEM DER)' \
    '-outform[output format]:format:(PEM DER)' \
    '-in[input file]:file:_files' \
    '-out[output file]:file:_files' \
    '-text[text form of request]' \
    '-pubkey[output public key]' \
    '-noout[do not output REQ]' \
    '-verify[verify signature on REQ]' \
    '-modulus[RSA modulus]' \
    "-nodes[don't encrypt the output key]" \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    "-subject[output the request's subject]" \
    '-passin[private key pass phrase source]:pass phrase source:_pass_phrase_source' \
    '-key[use the private key contained in the specified file]:file:_files' \
    '-keyform[key file format]:format:(PEM DER)' \
    '-keyout[file to send the key to]:file:_files' \
    '-rand[files to use for random number input]:file:_rand_files' \
    "-newkey rsa\:-[generate a new RSA key of the specified number of bits in size]:bits: " \
    "-newkey dsa\:[generate a new DSA key, parameters taken from CA in the specified file]:file:_files" \
    "-newkey ec\:[generate a new EC key, parameters taken from CA in the specified file]:file:_files" \
    '-md2[digest to sign with]' \
    '-md4[digest to sign with]' \
    '-md5[digest to sign with]' \
    '-mdc2[digest to sign with]' \
    '-sha1[digest to sign with]' \
    '-config[request template file]:file:_files' \
    '-subj[set or modify request subject]:subject: ' \
    '-multivalue-rdn[enable support for multivalued RDNs]' \
    '-new[new request]' \
    '-batch[do not ask anything during request generation]' \
    '-x509[output a x509 structure instead of a certificate request]' \
    '-days[number of days a certificate generated by -x509 is valid for]:days: ' \
    '-set_serial[serial number to use for a certificate generated by -x509]:serial: ' \
    '-newhdr[output "NEW" in the header lines]' \
    "-asn1-kludge[output the 'request' in a format that is wrong but some CA's have been reported as requiring]" \
    '-extensions[specify certificate extension section (override value in config file)]:section: ' \
    '-reqexts[specify request extension section (override value in config file)]:section: ' \
    '-utf8[input characters are UTF8 (default ASCII)]' \
    '*-nameopt[various certificate name options]:options:_nameopts' \
    '*-reqopt[- various request text options]:options:_certopts'
  # TODO: complete -extensions and -reqexts
}


_openssl_rsa() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-inform[input format]:format:(PEM DER NET)' \
    '-outform[output format]:format:(PEM DER NET)' \
    '-in[input file]:file:_files' \
    '-sgckey[use IIS SGC key format]' \
    '-passin[input file pass phrase source]:pass phrase source:_pass_phrase_source' \
    '-out[output file]:file:_files' \
    '-passout[output file pass phrase source]:pass phrase source:_pass_phrase_source' \
    '-des[encrypt PEM output with cbc des]' \
    '-des3[encrypt PEM output with ede cbc des using 168 bit key]' \
    '-idea[encrypt PEM output with cbc idea]' \
    '-seed[encrypt PEM output with cbc seed]' \
    '-aes128[encrypt PEM output with cbc aes]' \
    '-aes192[encrypt PEM output with cbc aes]' \
    '-aes256[encrypt PEM output with cbc aes]' \
    '-camellia128[encrypt PEM output with cbc camellia]' \
    '-camellia192[encrypt PEM output with cbc camellia]' \
    '-camellia256[encrypt PEM output with cbc camellia]' \
    '-text[print the key in text]' \
    "-noout[don't print key out]" \
    '-modulus[print the RSA key modulus]' \
    '-check[verify key consistency]' \
    '-pubin[expect a public key in input file]' \
    '-pubout[output a public key]' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines'
}


_openssl_rsautl() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-in[input file]:file:_files' \
    '-out[output file]:file:_files' \
    '-inkey[input key]:file:_files' \
    '-keyform[private key format]:format:(PEM DER)' \
    '-pubin[input is an RSA public]' \
    '-certin[input is a certificate carrying an RSA public key]' \
    '-ssl[use SSL v2 padding]' \
    '-raw[use no padding]' \
    '-pkcs[use PKCS#1 v1.5 padding (default)]' \
    '-oaep[use PKCS#1 OAEP]' \
    '-sign[sign with private key]' \
    '-verify[verify with public key]' \
    '-encrypt[encrypt with public key]' \
    '-decrypt[decrypt with private key]' \
    '-hexdump[hex dump output]' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    '-passin[pass phrase source]:pass phrase source:_pass_phrase_source'
}


_openssl_s_client() {
  # written for openssl 1.0.1k
  _arguments -C \
    '(-6)-4[use IPv4 only]' \
    '(-4)-6[use IPv6 only]' \
    '(-connect)-host[use -connect instead]:host: ' \
    '(-connect)-port[use -connect instead]:port: ' \
    '(-host -port)-connect[who to connect to (default is localhost:4433)]:host\:port: ' \
    '-verify[turn on peer certificate verification]:depth: ' \
    '-verify_return_error[return verification errors]' \
    '-cert[certificate file to use, PEM format assumed]:file:_files' \
    '-certform[certificate format (PEM or DER) PEM default]:format:(PEM DER)' \
    '-key[private key file to use, in cert file if not specified but cert file is]:file:_files' \
    '-keyform[key format (PEM or DER) PEM default]:format:(PEM DER)' \
    '-pass[private key file pass phrase source]:pass phrase source:_pass_phrase_source' \
    "-CApath[PEM format directory of CA's]:directory:_files -/" \
    "-CAfile[PEM format file of CA's]:file:_files" \
    '-reconnect[drop and re-make the connection with the same Session-ID]' \
    '-pause[sleep(1) after each read(2) and write(2) system call]' \
    '-prexit[print session information even on connection failure]' \
    '-showcerts[show all certificates in the chain]' \
    '-debug[extra output]' \
    '-msg[show protocol messages]' \
    '-nbio_test[more ssl protocol testing]' \
    "-state[print the 'ssl' states]" \
    '-nbio[run with non-blocking IO]' \
    '-crlf[convert LF from terminal into CRLF]' \
    '-quiet[no s_client output]' \
    '(-no_ign_eof)-ign_eof[ignore input eof (default when -quiet)]' \
    "(-ign_eof)-no_ign_eof[don't ignore input eof]" \
    '-psk_identity[PSK identity]:identity: ' \
    '-psk[PSK in hex (without 0x)]:key: ' \
    "-srpuser[SRP authentication for 'user']:user: " \
    "-srppass[password for 'user']:password: " \
    '-srp_lateuser[SRP username into second ClientHello message]' \
    '-srp_moregroups[tolerate other than the known g N values]' \
    '-srp_strength[minimal length in bits for N (default 1024)]:int: ' \
    '(-no_ssl2 -ssl3 -tls1 -tls1_1 -tls1_2 -dtls1)-ssl2[just use SSLv2]' \
    '(-no_ssl3 -ssl2 -tls1 -tls1_1 -tls1_2 -dtls1)-ssl3[just use SSLv3]' \
    '(-no_tls1_2 -ssl2 -ssl3 -tls1 -tls1_1 -dtls1)-tls1_2[just use TLSv1.2]' \
    '(-no_tls1_1 -ssl2 -ssl3 -tls1 -tls1_1 -dtls1)-tls1_1[just use TLSv1.1]' \
    '(-no_tls1 -ssl2 -ssl3 -tls1 -tls1_1 -dtls1)-tls1[just use TLSv1.0]' \
    '(-no_dtls1 -ssl2 -ssl3 -tls1 -tls1_1 -tls1_2)-dtls1[just use DTLSv1]' \
    '-fallback_scsv[send TLS_FALLBACK_SCSV]' \
    '-mtu[set the link layer MTU]' \
    '(-tls1_2)-no_tls1_2[turn off TLSv1.2]' \
    '(-tls1_1)-no_tls1_1[turn off TLSv1.1]' \
    '(-tls1)-no_tls1[turn off TLSv1.0]' \
    '(-ssl3)-no_ssl3[turn off SSLv3]' \
    '(-ssl2)-no_ssl2[turn off SSLv2]' \
    '-bugs[switch on all SSL implementation bug workarounds]' \
    "-serverpref[use server's cipher preferences (only SSLv2)]" \
    '-cipher[preferred cipher to use]:cipher suite:_list_ciphers' \
    "-starttls[use the STARTTLS command before starting TLS for those protocols that support it]:protocol:(smtp pop3 imap ftp xmpp)" \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    '-rand[files to use for random number input]:file:_rand_files' \
    '-sess_out[file to write SSL session to]:file:_files' \
    '-sess_in[file to read SSL session from]:file:_files' \
    '-servername[set TLS extension servername in ClientHello]:host: ' \
    '-tlsextdebug[hex dump of all TLS extensions received]' \
    '-status[request certificate status from server]' \
    '-no_ticket[disable use of RFC4507bis session tickets]' \
    '-nextprotoneg[enable NPN extension, considering named protocols supported (comma-separated list)]:protocols: ' \
    '-legacy_renegotiation[enable use of legacy renegotiation (dangerous)]' \
    '-use_srtp[offer SRTP key management with a colon-separated profile list]:profiles: ' \
    '-keymatexport[export keying material using label]:label: ' \
    '-keymatexportlen[export len bytes of keying material (default 20)]:len: '
}


_openssl_s_server() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-accept[port to accept on (default is 4433)]:port: ' \
    '-context[set session ID context]:id: ' \
    '-verify[turn on peer certificate verification]:depth: ' \
    '-Verify[turn on peer certificate verification, must have a cert]:depth: ' \
    '-verify_return_error[return verification errors]' \
    '-cert[certificate file to use (default is server.pem)]:file:_files' \
    '-crl_check[check the peer certificate has not been revoked by its CA]' \
    '-crl_check_all[check the peer certificate has not been revoked by its CA or any other CRL in the CA chain]' \
    '-certform[certificate format]:format:(PEM DER)' \
    '-key[Private Key file to use, in cert file if not specified (default is server.pem)]:file:_files' \
    '-keyform[key format]:format:(PEM DER ENGINE)' \
    '-pass[private key file pass phrase source]:pass phrase source:_pass_phrase_source' \
    '-dcert[second certificate file to use (usually for DSA)]:file:_files' \
    '-dcertform[second certificate format]:format:(PEM DER)' \
    '-dkey[second private key file to use (usually for DSA)]:file:_files' \
    '-dkeyform[second key format]:format:(PEM DER ENGINE)' \
    '-dpass[second private key file pass phrase source]:pass phrase source:_pass_phrase_source' \
    '-dhparam[DH parameter file to use, in cert file if not specified or a default set of parameters is used]:file:_files' \
    '-named_curve[elliptic curve name to use for ephemeral ECDH keys. (default is nistp256)]:named curve:_list_curves' \
    '-nbio[run with non-blocking IO]' \
    '-nbio_test[test with the non-blocking test bio]' \
    '-crlf[convert LF from terminal into CRLF]' \
    '-debug[print more output]' \
    '-msg[show protocol messages]' \
    '-state[print the SSL states]' \
    "-CApath[PEM format directory of CA's]:file:_files -/" \
    "-CAfile[PEM format file of CA's]:file:_files" \
    "-nocert[don't use any certificates (Anon-DH)]" \
    '-cipher[preferred cipher to use]:cipher suite:_list_ciphers' \
    "-serverpref[use server's cipher preferences]" \
    '-quiet[no server output]' \
    '-no_tmp_rsa[do not generate a tmp RSA key]' \
    '-psk_hint[PSK identity hint to use]:hint: ' \
    '-psk[PSK in hex (without 0x)]:PSK: ' \
    '-srpvfile[the verifier file for SRP]:file:_files' \
    '-srpuserseed[a seed string for a default user salt]:seed: ' \
    '-ssl2[just talk SSLv2]' \
    '-ssl3[just talk SSLv3]' \
    '-tls1_2[just talk TLSv1.2]' \
    '-tls1_1[just talk TLSv1.1]' \
    '-tls1[just talk TLSv1]' \
    '-dtls1[just talk DTLSv1]' \
    '-timeout[enable timeouts]' \
    '-mtu[set link layer MTU]' \
    '-chain[read a certificate chain]' \
    '-no_ssl2[just disable SSLv2]' \
    '-no_ssl3[just disable SSLv3]' \
    '-no_tls1[just disable TLSv1]' \
    '-no_tls1_1[just disable TLSv1.1]' \
    '-no_tls1_2[just disable TLSv1.2]' \
    '-no_dhe[disable ephemeral DH]' \
    '-no_ecdhe[disable ephemeral ECDH]' \
    '-bugs[turn on SSL bug compatibility]' \
    '-hack[workaround for early Netscape code]' \
    "-www[respond to a 'GET /' with a status page]" \
    "-WWW[respond to a 'GET /<path> HTTP/1.0' with file ./<path>]" \
    "-HTTP[respond to a 'GET /<path> HTTP/1.0' with file ./<path> with the assumption it contains a complete HTTP response]" \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    '-id_prefix[generate SSL/TLS session IDs prefixed by arg]:prefix: ' \
    '-rand[files to use for random number input]:file:_rand_files' \
    '-servername[servername for HostName TLS extension]:hostname: ' \
    '-servername_fatal[on mismatch send fatal alert (default warning alert)]' \
    '-cert2[certificate file to use for servername (default is server2.pem)]:file:_files' \
    '-key2[Private Key file to use for servername, in cert file if not specified (default is server2.pem)]:file:_files' \
    '-tlsextdebug[hex dump of all TLS extensions received]' \
    '-no_ticket[disable use of RFC4507bis session tickets]' \
    '-legacy_renegotiation[enable use of legacy renegotiation (dangerous)]' \
    '-nextprotoneg[set the advertised protocols for the NPN extension (comma-separated list)]:protocol:(http/1.0 http/1.1)' \
    '-use_srtp[offer SRTP key management with a colon-separated profile list]:profiles: ' \
    '-4[use IPv4 only]' \
    '-6[use IPv6 only]' \
    '-keymatexport[export keying material using label]:label: ' \
    '-keymatexportlen[export len bytes of keying material (default 20)]:length: ' \
    '-status[respond to certificate status requests]' \
    '-status_verbose[enable status request verbose printout]' \
    '-status_timeout[status request responder timeout]:seconds: ' \
    '-status_url[status request fallback URL]:URL: '
  # TODO: srtp profiles
}


_openssl_s_time() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-connect[host:port to connect to (default is localhost:4433)]:host\:port: ' \
    '-nbio[run with non-blocking IO]' \
    '-ssl2[just use SSLv2]' \
    '-ssl3[just use SSLv3]' \
    '-bugs[turn on SSL bug compatibility]' \
    '-new[just time new connections]' \
    '-reuse[just time connection reuse]' \
    "-www[retrieve the specified page from the site]:page: " \
    '-time[max number of seconds to collect data, default 30]:seconds: ' \
    '-verify[turn on peer certificate verification]:depth: ' \
    '-cert[certificate file to use, PEM format assumed]:file:_files' \
    '-key[RSA file to use, PEM format assumed, key is in cert file]:file:_files' \
    "-CApath[PEM format directory of CA's]:file:_files -/" \
    "-CAfile[PEM format file of CA's]:file:_files" \
    '-cipher[preferred cipher to use]:cipher suite:_list_ciphers'
}


_openssl_sess_id() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-inform[input format]:format:(PEM DER)' \
    '-outform[output format]:format:(PEM DER)' \
    '-in[input file (default stdin)]:file:_files' \
    '-out[output file (default stdout)]:file:_files' \
    '-text[print ssl session id details]' \
    '-cert[output certificate ]' \
    '-noout[no CRL output]' \
    '-context[set the session ID context]:id: '
}


_openssl_smime() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-encrypt[encrypt message]' \
    '-decrypt[decrypt encrypted message]' \
    '-sign[sign message]' \
    '-verify[verify signed message]' \
    '-pk7out[output PKCS#7 structure]' \
    '-des3[encrypt with triple DES]' \
    '-des[encrypt with DES]' \
    '-seed[encrypt with SEED]' \
    '-rc2-40[encrypt with RC2-40 (default)]' \
    '-rc2-64[encrypt with RC2-64]' \
    '-rc2-128[encrypt with RC2-128]' \
    '-aes128[encrypt PEM output with cbc aes]' \
    '-aes192[encrypt PEM output with cbc aes]' \
    '-aes256[encrypt PEM output with cbc aes]' \
    '-camellia128[encrypt PEM output with cbc camellia]' \
    '-camellia192[encrypt PEM output with cbc camellia]' \
    '-camellia256[encrypt PEM output with cbc camellia]' \
    "-nointern[don't search certificates in message for signer]" \
    "-nosigs[don't verify message signature]" \
    "-noverify[don't verify signers certificate]" \
    "-nocerts[don't include signers certificate when signing]" \
    '-nodetach[use opaque signing]' \
    "-noattr[don't include any signed attributes]" \
    "-binary[don't translate message to text]" \
    '-certfile[other certificates file]:file:_files' \
    '-signer[signer certificate file]:file:_files' \
    '-recip[recipient certificate file for decryption]:file:_files' \
    '-in[input file]:file:_files' \
    '-inform[input format]:format:(SMIME PEM DER)' \
    '-inkey[input private key (if not signer or recipient)]:file:_files' \
    '-keyform[input private key format]:format:(PEM ENGINE)' \
    '-out[output file]:file:_files' \
    '-outform[output format]:format:(SMIME PEM DER)' \
    '-content[supply or override content for detached signature]:file:_files' \
    '-to[to address]:address: ' \
    '-from[from address]:address: ' \
    '-subject[subject]:subject: ' \
    '-text[include or delete text MIME headers]' \
    '-CApath[trusted certificates directory]:directory:_files -/' \
    '-CAfile[trusted certificates file]:file:_files' \
    "-crl_check[check revocation status of signer's certificate using CRLs]" \
    "-crl_check_all[check revocation status of signer's certificate chain using CRLs]" \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    '-passin[input file pass phrase source]:pass phrase source:_pass_phrase_source' \
    '-rand[files to use for random number input]:file:_rand_files' \
    ':certificate:_files'
}


_openssl_speed() {
  # written for openssl 1.0.1k
  local algorithms
  algorithms=(mdc2 md4 md5 hmac sha1 sha256 sha512 whirlpoolrmd160 idea-cbc \
              seed-cbc rc2-cbc rc5-cbc bf-cbc des-cbc des-ede3 aes-128-cbc \
              aes-192-cbc aes-256-cbc aes-128-ige aes-192-ige aes-256-ige \
              camellia-128-cbc camellia-192-cbc camellia-256-cbc rc4 rsa512 \
              rsa1024 rsa2048 rsa4096 dsa512 dsa1024 dsa2048 ecdsap160 \
              ecdsap192 ecdsap224 ecdsap256 ecdsap384 ecdsap521 ecdsak163 \
              ecdsak233 ecdsak283 ecdsak409 ecdsak571 ecdsab163 ecdsab233 \
              ecdsab283 ecdsab409 ecdsab571 ecdsa ecdhp160 ecdhp192 ecdhp224 \
              ecdhp256 ecdhp384 ecdhp521 ecdhk163 ecdhk233 ecdhk283 ecdhk409 \
              ecdhk571 ecdhb163 ecdhb233 ecdhb283 ecdhb409 ecdhb571 ecdh idea \
              seed rc2 des aes camellia rsa blowfish)
  _arguments -C \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    '-evp[use the specified EVP]:EVP: ' \
    '-decrypt[time decryption instead of encryption (only EVP)]' \
    '-mr[produce machine readable output]' \
    '-multi[run n benchmarks in parallel]:benchmarks: ' \
    "*:algorithm:(${algorithms})"
}


_openssl_spkac() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-in[input file]:file:_files' \
    '-out[output file]:file:_files' \
    '-key[create SPKAC using private key]:file:_files' \
    '-passin[input file pass phrase source]:pass phrase source:_pass_phrase_source' \
    '-challenge[challenge string]:string: ' \
    '-spkac[alternative SPKAC name]:spkacname: ' \
    '-spksect[alternative section name]:section: ' \
    "-noout[don't print SPKAC]" \
    '-pubkey[output public key]' \
    '-verify[verify SPKAC signature]' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines'
}


_openssl_srp() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-verbose[talk a lot while doing things]' \
    '-config[a config file]:file:_files' \
    '-name[the particular srp definition to use]:definition: ' \
    '-srpvfile[the srp verifier file name]:file:_files' \
    '(-modify -delete -list)-add[add an user and srp verifier]' \
    '(-add -delete -list)-modify[modify the srp verifier of an existing user]' \
    '(-add -modify -list)-delete[delete user from verifier file]' \
    '(-add -modify -delete)-list[list user]' \
    '-gn[g and N values to be used for new verifier]:g and N: ' \
    '-userinfo[additional info to be set for user]:userinfo: ' \
    '-passin[input file pass phrase source]:pass phrase source:_pass_phrase_source' \
    '-passout[output file pass phrase source]:pass phrase source:_pass_phrase_source' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    '-rand[files to use for random number input]:file:_rand_files' \
    ':user:'
}


_openssl_ts() {
  # written for openssl 1.0.1k
  # written for openssl 1.0.2e
  local action digests
  digests=(-dss1 -md4 -md5 -mdc2 -ripemd160 -sha -sha1 -sha224 -sha256 \
           -sha384 -sha512 -whirlpool)
  if [[ "${CURRENT}" -eq 2 ]]; then
    # first parameter to ts
    _values 'openssl time stamp action' '-query[time stamp request generation]' '-reply[time stamp response generation]' '-verify[time stamp response verification]'
  else
    action="${words[2]}"
    case "${action}" in
      -query)
        _arguments -C \
          '-rand[files to use for random number input]:file:_rand_files' \
          '-config[config file to use]:file:_files' \
          '(-digest)-data[data file for which the time stamp request needs to be created]:file:_files' \
          '(-data)-digest[digest of the data file]:bytes: ' \
          "($digests)-dss1[use the dss1 message digest algorithm]" \
          "($digests)-md4[to use the md4 message digest algorithm]" \
          "($digests)-md5[to use the md5 message digest algorithm]" \
          "($digests)-mdc2[to use the mdc2 message digest algorithm]" \
          "($digests)-ripemd160[to use the ripemd160 message digest algorithm]" \
          "($digests)-sha[to use the sha message digest algorithm]" \
          "($digests)-sha1[to use the sha1 message digest algorithm]" \
          "($digests)-sha224[to use the sha224 message digest algorithm]" \
          "($digests)-sha256[to use the sha256 message digest algorithm]" \
          "($digests)-sha384[to use the sha384 message digest algorithm]" \
          "($digests)-sha512[to use the sha512 message digest algorithm]" \
          "($digests)-whirlpool[to use the whirlpool message digest algorithm]" \
          '-policy[policy to use for creating the time stamp token]:policy ID: ' \
          '-no_nonce[do not include a nonce in the request]' \
          '-cert[request a signing certificate in the response]' \
          '-in[use the previously created time stamp request]:file:_files' \
          '-out[name of the output file to which the request will be written]:file:_files' \
          '-text[output in human-readable format instead of DER]'
        ;;
      -reply)
        _arguments -C \
          '-config[config file to use]:file:_files' \
          '-section[config file section for response generation]:section: ' \
          '-queryfile[file containing a DER encoded time stamp request]:file:_files' \
          '-passin[private key password source]:pass phrase source:_pass_phrase_source' \
          '-signer[signer certificate of the TSA in PEM format]:file:_files' \
          '-inkey[signer private key in PEM format]:file:_files' \
          '-chain[signer certificate chain in PEM format]:file:_files' \
          '-policy[default policy to use for response]:policy ID: ' \
          '-in[use the previously created time stamp response in DER format]:file:_files' \
          '-token_in[the parameter to -in is a time stamp token in DER format]' \
          '-out[name of the output file to which the response will be written]:file:_files' \
          '-token_out[output a time stamp token instead of a time stamp response]' \
          '-text[output in human-readable format instead of DER]' \
          '-engine[use the specified engine, possibly a hardware device]:engine:_engines'
        ;;
      -verify)
        _arguments -C \
          '(-digest -queryfile)-data[verify response against the specified file]:file:_files' \
          '(-data -queryfile)-digest[verify the response against the specified message digest]:digest bytes: ' \
          '(-data -digest)-queryfile[the original time stamp request in DER format]:file:_files' \
          '-in[time stamp response that needs to be verified in DER format]:file:_files' \
          '-token_in[the parameter to -in is a time stamp token in DER format]' \
          '-CApath[directory containing the trusted CA certificates of the client]:directory:_files -/' \
          '-CAFile[file containing a set of trusted self-signed CA certificates in PEM format]:file:_files' \
          '-untrusted[set of additional untrusted certificates in PEM format which may be needed when building the certificate chain]:file:_files'
        ;;
    esac
  fi
}


_openssl_verify() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-CApath[a directory of trusted certificates]:directory:_files -/' \
    '-CAfile[file A file of trusted certificates]:file:_files' \
    '-purpose[the intended use for the certificate]:purpose:(sslclient sslserver nssslserver smimesign smimeencrypt crlsign any ocsphelper timestampsign)' \
    '*-policy[enable policy processing and add arg to the user-initial-policy-set]:object name or OID: ' \
    '-ignore_critical[ignore critical extensions]' \
    '-attime[perform validation checks using the given time]:timestamp: ' \
    '-check_ss_sig[verify the signature on the self-signed root CA]' \
    "-crlfile[file containing one or more CRL's (in PEM format) to load]:file:_files" \
    '-crl_check[check end entity certificate in CRL]' \
    '-crl_check_all[check all certificates in CRL]' \
    '-policy_check[enables certificate policy processing]' \
    '-explicit_policy[set policy variable require-explicit-policy]' \
    '-inhibit_any[set policy variable inhibit-any-policy]' \
    '-inhibit_map[set policy variable inhibit-policy-mapping]' \
    '-x509_strict[strict X.509-compliance]' \
    '-extended_crl[enable extended CRL features]' \
    '-use_deltas[enable support for delta CRLs]' \
    '-policy_print[print out diagnostics related to policy processing]' \
    '-untrusted[a file of untrusted certificates]:file:_files' \
    '(-*)-help[print out a usage message]' \
    '-issuer_checks[print out diagnostics relating to searches for the issuer certificate of the current certificate]' \
    '-verbose[print extra information about the operations being performed]' \
    '*:certificate:_files'
  # TODO: - may be used to separate certificates from options
  # TODO: Do not hardcode purposes
}


_openssl_version() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-a[all information, this is the same as setting all the other flags]' \
    '-v[the current OpenSSL version]' \
    '-b[the date the current version of OpenSSL was built]' \
    '-o[option information: various options set when the library was built]' \
    '-f[compilation flags]' \
    '-p[platform setting]' \
    '-d[OPENSSLDIR setting]'
}


_openssl_x509() {
  # written for openssl 1.0.1k
  _arguments -C \
    '-inform[input format - default PEM (one of DER, NET or PEM)]:format:(DER NET PEM)' \
    '-outform[output format - default PEM (one of DER, NET or PEM)]:arg:(DER NET PEM)' \
    '-keyform[private key format - default PEM]:arg:(DER PEM)' \
    '-CAform[CA format - default PEM]:arg:(DER PEM)' \
    '-CAkeyform[CA key format - default PEM]:arg:(DER PEM)' \
    '-in[input file - default stdin]:file:_files' \
    '-out[output file - default stdout]:file:_files' \
    '-passin[private key password source]:pass phrase source:_pass_phrase_source' \
    '-serial[print serial number value]' \
    '-subject_hash[print subject hash value]' \
    '-subject_hash_old[print old-style (MD5) subject hash value]' \
    '-issuer_hash[print issuer hash value]' \
    '-issuer_hash_old[print old-style (MD5) issuer hash value]' \
    '-hash[synonym for -subject_hash]' \
    '-subject[print subject DN]' \
    '-issuer[print issuer DN]' \
    '-email[print email address(es)]' \
    '-startdate[notBefore field]' \
    '-enddate[notAfter field]' \
    '-purpose[print out certificate purposes]' \
    '-dates[both Before and After dates]' \
    '-modulus[print the RSA key modulus]' \
    '-pubkey[output the public key]' \
    '-fingerprint[print the certificate fingerprint]' \
    '-alias[output certificate alias]' \
    '-noout[no certificate output]' \
    '-ocspid[print OCSP hash values for the subject name and public key]' \
    '-ocsp_uri[print OCSP Responder URL(s)]' \
    '-trustout[output a "trusted" certificate]' \
    '-clrtrust[clear all trusted purposes]' \
    '-clrreject[clear all rejected purposes]' \
    '-addtrust[trust certificate for a given purpose]:purpose:(clientAuth serverAuth emailProtection)' \
    '-addreject[reject certificate for a given purpose]:purpose:(clientAuth serverAuth emailProtection)' \
    '-setalias[set certificate alias]:alias: ' \
    '-days[how long till expiry of a signed certificate (default 30 days)]:days: ' \
    '-checkend[check whether the cert expires in the specified time]:seconds: ' \
    '-signkey[self sign cert with arg]:file:_files' \
    '-x509toreq[output a certification request object]' \
    '-req[input is a certificate request, sign and output]' \
    '-CA[set the CA certificate, must be PEM format]:file:_files' \
    '-CAkey[set the CA key, must be PEM format]:file:_files' \
    '-CAcreateserial[create serial number file if it does not exist]' \
    '-CAserial[serial file]:file:_files' \
    '-set_serial[serial number to use]' \
    '-text[print the certificate in text form]' \
    '-C[print out C code forms]' \
    '(-md5 -sha1 -mdc2)-md2[digest to use]' \
    '(-md2 -sha1 -mdc2)-md5[digest to use]' \
    '(-md2 -md5 -mdc2)-sha1[digest to use]' \
    '(-md2 -md5 -sha1)-mdc2[digest to use]' \
    '-extfile[configuration file with X509V3 extensions to add]' \
    '-extensions[section from config file with X509V3 extensions to add]' \
    '-clrext[delete extensions before signing and input certificate]' \
    '*-nameopt[various certificate name options]:options:_nameopts' \
    '-engine[use the specified engine, possibly a hardware device]:engine:_engines' \
    '*-certopt[various certificate text options]:options:_certopts'
}


_pass_phrase_source() {
  # pass:password
  # env:var
  # file:pathname
  # fd:number
  # stdin
  _values -S : 'pass phrase source' \
    'pass[obtain the password from the command line]:password: ' \
    'env[obtain the password from the environment variable var]:var:_parameters -g "*export*"' \
    'file[obtain the password from a file]:file:_files' \
    'fd[read the password from the file descriptor number]:number: ' \
    'stdin[read the password from standard input]'
}


_rand_files() {
  # FIXME: this does not allow using multiple files separated by :
  # the following would probably work, but how to generate $files?
  #_values -s : -S ' ' 'random source file or directory' ${files}
  _files
}


_engines() {
  # openssl engines
  local engines
  engines=(${${${(@f)"$(_call_program engines openssl engine)"}%)*}#\(})
  _values 'engines' ${engines}
}


_list_ciphers() {
  # openssl ciphers
  local ciphers
  # add cipher suites
  ciphers=(${(@s/:/)"$(_call_program ciphers openssl ciphers)"})
  # add static cipher strings
  ciphers=(${ciphers} \
    'DEFAULT[the default cipher list]' \
    'COMPLEMENTOFDEFAULT[the ciphers included in ALL but not enabled by default]' \
    'ALL[all cipher suites except the eNULL ciphers]' \
    'COMPLEMENTOFALL[the cipher suites not enabled by ALL]' \
    'HIGH["high" encryption cipher suites]' \
    'MEDIUM["medium" encryption cipher suites]' \
    'LOW["low" encryption cipher suites]' \
    {EXP,EXPORT}'[export encryption algorithms]' \
    'EXPORT40[40 bit export encryption algorithms]' \
    'EXPORT56[56 bit export encryption algorithms]' \
    {eNULL,NULL}'[ciphers offering no encryption]' \
    'aNULL[ciphers offering no authentication]' \
    {kRSA,RSA}'[cipher suites using RSA key exchange]' \
    'kDHr[cipher suites using DH key agreement signed by CAs with RSA keys]' \
    'kDHd[cipher suites using DH key agreement signed by CAs with DSS keys]' \
    'kDH[cipher suites using DH key agreement]' \
    {kDHE,kEDH}'[cipher suites using ephemeral DH key agreement, including anonymous cipher suites]' \
    {DHE,EDH}'[cipher suites using authenticated ephemeral DH key agreement]' \
    'ADH[anonymous DH cipher suites, not including anonymous ECDH ciphers]' \
    'DH[cipher suites using DH, including anonymous DH, ephemeral DH and fixed DH]' \
    'kECDHr[cipher suites using fixed ECDH key agreement signed by CAs with RSA keys]' \
    'kECDHe[cipher suites using fixed ECDH key agreement signed by CAs with ECDSA keys]' \
    'kECDH[cipher suites using fixed ECDH key agreement]' \
    {kECDHE,kEECDH}'[cipher suites using ephemeral ECDH key agreement, including anonymous cipher suites]' \
    {ECDHE,kEECDH}'[cipher suites using authenticated ephemeral ECDH key agreement]' \
    'AECDH[anonymous Elliptic Curve Diffie Hellman cipher suites]' \
    'ECDH[cipher suites using ECDH key exchange, including anonymous, ephemeral and fixed ECDH]' \
    'aRSA[cipher suites using RSA authentication]' \
    {aDSS,DSS}'[cipher suites using DSS authentication]' \
    'aDH[cipher suites effectively using DH authentication]' \
    'aECDH[cipher suites effectively using ECDH authentication]' \
    {aECDSA,ECDSA}'[cipher suites using ECDSA authentication]' \
    'TLSv1.2[TLSv1.2 cipher suites]' \
    'TLSv1[TLSv1.0 cipher suites]' \
    'SSLv3[SSLv3.0 cipher suites]' \
    'SSLv2[SSLv2.0 cipher suites]' \
    'AES128[cipher suites using 128 bit AES]' \
    'AES256[cipher suites using 256 bit AES]' \
    'AES[cipher suites using AES]' \
    'AESGCM[AES in Galois Counter Mode (GCM)]' \
    'CAMELLIA128[cipher suites using 128 bit CAMELLIA]' \
    'CAMELLIA256[cipher suites using 256 bit CAMELLIA]' \
    'CAMELLIA[cipher suites using CAMELLIA]' \
    '3DES[cipher suites using triple DES]' \
    'DES[cipher suites using DES (not triple DES)]' \
    'RC4[cipher suites using RC4]' \
    'RC2[cipher suites using RC2]' \
    'IDEA[cipher suites using IDEA]' \
    'SEED[cipher suites using SEED]' \
    'MD5[cipher suites using MD5]' \
    {SHA1,SHA}'[cipher suites using SHA1]' \
    'SHA256[cipher suites using SHA256]' \
    'SHA384[cipher suites using SHA284]' \
    'aGOST[cipher suites using GOST R 34.10 for authentication]' \
    'aGOST01[cipher suites using GOST R 34.10-2001 authentication]' \
    'aGOST94[cipher suites using GOST R 34.10-94 authentication]' \
    'kGOST[cipher suites, using VKO 34.10 key exchange]' \
    'GOST94[cipher suites, using HMAC based on GOST R 34.11-94]' \
    'GOST89MAC[cipher suites using GOST 28147-89 MAC instead of HMAC]' \
    'PSK[cipher suites using pre-shared keys (PSK)]' \
    'SUITEB128[suite B mode operation using 128 or 192 bit level of security]' \
    'SUITEB128ONLY[suite B mode operation using 128 bit level of security]' \
    'SUITEB192[suite B mode operation using 192 bit level of security]' \
    )
  # FIXME: support !, + and - before each cipher suite
  _values -s : 'cipher suite' ${ciphers}
}


_list_curves() {
  # openssl ecparam -list_curves
  local curves not_curves
  curves="$(_call_program list_curves openssl ecparam -list_curves)"
  # identify lines that do not contain curve names but only descriptions
  not_curves=(${${(f)curves[@]}:#*:*})
  # remove non-curve lines, trailing descriptions and leading spaces
  curves=(${${${${(f)curves[@]}:|not_curves}%:*}##* })
  _values 'named curves' ${curves}
}


_list_message_digest_algorithms() {
  # openssl list-message-digest-algorithms
  local algorithms
  algorithms=(${${(@f)"$(_call_program message_digest_algorithms openssl list-message-digest-algorithms)"}%% *})
  _values 'message digest algorithms' ${algorithms}
}


_nameopts() {
  _values -s ',' -w 'nameopts' \
    '(-compat compat)'{-compat,compat}'[use the old format. This is equivalent to specifying no name options at all]' \
    '(-RFC2253 RFC2253)'{-RFC2253,RFC2253}'[displays names compatible with RFC2253 equivalent to esc_2253, esc_ctrl, esc_msb, utf8, dump_nostr, dump_unknown, dump_der, sep_comma_plus, dn_rev and sname]' \
    '(-oneline oneline)'{-oneline,oneline}'[a oneline format which is more readable than RFC2253. Equivalent to esc_2253, esc_ctrl, esc_msb, utf8, dump_nostr, dump_der, use_quote, sep_comma_plus_space, space_eq and sname options]' \
    '(-multiline multiline)'{-multiline,multiline}'[a multiline format. Equivalent to esc_ctrl, esc_msb, sep_multiline, space_eq, lname and align]' \
    '(-esc_2253 esc_2253)'{-esc_2253,esc_2253}'[escape the "special" characters required by RFC2253 in a field]' \
    '(-esc_ctrl esc_ctrl)'{-esc_ctrl,esc_ctrl}'[escape control characters]' \
    '(-esc_msb esc_msb)'{-esc_msb,esc_msb}'[escape characters with the MSB set]' \
    '(-use_quote use_quote)'{-use_quote,use_quote}'[escapes some characters by surrounding the whole string with " characters]' \
    '(-utf8 utf8)'{-utf8,utf8}'[convert all strings to UTF8 format first]' \
    '(-ignore_type ignore_type)'{-ignore_type,ignore_type}'[this option does not attempt to interpret multibyte characters in any way]' \
    '(-show_type show_type)'{-show_type,show_type}'[show the type of the ASN1 character string]' \
    '(-dump_der dump_der)'{-dump_der,dump_der}'[use DER encoding when hexdumping fields]' \
    '(-dump_nostr dump_nostr)'{-dump_nostr,dump_nostr}'[dump non character string types]' \
    '(-dump_all dump_all)'{-dump_all,dump_all}'[dump all fields]' \
    '(-dump_unknown dump_unknown)'{-dump_unknown,dump_unknown}'[dump any field whose OID is not recognised by OpenSSL]' \
    '(-sep_comma_plus sep_comma_plus)'{-sep_comma_plus,sep_comma_plus}'[these options determine the field separators]' \
    '(-sep_comma_plus_space sep_comma_plus_space)'{-sep_comma_plus_space,sep_comma_plus_space}'[these options determine the field separators]' \
    '(-sep_semi_plus_space sep_semi_plus_space)'{-sep_semi_plus_space,sep_semi_plus_space}'[these options determine the field separators]' \
    '(-sep_multiline sep_multiline)'{-sep_multiline,sep_multiline}'[these options determine the field separators]' \
    '(-dn_rev dn_rev)'{-dn_rev,dn_rev}'[reverse the fields of the DN]' \
    '(-nofname nofname)'{-nofname,nofname}'[do not display field names]' \
    '(-sname sname)'{-sname,sname}'[display field names in short form]' \
    '(-lname lname)'{-lname,lname}'[display field names in long form]' \
    '(-oid oid)'{-oid,oid}'[display field names in numerical form]' \
    '(-align align)'{-align,align}'[align field values for a more readable output. Only usable with sep_multiline]' \
    '(-space_eq space_eq)'{-space_eq,space_eq}'[places spaces around the = character which follows the field name]'
}


_certopts() {
  _values -s ',' -w 'certopts' \
    'compatible[use the old format. This is equivalent to specifying no output options at all]' \
    "no_header[don't print header information: that is the lines saying \"Certificate\" and \"Data\"]" \
    "no_version[don't print out the version number]" \
    "no_serial[don't print out the serial number]" \
    "no_signame[don't print out the signature algorithm used]" \
    "no_validity[don't print the validity, that is the notBefore and notAfter fields]" \
    "no_subject[don't print out the subject name]" \
    "no_issuer[don't print out the issuer name]" \
    "no_pubkey[don't print out the public key]" \
    "no_sigdump[don't give a hexadecimal dump of the certificate signature]" \
    "no_aux[don't print out certificate trust information]" \
    "no_extensions[don't print out any X509V3 extensions]" \
    'ext_default[retain default extension behaviour: attempt to print out unsupported certificate extensions]' \
    'ext_error[print an error message for unsupported certificate extensions]' \
    'ext_parse[ASN1 parse unsupported extensions]' \
    'ext_dump[hex dump unsupported extensions]' \
    '(no_issuer no_pubkey no_header no_version no_sigdump no_signame)ca_default[the value used by the ca utility, equivalent to no_issuer, no_pubkey, no_header, no_version, no_sigdump and no_signame]'
}


_openssl "$@"

# vim: ft=zsh sw=2 ts=2 et
