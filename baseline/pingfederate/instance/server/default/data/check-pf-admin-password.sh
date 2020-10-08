#!/bin/bash

# Read Password
echo -n Enter PingFed Admin Password to check:
read -s password
echo
echo

# Read hashed value
export rawhash=$(grep adm:hash pingfederate-admin-user.xml | sed 's#\s*<[^>]*>##g')
echo pingfederate-admin-user.xml hash value $rawhash

export base64hash=$(echo -n $rawhash | cut -d. -f1 | sed "s#_#/#g" | sed "s/-/+/g")
# check for truncated base64 value
if [ $((${#base64hash} % 2)) -eq 1 ]; then
    export base64hash=${base64hash}=
fi
export base64salt=$(echo -n $rawhash | cut -d. -f2 | sed "s#_#/#g" | sed "s/-/+/g")
if [ $((${#base64salt} % 2)) -eq 1 ]; then
    export base64salt=${base64salt}=
fi
export algorithmid=$(echo -n $rawhash | cut -d. -f3)

if [ $(uname) = "Darwin" ]; then
  export decodeArg='-D'
else
  export decodeArg='-d'
fi

export hash=$(echo -n $base64hash | base64 $decodeArg | xxd -ps -c 32)
echo decoded hash value $hash

export salt=$(echo -n $base64salt | base64 $decodeArg | xxd -ps -c 32)
echo decoded salt value $salt

echo 'algorithm         ' $algorithmid

# Convert salt to binary file
export saltbin=$(echo -n $salt | xxd -r -p)

echo
echo Computing hash value for entered password...
iter=$(echo -n ${saltbin}${password} | echo -n $(openssl sha256) | cut -d" " -f2)${salt};for i in {1..10000};do [[ ($(($i % 2)) = 0) ]] && iter=$(echo -n $iter | xxd -r -p | echo -n $(openssl sha256) | cut -d" " -f2)${salt} || iter=${salt}$(echo -n $iter | xxd -r -p | echo -n $(openssl sha256) | cut -d" " -f2); done; export computedhash=${iter:0:64}
echo hash=$computedhash

if [ $hash = $computedhash ]; then
    echo "Hash matches for entered password!"
else
    echo "Hash does NOT match for entered password!"
fi
