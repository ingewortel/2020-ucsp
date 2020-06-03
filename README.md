# 2020-ucsp
This repository will contain all simulation code for the manuscript "An actin-inspired positive feedback loop explains the universal coupling between speed and persistence in a  computational model of cell migration".




## Dependencies and installation

First-time users can install dependencies from the `figures/` folder by typing:

```
make aux/setup
```

This should help you install the required dependencies automatically on most systems.
If you run into problems, see below for details on how to install manually.

#### 1 Install Make and other command line essentials

We here use GNU Make to generate the figures automatically using all the code.
If you get an error that you don't have make, you may still have to install it.

On Mac OS X, install it by getting the Xcode command line tools. In the terminal, type:

```
xcode-select --install
```

This will also get you other essentials that you will need.

On Linux, you can run:

```
sudo apt-get install build-essential
```

which again will install make along with other essentials (such as C++ compilers).


#### 2 Install node and npm

See [https://nodejs.org/en/download/package-manager/](this page) for details.


#### 3 Install node packages

Inside the figures folder, there is a file `package.json` which contains all the information
on the node modules needed. To install these dependencies, simply go to this folder and 
type:

```
npm install
```


#### 4 Install R and some packages

Most of the analysis and plotting was done in R, which you can get at 
[https://cloud.r-project.org/](https://cloud.r-project.org/).

You will also need to install several R packages for all the code to run. 


Once you have R (and Xcode CLT, step 1) installed, open R from the terminal using:
```
R
```

Then type the following to install the required packages:

```
install.packages( "ggplot2" )
install.packages( "dplyr" )
install.packages( "ggrepel" )
install.packages( "grid" )
install.packages( "celltrackR" )
```
If R asks you to select a CRAN mirror, you can just choose 1 or another of the listed
numbers (preferably a location nearby).



## How to build the figures


To make all figures, simply run `make` from the `figures/` folder. 
Note that simulations will be run for this and this can take very long, so you may want to do it inside a `screen`.

If you just want to do a quick run to see how the code works, look for the `settings.env` file and adjust the 
`NSIM`, `GROUPSIZE` and `RUNTIME` parameters according to the recommendations there.

If you have multiple cores, you may try using them to run simulations in parallel; e.g.
allow make to use 4 cores by saying:

```
make -j 4
```

To build a single figure, go inside a folder (eg `figure1/`) and type `make`:

```
cd figure1
make
```

This will automatically build the figure.  Note that some
figure use data from other figures, so it is possible that data will also be generated
in the other folders.



