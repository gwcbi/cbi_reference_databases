#! /bin/bash

[[ -n ${1+x} ]] && build=$1
[[ -z ${build+x} ]] && build=$(date +"%Y%m%d")

#--- Download all the genomes from FTP
umask 0002
mkdir -p NCBI_rep_fungi/${build}/Archive && cd NCBI_rep_fungi/${build}/Archive

# First parse the directory listing to get available species
curl -s ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/fungi/ | tr -s ' ' | cut -f9 -d' ' > SPECIES.txt

# Now download the representative genome DNA file for each
cat SPECIES.txt | while read sp; do
    echo $sp
    rsync --partial --progress -iav ftp.ncbi.nlm.nih.gov::genomes/refseq/fungi/${sp}/representative/*/*_genomic.fna.gz .
done

rm -f *_rna_* && rm -f *_cds_* #removing the rna and cds files

rsync --partial --progress -iav ftp.ncbi.nlm.nih.gov::genomes/refseq/fungi/assembly_summary.txt .

cut -f 1,8,7 assembly_summary.txt | sed 's/ /_/g'| grep -v '^#' > mapping.txt

#--- Update the sequence IDs with taxonomy ID
for p in *_genomic.fna.gz; do
    fn=$(basename $p)
    bd=${fn%_*}
    acc=$(echo $bd | cut -d "_" -f1,2)
    ti=$(grep "$acc" mapping.txt | cut -f2)
    gunzip -c $p | perl -lne 's/^>([\S]+)/>ti|'$ti'|ref|\1|/; print $_;' > ti_${fn%.*}
done

#--- Create fasta with all sequences
cd ..
cat Archive/ti_*.fna > ref_fungi_rep_genomes.fna

#--- Splits combined fasta file into smaller (less than 4G) files 
# (This may need to be altered if more than 2 files are created)
split -b 4G -d ref_fungi_rep_genomes.fna temp.

# finds the last species in the split up file.
sp=$(grep "^>" temp.00 | cut -d' ' -f2,3 | tail -n 1)
# finds the line number where the species seqs start in the file
sline=$(grep -n "$sp" ref_fungi_rep_genomes.fna | head -n 1 | sed 's/^\([0-9]\+\):.*$/\1/')
line=$(echo "$(($sline - 1))")

split -l $line -d ref_fungi_rep_genomes.fna ref_fungi_rep_genomes.
rm temp.?? #removes temporary files used to figure out which species is split between the two files

# add suffix to new files
for f in ref_fungi_rep_genomes.??; do 
    mv $f ${f}.fna
done

#--- Create .gitignore
echo -e '*\n!.gitignore' > .gitignore

#--- Build the index with bowtie2
for p in ref_fungi_rep_genomes.??.fna; do 
sbatch -N 1 -t 300 -p short,defq  <<EOF
#! /bin/bash
umask 0002
module load bowtie2/2.2.3
bowtie2-build $p ${p%.*}
EOF

done

