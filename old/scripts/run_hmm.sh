#!/bin/sh

date

# set class path
export CLASSPATH="../code/stallone_121105.jar"
export CLASSPATH=$CLASSPATH:"../code/exp-stallone_121105.jar" 
export CLASSPATH=$CLASSPATH:"../code/colt-1.2.0.jar"
export CLASSPATH=$CLASSPATH:"../code/netlib-java-0.9.1.jar"
export CLASSPATH=$CLASSPATH:"../code/arpack-combo-0.1.jar"
echo $CLASSPATH


# parameter of the HMM algorithm
NSTATES		= 3
TIMESCALE	= 10000
NSCANSTEPS	= 3
NSCANS 		= 50
NCONVSTEPS 	= 100
DECTOL		= 1

# directories and files
DATFILES=../../data/data_5mM_1ms/*.dat
BG_FILE=../../data/background.dat
OUTDIR=../output/hmm_5mM_1ms/


for N in 01 02 03 04 05; do

	# make output directory
        mkdir $OUTDIR/HMM$N

	# and execute program 
	java -Xmx2000M exp.ui.Fret_HMM \
	-i $DATFILES \
	-background  $BG_FILE \
	-reversible \
	-EMmult $NSTATES $TIMESCALE $NSCANSTEPS $NSCANS $NCONVSTEPS $DECTOL \
	-o $OUTDIR/HMM$N \
	-outputMaxPath	 \
	-outputViterbi	\
	-outputEMaxPath	\
	-outputEViterbi	\
	> $OUTDIR/HMM$N/HMM$N.out



	# change to output directory and post-process output
	mv $OUTDIR/HMM$N/par.dat  $OUTDIR/HMM$N.param							# model parameters	
	mv $OUTDIR/HMM$N/par_E.dat  $OUTDIR/HMM$N.fret							# fret efficiencies
	mv $OUTDIR/HMM$N/par_statdist.dat  $OUTDIR/HMM$N.statdist						# equilibrium distribution
	mv $OUTDIR/HMM$N/par_T.dat $OUTDIR/HMM$N.T								# transition matrix
        mv $OUTDIR/HMM$N/lifedist-data.dat $OUTDIR/HMM$N.lifedist.data                                     # lifetime distribution from the data
        mv $OUTDIR/HMM$N/lifedist-T.dat $OUTDIR/HMM$N.lifedist.T                                           # lifetime distribution from the model

        grep -A $NSTATES num $OUTDIR/HMM$N/HMM$N.out > $OUTDIR/HMM$N.stateDef                             	# state definitions E vs equ-population
        grep "State Properties" $OUTDIR/HMM$N/HMM$N.out | sed 's/State Properties://' > $OUTDIR/HMM$N.logL # log likelihood

        mv $OUTDIR/HMM$N/HMM$N.out $OUTDIR/HMM$N.out                                                      	# rename output file

done

date
