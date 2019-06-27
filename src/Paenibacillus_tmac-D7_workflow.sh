#!/bin/bash

#Written RAWIII
#June 24th, 2019

#remove adapters/trim
bbduk.sh -Xmx1g in1=Paenibacillus_tmac-D7_raw_R1.fastq.gz in2=Paenibacillus_tmac-D7_raw_R2.fastq.gz out1=Paenibacillus_tmac-D7_trim_R1.fastq.gz out2=Paenibacillus_tmac-D7_trim_R2.fastq.gz ref=~/bbmap/resources/adapters.fa ktrim=r k=21 mink=11 hdist=2 tpe tbo 

#decon phix and trim further
bbduk.sh -Xmx1g in1=Paenibacillus_tmac-D7_trim_R1.fastq.gz in2=Paenibacillus_tmac-D7_trim_R2.fastq.gz out1=Paenibacillus_tmac-D7_trim-decon_R1.fastq.gz out2=Paenibacillus_tmac-D7_trim-decon_R2.fastq.gz qtrim=r trimq=25 maq=25 minlen=50 ref=~/bbmap/resources/phix174_ill.ref.fa.gz k=31 hdist=1 stats=F1_all_trim-decon-stats.txt

#load modules for unicycler
module load python3/3.5.0
module load bowtie2/2.3.4
module load blast/2.7.1
module load samtools/1.6

#run unicycler assembly and pilon polishing
/home/richard.white3/Unicycler/unicycler-runner.py -1 Paenibacillus_tmac-D7_trim-decon_R1.fastq.gz -2 Paenibacillus_tmac-D7_trim-decon_R2.fastq.gz -o Paenibacillus_tmac-D7_dir --pilon_path /pilon-1.22.jar

#subsample >200 bp for GenBank submission
reformat.sh in=Paenibacillus_tmac-D7_raw-assem.fasta out=Paenibacillus_tmac-D7_wo200bp.fasta minlength=1000 aqhist=Paenibacillus_tmac-D7_hist_200bp.txt

#subsample 1k contigs
reformat.sh in=Paenibacillus_tmac-D7_raw-assem.fasta out=Paenibacillus_tmac-D7_1k.fasta minlength=1000 aqhist=Paenibacillus_tmac-D7_hist_1k.txt

#Prokka annotation (all raw contigs, all contigs >200 bp for Genbank, and 1k contigs)
prokka Paenibacillus_tmac-D7_raw-assem.fasta --cpu 28 --outdir Paenibacillus_tmac-D7_raw --prefix Paenibacillus_tmac-D7_raw --rfam
prokka Paenibacillus_tmac-D7_wo200bp.fasta --cpu 28 --outdir Paenibacillus_tmac-D7_200bp --prefix Paenibacillus_tmac-D7_200bp --rfam
prokka Paenibacillus_tmac-D7_1k.fasta --cpu 28 --outdir Paenibacillus_tmac-D7_1k --prefix Paenibacillus_tmac-D7_1k --rfam
