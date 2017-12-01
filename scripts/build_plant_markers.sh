#! /bin/bash

[[ -n ${1+x} ]] && build=$1
[[ -z ${build+x} ]] && build=$(date +"%Y%m%d")

#--- Download all the genomes from FTP
umask 0002
mkdir -p plant_markers/${build}/Archive && cd plant_markers/${build}/Archive

#--- Gathering Sequences
# trnH–psbA:
#	Supplemental data from: Utility of the trnH–psbA Intergenic Spacer Region and Its Combinations as Plant DNA Barcodes: A Meta-Analysis
#   Accession numbers were pulled, and queried from NCBI.
#       tp_accessions.txt
#
#   
# ITS2	https://www.ncbi.nlm.nih.gov/pubmed/26248563
#   Fasta file was downloaded, and GI numbers pulled.
#       its2_orginal.fasta
#   GI numbers were queried from NCBI, and accession numbers pulled.
#       its2_gi.txt
#   Removed duplicate accession numbers, and re-queried from NCBI.
#       its2_uniq_accessions.txt
#
#
# rbcL	https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5357121/#bib1
#   Fasta file was downloaded, and accession numbers pulled.
#       rbcL_original.fasta
#   Accession numbers were queried from NCBI. 
#       rbcL_accessions.txt
#
#
# Resulting files: 3 fasta files - each representing all (no dublicates) sequences for each marker
#   trnH_psbA_seqs.fna, its2_seqs.fna, rbcL_seqs.fna

#--- Copy and rename fastas
cd ..
for p in Archive/*_seqs.fna; do
    cat $p > $(basename ${p%seqs*})marker_seqs.fna
done

#--- Create .gitignore
echo -e '*\n!.gitignore' > .gitignore

#--- Build the index with bowtie2
for p in *.fna; do 
sbatch -N 1 -t 300 -p short,defq  <<EOF
#! /bin/bash
umask 0002
module load bowtie2/2.2.3
bowtie2-build $p ${p%.*}
EOF

done
