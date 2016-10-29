#! /bin/bash

SN="bowtie2build_wrapper.sh"

#--- Set reference
[[ -z ${ref+x} ]] && echo "ref not set" && exit 1
[[ ! -e $ref ]] && echo "$ref not found" && exit 1

#-- Set out prefix (if not provided)
[[ -z ${out+x} ]] && out=${ref%.*}

#--- Memory polling
free -hs 300 &
freepid=$(echo $!)

#--- Start the timer
t1=$(date +"%s")

#--- Run build
module load bowtie2
bowtie2-build --threads $(nproc) ${ref} ${out}

#--- Kill memory polling
kill $freepid

#---Complete job
t2=$(date +"%s")
diff=$(($t2-$t1))
echo "[---bowtie-build---] ($(date)) $(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed."
exit 0
