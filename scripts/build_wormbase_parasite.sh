#! /bin/bash

[[ -n ${1+x} ]] && build=$1
[[ -z ${build+x} ]] && build=$(date +"%Y%m%d")

#--- Download all the genomes from FTP
umask 0002
mkdir -p wormbase_parasite/${build}/Archive && cd wormbase_parasite/${build}/Archive

# First parse the directory listing to get available species
# OLD VERSION: curl -s ftp://ftp.ebi.ac.uk/pub/databases/wormbase/parasite/releases/WBPS9/species/ | tr -s ' ' | cut -f9 -d' ' > SPECIES_EX.txt

curl -s ftp://ftp.ebi.ac.uk/pub/databases/wormbase/parasite/releases/WBPS12/species/ | tr -s ' ' | cut -f9 -d' ' > SPECIES_EX.txt

# Now download the representative genome DNA file for each
cat SPECIES_EX.txt | while read sp; do
    echo $sp
    rsync --partial --progress --copy-links -iav ftp.ebi.ac.uk::pub/databases/wormbase/parasite/releases/WBPS12/species/${sp}/*/*.genomic.fa.gz .
done

ls *.gz | cut -d'.' -f1 | sort | uniq > SPECIES.txt

###### IN R ##############################################################################

module load R/current

# you may have to do this if those packages are not istalled:
#R
#61
#install.packages("taxize")
#install.packages("magrittr")
#install.packages("dplyr")
#quit()
#n

R --slave <<EOF
library("taxize")
library("magrittr")
library("dplyr")

worms = read.table("SPECIES.txt")
colnames(worms) <- "species"

uid_table <- tbl_df(worms)%>%
  rowwise() %>%
  mutate(tid = get_uid(species)) %>%
  select(species, tid)
  
write.table(uid_table, file = "worms_tids.txt", quote=FALSE, sep="\t", col.names = F, row.names = F)
EOF

##########################################################################################

#--- Update the sequence IDs with taxonomy ID
for p in *.genomic.fa.gz; do
    fn=$(basename $p)
    bd=$(echo $fn | cut -d"." -f2)
    sp=$(echo $fn | cut -d"." -f1)
    sn=$(echo $sp | sed -r 's/(\w)+_(\w+)/\1_\2/g')
    ti=$(grep "$sp" worms_tids.txt | cut -f2)
    gunzip -c $p | perl -lne 's/^>([\S]+)/>ti|'$ti'|ref|'${sn}.${bd}.'\1| '$sp' bioProject='$bd'/; print $_;' > ti_${fn%.*}
    echo -e "$sp\t$sn\t$bd\t$ti" >> mapping.txt
    echo "Completed: "$p
done

#--- Create a list of all the ti files
ls ti*.fa > all_ti_files.txt

#--- Create fasta with all sequences

cd ..
cat Archive/ti_*.fa > wormbase_parasite_genomes.fna

# splitting the species file because combining all the sequences creates too big of file
split -d -b 4G wormbase_parasite_genomes.fna tmp_wormbase_parasite_genomes_


# making sure a species is not split between files
start_line=0
for f in tmp_wormbase_parasite_genomes_??; do 
   sp=$(grep "^>" $f | tail -n 1 | cut -d' ' -f2)
   bd=$(grep "^>" $f | tail -n 1 | cut -d' ' -f3 | cut -d'=' -f2)
   fn=$sp.$bd
   line=$(grep -n "$fn" Archive/all_ti_files.txt | cut -d':' -f1)
   new_line=$(($line - 1))
   line_len=$(($new_line - $start_line))
   #echo "$f	sp: $sp	bd: $bd	fn: $fn	line: $line	new_line: $new_line start_line: $start_line len: $line_len"
   tail -n +$start_line Archive/all_ti_files.txt | head -n $line_len > Archive/ti_files_${f##*_}.txt
   start_line=$line
   echo "Created ti_files_${f##*_}.txt"
done

for f in Archive/ti_files_*.txt; do
    cat $f | while read sp; do
        num=${f##*_}
        cat Archive/$sp >> wormbase_parasite_genomes_${num%.txt}.fna
    done
    echo "Finished pulling ${f}'s fasta into wormbase_parasite_genomes_${num%.txt}.fna"
done

# removes redundant files
rm tmp_wormbase_parasite_genomes_??
rm wormbase_parasite_genomes.fna


#--- Create .gitignore
echo -e '*\n!.gitignore' > .gitignore

#--- Build the index with bowtie2
for f in wormbase_parasite_genomes_*.fna; do
sbatch -N 1 -t 300 -p short,defq  <<EOF
#! /bin/bash
umask 0002
module load bowtie2/2.2.3
bowtie2-build $f ${f%.fna}
EOF

done

