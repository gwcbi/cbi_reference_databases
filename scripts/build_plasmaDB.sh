#! /bin/bash

[[ -n ${1+x} ]] && build=$1
[[ -z ${build+x} ]] && build=$(date +"%Y%m%d")

# Load modules
module load bowtie2

# Get the repository root directory
rroot=$(git rev-parse --show-toplevel)

#--- Set the build directory
builddir=$rroot/plasmaDB/$build && cd $builddir

#--- Find files that begin with "acc."
for f in orig/acc.*; do
    echo "Getting sequences for accessions in $f"
    bn=$(basename ${f%.*})
    python $rroot/scripts/get_seqs_by_accession.py \
        --email bendall@gwu.edu \
        --fasta $rroot/NCBI_rep_genomes/latest/ref_viruses_rep_genomes_ti.fna \
        $f > ${bn#*.}.fna
done

#--- Find fasta files
#--- The files should be named so that the taxonomy ID is the first part of the name
for f in orig/*.fasta; do
    bn=$(basename ${f%.*})
    tx=${bn%%.*} 
    echo "Adding taxonomy ID ${bn%%.*} to sequences in $f"
    python $rroot/scripts/add_ti_fasta.py \
        --delim '.' --idx -1 \
        $tx $f > ${bn#*.}.fna
done

#--- Create the bowtie2 database
echo "Building the bowtie2 databases"
for f in *.fna; do
    bowtie2-build $f $(basename ${f%.*})
done

echo -e '*\n!.gitignore' > .gitignore

cd $rroot
