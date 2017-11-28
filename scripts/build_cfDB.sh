#! /bin/bash

[[ -n ${1+x} ]] && build=$1
[[ -z ${build+x} ]] && build=$(date +"%Y%m%d")

# Load modules
module load bowtie2

# Get the repository root directory
rroot=$(git rev-parse --show-toplevel)

# Function for checking bowtie2 indexes
checkindex () {
    local prefix=$1
    [[ ! -e ${prefix}.1.bt2 ]] && return 1
    [[ ! -e ${prefix}.2.bt2 ]] && return 1
    [[ ! -e ${prefix}.3.bt2 ]] && return 1
    [[ ! -e ${prefix}.4.bt2 ]] && return 1
    [[ ! -e ${prefix}.rev.1.bt2 ]] && return 1
    [[ ! -e ${prefix}.rev.2.bt2 ]] && return 1
    bowtie2-inspect -n $prefix &> /dev/null
    [[ $? -ne 0 ]] && return 1
    return 0
}

#--- Set the build directory
#--- Create and move to build directory
builddir=$rroot/cfDB/$build
mkdir -p $builddir && cd $builddir
mkdir -p Archive

#--- Move the file into the new directory
mv ../Burkholderia_Pseudomonas_genomes_ti.fna .

#--- Create the bowtie2 database
echo "Building the bowtie2 databases"
for f in *.fna; do
    bowtie2-build $f $(basename ${f%.*})
done

echo -e '*\n!.gitignore' > .gitignore
