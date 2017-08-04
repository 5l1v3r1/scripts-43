#!/bin/bash
# https://github.com/jnqpblc/Randomness/blob/master/3.mapping/automated-va/run-auto-ikeforce.sh

IFS=$'\n';
for line in $(grep -H 'Auth=PSK' ikescan-*-aggressive-mode.txt); do
	IP=$(echo $line|egrep -o '([0-9]{1,3}\.){3}([0-9]{1,3})');
	ENC=$(echo $line|egrep -o 'Enc=[^ ]+');
	HASH=$(echo $line|egrep -o 'Hash=[^ ]+');
	GROUP=$(echo $line|egrep -o 'Group=[0-9]');

if [ $ENC == 'Enc=3DES' ];then CRYPTO='5';
elif  [ $ENC == 'Enc=AES' ];then CRYPTO='7';
elif  [ $ENC == 'Enc=DES' ];then CRYPTO='1';
else
	printf '\nDammit Bobby. Wrong crypto.\n'
	exit 0
fi

if [ $HASH == 'Hash=MD5' ];then HMAC='1';
elif  [ $HASH == 'Hash=SHA1' ];then HMAC='2';
elif  [ $HASH == 'Hash=SHA2-256' ];then HMAC='4';
elif  [ $HASH == 'Hash=SHA2-384' ];then HMAC='5';
elif  [ $HASH == 'Hash=SHA2-512' ];then HMAC='6';
else
	printf '\nDammit Bobby. Wrong hmac.\n';
	exit 0;
fi

if [ $GROUP == 'Group=1' ];then DH='1';
elif  [ $GROUP == 'Group=2' ];then DH='2';
elif  [ $GROUP == 'Group=5' ];then DH='5';
else
	printf '\nDammit Bobby. Wrong group.\n';
	exit 0;
fi

if [ -z  $CRYPTO ];then
		printf '\nDammit Bobby. Empty crypto\n';
		exit 0;
	else
		if [ -z  $HASH ];then
			printf '\nDammit Bobby. Empty hash\n';
			exit 0;
		else
			if [ -z  $DH ];then
				printf '\nDammit Bobby. Empty dh\n';
				exit 0
			else
				bash run-ikeforce.sh $IP $CRYPTO $HMAC 1 $DH;
        echo
			fi
		fi
	fi
done

