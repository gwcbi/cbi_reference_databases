#! /bin/bash

rroot=$(git rev-parse --show-toplevel)

# Sync all builds
mkdir -p /lustre/groups/cbi/shared/Databases/NCBI_rep_genomes
for build in NCBI_rep_genomes/????????; do
    rsync -av $build/*.bt2 /lustre/groups/cbi/shared/Databases/$build
done

# Link to the latest
cd /lustre/groups/cbi/shared/Databases/NCBI_rep_genomes && \
    rm -f latest && \
    ln -s $(ls . | sort | tail -n1) latest && \
    cd $rroot

# Sync all builds
mkdir -p /lustre/groups/cbi/shared/Databases/NCBI_16SMicrobial
for build in NCBI_16SMicrobial/????????; do
    rsync -av $build/*.bt2 /lustre/groups/cbi/shared/Databases/$build
done

cd /lustre/groups/cbi/shared/Databases/NCBI_16SMicrobial && \
    rm -f latest && \
    ln -s $(ls . | sort | tail -n1) latest && \
    cd $rroot

# Sync all builds
mkdir -p /lustre/groups/cbi/shared/Databases/plasmaDB
for build in plasmaDB/????????; do
    rsync -av $build/*.bt2 /lustre/groups/cbi/shared/Databases/$build
done

cd /lustre/groups/cbi/shared/Databases/plasmaDB && \
    rm -f latest && \
    ln -s $(ls . | sort | tail -n1) latest && \
    cd $rroot
