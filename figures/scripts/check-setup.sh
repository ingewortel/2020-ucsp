
# Depending on system, check if basic tools are there.
system=$(uname -s)
if [ $system == "Darwin" ] ; then
	# This will open a prompt to install xcode CLT if it is not there, or otherwise
	# this will do nothing.
	xcode-select --install &> /dev/null
	echo "** 	Xcode CLT :	OK "
elif [ $system == "Linux" ] ; then
	checkEssentials=$( locate build-essential | wc -l )
	if [ $checkEssentials -eq 0 ] ; then
		echo "ERROR - Your computer does not appear to have build-essentials installed! Please install before continuing."
		echo ""
		echo "	Try:"
		echo "		sudo apt-get install build-essential"
		echo "	or try the equivalent for your package manager."
		exit 1
	else
		echo "** 	build-essentials :	OK "
	fi
else 
	echo "WARNING: Unknown system. Please ensure that you have basic command line tools (C compiler, make, ...) before continuing."
fi

# check latex
checkLatex=$(command -v pdflatex | wc -l )
checkLatexmk=$(command -v latexmk | wc -l )

if [[ $checkLatex == 0 || $checkLatexmk == 0 ]] ; then \
	echo "ERROR - Your computer does not appear to have latex (or all required packages) installed!"
	echo "	 Please install before continuing, and ensure you have the commands 'pdflatex', 'latexmk', and latex packages such as tikz installed."
	echo ""
	echo "	On linux, try:"
	echo "		sudo apt-get install texlive"
	echo "		sudo apt-get install texlive-latex-extra"
	echo "		sudo apt-get install latexmk"
	echo "	On Mac OS X, try:"
	echo "		brew cask install mactex"
	exit 1
else
	echo "** 	Latex-etc :	OK "
fi

# check bc on linux (mac should have it)
checkBc=$(command -v bc | wc -l )

if [ $checkBc != 1 ] ; then \
	echo "ERROR - Your computer does not appear to have bc installed! Please install before continuing."
	echo ""
	echo "	On linux, try:"
	echo "		sudo apt-get install bc"
	echo "	On Mac OS X, you should have bc by default. Please Google to find out what's wrong."
	exit 1
else
	echo "** 	bc :		OK "
fi


# Check if R is installed
Rinstall=$(command -v R | wc -l)

if [ $Rinstall != 1 ] ; then \
	echo "ERROR - Your computer does not appear to have R installed! Please install R before continuing."
	echo ""
	echo "	On linux, try:"
	echo "		sudo apt-get install R"
	echo "	On Mac OS X, try:"
	echo "		brew install R"
	echo "	or visit https://cloud.r-project.org/"
	exit 1
else
	echo "** 	R :		OK "
fi


# Check if nodejs is installed
nodeCheck=$(command -v node | wc -l )

if [ $nodeCheck != 1 ] ; then \
	echo "ERROR - Your computer does not appear to have nodejs installed! Please install nodejs before continuing."
	echo ""
	echo "	On linux, try:"
	echo "		sudo apt-get install nodejs"
	echo "	On Mac OS X, try:"
	echo "		brew install node"
	echo "	or visit https://nodejs.org/en/download/"
	exit 1
else
	echo "** 	nodejs :	OK "
fi

# Check if nodejs is installed
npmCheck=$(command -v npm | wc -l )

if [ $npmCheck != 1 ] ; then \
	echo "ERROR - Your computer does not appear to have the node package manager npm installed! Please install npm before continuing."
	echo ""
	echo "	On linux, try:"
	echo "		sudo apt-get install npm"
	echo "		(You may have to install libssl1.0-dev, nodejs-dev, and node-gyp first using the same command.)"
	echo "	On Mac OS X, try:"
	echo "		brew install node"
	echo "	or visit https://nodejs.org/en/"
	exit 1
else
	echo "** 	npm :	OK "
fi



echo "Setup OK!"
