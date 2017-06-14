# CBI Reference Databases

## Reference and representative genomes

[Recently](https://www.ncbi.nlm.nih.gov/news/10-11-2016-ncbi-minute-new-blast-dbs/)
NCBI released new BLAST databases containing NCBI-selected Reference and Representative
Genome nucleotide assemblies. This new database promises to provide cleaner results and
a smaller overall database than our current references.

[This is how NCBI selects representative genomes:](https://www.ncbi.nlm.nih.gov/genome/browse/refhelp/)

>Representative genomes are selected based on the following rules:
>
>+ the only genome sequenced
+ the only complete genome for species
+ multiple complete genomes or no complete genome
    + Type strain
    + First complete genome sequenced
    + Human Microbiome reference
    + Highest assembly quality


### Building the databases

`build_NCBI_rep_genomes.sh` is a script for automatically downloading and 
building the databases.

**Usage:**

```bash
. scripts/build_NCBI_rep_genomes.sh [build_id]
```

Where `build_id` is a build identifier. A new directory will be created within 
`NCBI_rep_genomes` with the build ID. For example, the identifier used for 
BLAST databases dated Oct. 27, 2016 was `20161027`.

### Available builds

| build date    | build ID    | latest |
| ------------- | ----------- | ------ |
| Oct. 27, 2016 | 20161027    | yes    |

## 16S Microbial

The 16S microbial databases contain Bacterial and Archaeal 16S rRNA sequences
from the [NCBI RefSeq targeted loci project](https://www.ncbi.nlm.nih.gov/refseq/targetedloci/) (BioProject [33175](https://www.ncbi.nlm.nih.gov/bioproject/33175)).

A brief description:

>The 16S ribosomal RNA targeted loci project is the result of an international collaboration between a number of ribosomal RNA databases and NCBI to provide a curated and comprehensive set of complete and near full length Reference Sequence records for phylogenetic and evolutionary analyses. Sequences that represent the consensus of all contributing databases in both sequence content and taxonomic assignment are promoted to RefSeqs. All sequences will have the same project ID and can be found as such.

### Building the databases

`build_NCBI_16SMicrobial.sh` is a script for automatically downloading and 
building the databases.

**Usage:**

```bash
. scripts/build_NCBI_16SMicrobial.sh [build_id]
```

Where `build_id` is a build identifier. A new directory will be created within 
`NCBI_16SMicrobial` with the build ID.

### Available builds

| build date    | build ID    | latest |
| ------------- | ----------- | ------ |
| Aug. 6, 2016  | 20160806    | yes    |


## plasmaDB

The plasma database contains reference sequences for organisms that may appear in human plasma.

**Usage:**

```bash
. scripts/build_plasmaDB.sh [build_id]
```

Where `build_id` is a build identifier. Before building, the build directory should contain files with information about the sequences to be included in the database. These can be:

1. **Accessions:** Each file contains a list of accession numbers, one per line. The filename for these files should begin with `acc.*`. The name of the resulting database will be the file name with the beginning and extension removed. For example, if provided the file `acc.human_viruses.txt`, the build script will create a database named `human_viruses`.
2. **Sequences:** Each file is a multi-fasta files from the same taxonomic group. The filename should have the extension `*.fasta` and should begin with the taxonomy ID to be added to the sequence names. For example, if provided the file `11103.HCV_references.fasta`, the build script will add the taxon ID `11103` to all sequences and create a database named `HCV_references`.

| build date     | build ID    | latest | comment |
| -------------- | ----------- | ------ | ------- |
| Aug. 6, 2016   | 20160806    | no     |
| Jan. 17, 2017  | 20170117    | yes    | separate DB for HCV, HIV, and human viruses |


## kraken

This database is the standard kraken database (built by `kraken-build`).

Here is how to submit a job to create the database:

```bash
sbatch -N 1 -p short,gpu -t 720 <<EOF
#! /bin/bash
umask 0002
module load kraken/dev
cd /groups/cbi/shared/References/cbi_reference_databases.git/kraken
kraken-build --standard --threads 16 --db [build_id]

EOF

```

| build date     | build ID    | latest | comment |
| -------------- | ----------- | ------ | ------- |
| Jun. 14, 2017   | 20170614    | yes     | |


## centrifuge

This database is for centrifuge and was downloaded from [CCB](https://ccb.jhu.edu/software/centrifuge/manual.shtml)

```bash
mkdir -p [build_id] && cd [build_id]
wget ftp://ftp.ccb.jhu.edu/pub/infphilo/centrifuge/data/p_compressed.tar.gz
wget ftp://ftp.ccb.jhu.edu/pub/infphilo/centrifuge/data/p_compressed+h+v.tar.gz
wget ftp://ftp.ccb.jhu.edu/pub/infphilo/centrifuge/data/p+h+v.tar.gz
wget ftp://ftp.ccb.jhu.edu/pub/infphilo/centrifuge/data/nt.tar.gz

tar xzf p_compressed.tar.gz
tar xzf p_compressed+h+v.tar.gz
tar xzf p+h+v.tar.gz
tar xzf nt.tar.gz
```

| build date     | build ID    | latest | comment |
| -------------- | ----------- | ------ | ------- |
| Dec. 6, 2016   | 20161206   | yes     | |



There are 4 databases included with the Dec. 6, 2016 build:

| Contents     | Name    | Size |
| -------------- | ----------- | ------ |
| Bacteria, Archaea (compressed) |  p_compressed | 4.4 GB |
| Bacteria, Archaea, Viruses, Human (compressed) | p_compressed+h+v | 5.4 GB |
| Bacteria, Archaea, Viruses, Human	| p+h+v | 7.9 GB |
|  NCBI nucleotide non-redundant sequences | nt | 50GB |
