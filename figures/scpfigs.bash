setget=$1
figures=$2


if [ $setget == "get" ] ; then
	echo "getting figures from inge@computational-immunology.org:ucsp-paper/"
	scp inge@computational-immunology.org:ucsp-paper/*.pdf .
elif [ $setget == "set" ] ; then
	echo "putting figures in inge@computational-immunology.org:ucsp-paper/"
	scp $figures inge@computational-immunology.org:ucsp-paper/
fi

