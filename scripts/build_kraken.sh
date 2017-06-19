#! /bin/bash

[[ -n ${1+x} ]] && build=$1
[[ -z ${build+x} ]] && build=$(date +"%Y%m%d")

# Get the repository root directory
rroot=$(git rev-parse --show-toplevel)

#--- Create and move to build directory
builddir=$rroot/kraken/$build
mkdir -p $builddir && cd $builddir

#--- Build the bacteria database (p)
xt=$(sbatch -N 1 -t 600 -p short,128gb,gpu <<EOF
#! /bin/bash
umask 0002
cd $builddir
module load kraken/dwood
kraken-build --download-taxonomy --db p
kraken-build --download-library bacteria --db p
kraken-build --build  --threads \$(nproc) --db p

EOF
)
j1=$(sed 's/Submitted batch job //' <<<$xt)


#--- Build the virus database (v)
xt=$(sbatch -N 1 -t 600 -p short,128gb,gpu <<EOF
#! /bin/bash
umask 0002
cd $builddir
module load kraken/dwood
kraken-build --download-taxonomy --db v
kraken-build --download-library viruses --db v
kraken-build --build  --threads \$(nproc) --db v

EOF
)
j2=$(sed 's/Submitted batch job //' <<<$xt)


#--- Build the human database (h)
xt=$(sbatch -N 1 -t 600 -p short,128gb,gpu <<EOF
#! /bin/bash
umask 0002
cd $builddir
module load kraken/dwood
kraken-build --download-taxonomy --db h
kraken-build --download-library human --db h
kraken-build --build  --threads \$(nproc) --db h

EOF
)
j3=$(sed 's/Submitted batch job //' <<<$xt)


#--- Build the bacteria+virus database (p+v)
xt=$(sbatch -N 1 -t 600 -p short,128gb,gpu --dependency=afterany:$j1:$j2:$j3 <<EOF
#! /bin/bash
umask 0002
cd $builddir
module load kraken/dwood
kraken-build --download-taxonomy --db p+v
mkdir -p p+v/library
mv v/library/Viruses p+v/library
mv p/library/Bacteria p+v/library
kraken-build --build  --threads \$(nproc) --db p+v

EOF
)
j4=$(sed 's/Submitted batch job //' <<<$xt)

#--- Build the bacteria+virus+human database (p+v+h)
sbatch -N 1 -t 600 -p short,128gb,gpu --dependency=afterany:$j4 <<EOF
#! /bin/bash
umask 0002
cd $builddir
module load kraken/dwood
kraken-build --download-taxonomy --db p+v+h
mkdir -p p+v+h/library
mv p+v/library/Viruses p+v+h/library
mv p+v/library/Bacteria p+v+h/library
mv h/library/Human p+v+h/library
kraken-build --build  --threads \$(nproc) --db p+v+h

kraken-build --clean --db p
kraken-build --clean --db v
kraken-build --clean --db h
kraken-build --clean --db p+v
kraken-build --clean --db p+v+h

EOF

cd $rroot
