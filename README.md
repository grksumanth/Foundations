# Foundations
#Author GRK

The cracker is a shell file which needs mkpasswd.

To add additional algo which is supported by the mkpasswd type "mkpasswd -m help"

add the same in the if block and set the "usedalgo" in the script.

Right now supporting md5, sha256, sha512 algo for the linux password file unshadowed

Perl or python script can also be mixed to get access to newer algo 

or add "smbencrypt password | awk '{print $1}'" to get the LM hash and compare it.

totally flexible and can be re-written easily or modified based on the need.

crypto.sh -e <receiver public key> <sender private key> <plain file> <encrypted file>
