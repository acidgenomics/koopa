if [ -d STAR ]; then
  rm -rf STAR
fi
mkdir STAR
cd STAR
STAR --runMode=genomeGenerate --genomeDir=. --genomeFastaFiles=../dna.fa --sjdbGTFfile=../gtf
