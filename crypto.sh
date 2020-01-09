#! /bin/bash
encrypt=false
decrypt=false

#checking if the openssl and tar are present if not we are aborting
if ! type openssl &> /dev/null; then
	echo " Openssl not present please install and retry "
	exit 1
fi

if ! type tar &> /dev/null; then
	echo "Install tar and retry"
	exit 1
fi

#Taking in the options for either encrypting or decrypting the file
#if neither of them are present we are printing the options available
if [ $1 == "-e" ];then
	encrypt=true
	elif [ $1 == "-d" ]; then 
		decrypt=true
		else
			echo "must be either -e for encrypting the file or -d for  decrypting  "
			exit 1
	fi
	filesvalid=false
#checking for the input files valid in the system or not if not present we desplay error
	if [[ ! -f $2 || ! -f $3 || ! -f $4 ]]; then
	echo "one or more files were missing please check the files provided "
	exit 1
	else
	filesvalid=true
fi

#This if block is for encrypting the data
#We take a temporary file and srite the data into them and delete them
if [ $encrypt == "true" ]; then
	temp_file=$(mktemp XXXXXXXXXX.bin)
	temp_sha512=$(mktemp XXXXXXXXX.sha512)
	temp_store=$(mktemp XXXXXXXXXXX.encrypted)
	temp_file_enc="$temp_file.enc"

	#Generating the base64 string.
	openssl rand -base64 32 > $temp_file

	#Encrypting the above generated string using RSA.
	openssl rsautl -encrypt -inkey $2 -pubin -in $temp_file -out $temp_file_enc

	#openssl rsautl -encrypt -inkey $2 -pubin -in $4 -out $temp_store
	#Issue while decrypt.
	#just to make sure data is flushed into the hard disk for file access.
	sync

	#Encrypting the data in the file using the key generated.
	openssl enc -aes-256-cbc -salt -a -pbkdf2 -in $4 -out $temp_store -k $(<$temp_file)

	#Signing the Encrypted file using SHA512 hash function and zipping the file
	openssl dgst -sha512 -sign $3 -out $temp_sha512 $temp_store
	tar -cf $5 $temp_store $temp_sha512 $temp_file_enc
	# flushing the data.
	sync
	#Removing the temporary files
	rm $temp_store
	rm $temp_sha512
	rm $temp_file_enc
	rm $temp_file
fi

# Block used for decryption
if [ $decrypt == "true" ]; then
	#make temp directory and move to that
	public_key=$(<$2)
	temp_dir=$(mktemp -d XXXXXXXX)
	#copying the necessary files to the temporary directory and unzipping the file
	cp $4 $temp_dir
	cp $2 $temp_dir
	cp $3 $temp_dir
	cd $temp_dir
	tar -xf $4

	#making necessary files for the usage in the system.
	# we find files by the extension we provide while encrypting
	sha512_file=$(find . -type f -name "*.sha512")
	encrypted_file=$(find . -type f -name "*.encrypted")
	key_bin_enc=$(find . -type f -name "*.enc")
	key_bin=$(mktemp XXXXXXX.enc)

	#Checking of all the files were presnt or another output was given
	if [[ -f $sha512_file && -f $encrypted_file && -f $key_bin_enc ]]
	then
		#taking the basse name of the file s we moved to that directory and performing the actions.
		key_bin_enc=$(basename -- "$key_bin_enc")
		sync

		#checking for the signature match if not verified we are exiting the application
		verify_sha=$(openssl dgst -sha512 -verify "$3" -signature "$sha512_file" "$encrypted_file")
		#echo "$verify_sha"

		#If verified OK then we are proceeding forward and checking the data.
		if [ "$verify_sha" == "Verified OK" ]; then

			#decrypting the Symmetric key using RSA Utility.
			#sending the output to null.
			openssl rsautl -decrypt -inkey $2 -in $key_bin_enc -out $key_bin &> /dev/null

			#taking the decrypted key and then decrypting the encrypted data
			#sending the output to /dev/null.
			openssl enc -d -aes-256-cbc -pbkdf2 -a -in $encrypted_file -out $5 -k $(<$key_bin) &> /dev/null

			#moving the output to the parent folder i.e where the command is executed
			#and changing to the previous directory and removing the temporary directory
			#checking if the file exist if it doesn't then there is a publick key mismatch 
			if [ -f $5 ]; then
				cp $5 ..
			else
				echo "Public Key mismatch..!!!"
				cd ..
				rm -rf $temp_dir
				exit 1
			fi
			cd ..
			rm -rf $temp_dir
			else
				echo "Verification Failure..!! check public and private key pair"
				exit 1
		fi

		#openssl rsautl -decrypt -inkey $2 -in $4 -out $5
		else
			echo "Files corrupted!!"
			exit 1
	fi
fi
