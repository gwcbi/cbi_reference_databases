# CBI Reference Databases

[Recently](https://www.ncbi.nlm.nih.gov/news/10-11-2016-ncbi-minute-new-blast-dbs/)
NCBI released new BLAST databases containing NCBI-selected Reference and Representative
Genome nucleotide assemblies. This new database promises to provide cleaner results and
a smaller overall database than our current references.

[This is how NCBI selects representative genomes:](https://www.ncbi.nlm.nih.gov/genome/browse/refhelp/):

>Representative genomes are selected based on the following rules:
>
>+ the only genome sequenced
+ the only complete genome for species
+ multiple complete genomes or no complete genome
    + Type strain
    + First complete genome sequenced
    + Human Microbiome reference
    + Highest assembly quality


## Building the databases

`build_NCBI_rep_genomes.sh` is a script for automatically downloading and 
building the databases.

**Usage:**

```bash
. scripts/build_NCBI_rep_genomes.sh [build_id]
```

Where `build_id` is a build identifier. A new directory will be created within 
`NCBI_rep_genomes` with the build ID. For example, the identifier used for 
BLAST databases dated Oct. 27, 2016 was `20161027`.


