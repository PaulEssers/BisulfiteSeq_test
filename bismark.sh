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

# only run once per pair of files
for file in $(ls *.fastq); do echo ${file::(-11)}
if [[ -e ${tmp}bismark_${file::(-11)}.sh ]]
then echo "file already exists"
else	
echo ${tmp}bismark_${file::(-11)}.sh
echo "#!/bin/bash
cd ${rawt}
module load Bowtie2
module load Bismark
bismark --bowtie2 -o ${bsm} ${bsm} -1 ${rawt}${file::(-10)}1.fa.fastq -2 ${rawt}${file::(-10)}2.fa.fastq
rm ${tmp}bismark_${file::(-11)}.sh" > ${tmp}bismark_${file::(-11)}.sh

cd ${tmp}
chmod 755 ${tmp}bismark_${file::(-11)}.sh
rm ../slurm_logs/bismark_${file::(-11)}.*.out
sbatch -p blade,himem,hugemem --cpus-per-task=18 -o ../slurm_logs/bismark_${file::(-11)}.%j.out ${tmp}bismark_${file::(-11)}.sh 2>&1 | tee ${tmp}bismark_${file::(-11)}.id
id=$(cat ${tmp}bismark_${file::(-11)}.id | grep 'Submitted batch job')
echo -n :${id:20} >> ${tmp}bismark.ids
rm ${tmp}bismark_${file::(-11)}.id

fi
done

bismark_ids=$(cat ${tmp}bismark.ids)
srun -p blade,himem,hugemem -d afterok${bismark_ids} echo "bismark done"
