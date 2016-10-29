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
