currentdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
path_to_fastq=${currentdir}/*.gz
path_to_python=${currentdir}/make_manifest.py
echo $path_to_fastq | python $path_to_python