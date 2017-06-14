#! /bin/bash

rroot=$(git rev-parse --show-toplevel)

### NCBI_rep_genomes #####################################################################
mkdir -p /lustre/groups/cbi/shared/Databases/NCBI_rep_genomes
for build in NCBI_rep_genomes/????????; do
    rsync -av $build/*.bt2 /lustre/groups/cbi/shared/Databases/$build
done

# Link to the latest
cd /lustre/groups/cbi/shared/Databases/NCBI_rep_genomes && \
    rm -f latest && \
    ln -s $(ls . | sort | tail -n1) latest && \
    cd $rroot

### NCBI_16SMicrobial ####################################################################
mkdir -p /lustre/groups/cbi/shared/Databases/NCBI_16SMicrobial
for build in NCBI_16SMicrobial/????????; do
    rsync -av $build/*.bt2 /lustre/groups/cbi/shared/Databases/$build
done

cd /lustre/groups/cbi/shared/Databases/NCBI_16SMicrobial && \
    rm -f latest && \
    ln -s $(ls . | sort | tail -n1) latest && \
    cd $rroot

### plasmaDB #############################################################################
mkdir -p /lustre/groups/cbi/shared/Databases/plasmaDB
for build in plasmaDB/????????; do
    rsync -av $build/*.bt2 /lustre/groups/cbi/shared/Databases/$build
done

cd /lustre/groups/cbi/shared/Databases/plasmaDB && \
    rm -f latest && \
    ln -s $(ls . | sort | tail -n1) latest && \
    cd $rroot

### kraken database ######################################################################
mkdir -p /lustre/groups/cbi/shared/Databases/kraken
for build in kraken/????????; do
    rsync -av $build /lustre/groups/cbi/shared/Databases/$build
done

cd /lustre/groups/cbi/shared/Databases/kraken && \
    rm -f latest && \
    ln -s $(ls . | sort | tail -n1) latest && \
    cd $rroot

### centrifuge database ##################################################################
mkdir -p /lustre/groups/cbi/shared/Databases/centrifuge
for build in centrifuge/????????; do
    rsync -av $build/*.cf /lustre/groups/cbi/shared/Databases/$build
done

cd /lustre/groups/cbi/shared/Databases/centrifuge && \
    rm -f latest && \
    ln -s $(ls . | sort | tail -n1) latest && \
    cd $rroot
