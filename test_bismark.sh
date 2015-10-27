top=$(readlink -f ../)/
tmp=$(readlink -f ../tmp)/
raw=$(readlink -f ../raw)/
rawt=$(readlink -f ../raw_trimmed)/
# bt2=$(readlink -f ../bowtie2)/


if [[ -e ${tmp}bismark.ids ]]; then
rm ${tmp}bismark.ids
fi


mkdir ../bismark
bsm=$(readlink -f ../bismark)

cd ${rawt}
# srun head -n 200 control2_1.fastq > test_1.fastq
# srun head -n 200 control2_2.fastq > test_2.fastq


# only run once per pair of files
for file in $(ls test*.fastq); do echo ${file::(-8)}
if [[ -e ${tmp}bismark_${file::(-8)}.sh ]]
then echo "file already exists"
else	
echo ${tmp}bismark_${file::(-8)}.sh
echo "#!/bin/bash
cd ${rawt}
module load Bowtie2
module load Bismark
bismark --bowtie2 -N 1 -o ${bsm} ${bsm} -1 ${rawt}${file::(-7)}1.fastq -2 ${rawt}${file::(-7)}2.fastq
rm ${tmp}bismark_${file::(-8)}.sh" > ${tmp}bismark_${file::(-8)}.sh

cd ${tmp}
chmod 755 ${tmp}bismark_${file::(-8)}.sh
rm ../slurm_logs/bismark_${file::(-8)}.*.out
sbatch -p blade,himem,hugemem --cpus-per-task=18 -o ../slurm_logs/bismark_${file::(-8)}.%j.out ${tmp}bismark_${file::(-8)}.sh 2>&1 | tee ${tmp}bismark_${file::(-8)}.id
id=$(cat ${tmp}bismark_${file::(-8)}.id | grep 'Submitted batch job')
echo -n :${id:20} >> ${tmp}bismark.ids
rm ${tmp}bismark_${file::(-8)}.id

fi
done

bismark_ids=$(cat ${tmp}bismark.ids)
srun -p blade,himem,hugemem -d afterok${bismark_ids} echo "bismark done"

cd ${rawt}
rm test*.fastq

