#!/usr/bin/bash

set -e
#set -x

print_usage() {
  usage="""
  $(basename $0)
  -------------------------------------
  This script splits an audiobook file into chapters.

  Usage:
  $(basename $0) -i <input file> -o <output directory> -c <chapter keyword> [-w] [-v] [-a ARGS] [-h]
  ex.
  $(basename $0) -i audiobook.mp3 -o chapters -c chapter -w -a \"--model medium --language Swedish\"

  Options:
    -i: Path to the input file
    -o: Path to the output directory
    -c: Keyword that is used to identify breakpoints between chapters (case-insensitive)
    -w: Use this flag to use OpenAI's Whisper for transcription
    -v: Use this flag to use Vosk for transcription
    -a: Pass any additional arguments to transcriber using this flag
    -h: Print this help message
"""
  printf "$usage"

}

# check arguments
while getopts 'i:o:c:wva::h' flag; do
  case "${flag}" in
    i) input_file="${OPTARG}" ;;
    o) output_dir="${OPTARG}" ;;
    c) chapter_keyword="${OPTARG}" ;;
    w) whisper=true ;;
    v) vosk=true ;;
    a) args="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done              

# check if input file exists
if [ ! -f "$input_file" ]; then
  echo "Input file does not exist"
  exit 1
fi

# check if output directory is set
if [ -z "$output_dir" ]; then
  echo "Output directory is required"
  exit 1
fi

# check if chapter keyword is set
if [ -z "$chapter_keyword" ]; then
  echo "Chapter keyword is required"
  exit 1
fi

# create output directory if it does not exist
if [ ! -d "$output_dir" ]; then
  mkdir -p "$output_dir"
fi

# save input file name prefix
input_file_prefix=$(basename "$input_file" | cut -d. -f1)







#  _____ ____      _    _   _ ____   ____ ____  ___ ____  _____
# |_   _|  _ \    / \  | \ | / ___| / ___|  _ \|_ _| __ )| ____|
#   | | | |_) |  / _ \ |  \| \___ \| |   | |_) || ||  _ \|  _|
#   | | |  _ <  / ___ \| |\  |___) | |___|  _ < | || |_) | |___
#   |_| |_| \_\/_/   \_\_| \_|____/ \____|_| \_\___|____/|_____|
#
# TRANSCRIBE

# create work directory
work_dir=$(mktemp -d)

# figure out which transcription tool to use

# check if whisper flag is set
if [ "$whisper" = true ]; then
    transcribe_tool="whisper"
elif [ "$vosk" = true ]; then
    transcribe_tool="vosk"
else
    # check if whisper is installed
    if command -v whisper &> /dev/null; then
        transcribe_tool="whisper"
    # check if vosk is installed
    elif command -v vosk-transcriber &> /dev/null; then
        transcribe_tool="vosk"
    else
        echo "No transcription tool found. Please install either Whisper or Vosk"
        exit 1
    fi
fi

# run the transcription tool
if [ "$transcribe_tool" = "whisper" ]; then
    whisper "$input_file" --output_dir "$work_dir" --output_format srt $args
else
    ffmpeg -i "$input_file" -ar 16000 -ac 1 "$work_dir/$input_file_prefix.wav"
    vosk-transcriber -i "$work_dir/$input_file_prefix.wav" -t srt -o "$work_dir/$input_file_prefix.srt" $args
fi






#  _____ ___ _   _ ____     ____ _   _    _    ____ _____ _____ ____  
# |  ___|_ _| \ | |  _ \   / ___| | | |  / \  |  _ \_   _| ____|  _ \ 
# | |_   | ||  \| | | | | | |   | |_| | / _ \ | |_) || | |  _| | |_) |
# |  _|  | || |\  | |_| | | |___|  _  |/ ___ \|  __/ | | | |___|  _ < 
# |_|   |___|_| \_|____/   \____|_| |_/_/   \_\_|    |_| |_____|_| \_\
#                                                                     
# FIND CHAPTER

# find the chapter breakpoints
grep -i "$chapter_keyword" "$work_dir/$input_file_prefix.srt" -B1 | grep -v "^--$" | awk 'BEGIN{OFS=" "}{if (NR % 2 == 0) {print prev_line, $0} else {prev_line = $0}}' > "$work_dir/chapters.tmp"

# create a file with the chapter breakpoints
touch "$work_dir/chapters.txt"
prev_start_time="00:00:00"
prev_chapter_title="Intro"
while read -r line; do
    # get the new chapter start time and title
    start_time=$(echo "$line" | cut -d' ' -f1 | cut -d',' -f1)

    # write the previous chapter to the file
    echo "        -ss $prev_start_time}-to $start_time}$prev_chapter_title" >> "$work_dir/chapters.txt" # no idea why, but without the extra space, the read -r line part below sometimes loses the -ss part

    # update the previous chapter
    prev_start_time=$start_time
    prev_chapter_title=$(echo "$line" | cut -d' ' -f4-)

done < "$work_dir/chapters.tmp"

# add the last chapter
echo "        -ss $prev_start_time}}$prev_chapter_title" >> "$work_dir/chapters.txt"






#  ____  ____  _     ___ _____   _____ ___ _     _____
# / ___||  _ \| |   |_ _|_   _| |  ___|_ _| |   | ____|
# \___ \| |_) | |    | |  | |   | |_   | || |   |  _|
#  ___) |  __/| |___ | |  | |   |  _|  | || |___| |___
# |____/|_|   |_____|___| |_|   |_|   |___|_____|_____|
#
# SPLIT FILE

# save input file extension
input_file_extension=$(basename "$input_file" | rev | cut -d. -f1 | rev)
echo "$work_dir/chapters.txt"
# split the audio file into chapters
while read -r line; do
    start_time=$(echo "$line" | cut -d'}' -f1)
    end_time=$(echo "$line" | cut -d'}' -f2)
    chapter_title=$(echo "$line" | cut -d'}' -f3)

    ffmpeg -y -i "$input_file" $start_time $end_time -c copy "$output_dir/$input_file_prefix - $chapter_title.$input_file_extension"

done < "$work_dir/chapters.txt"

# remove work directory
rm -rf "$work_dir"

echo """
Done! Chapters have been saved to $output_dir
"""
