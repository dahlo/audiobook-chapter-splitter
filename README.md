# audiobook-chapter-splitter

A tool to split monolithic audiobook files into one file per chapter. Based on speech recognition (whisper or vosk) and finding a user defined keyword to separate chapter.  

## Prerequisites

You need either [Whisper](https://github.com/openai/whisper) or [Vosk](https://alphacephei.com/vosk/) installed on your system. If both are installed, Whisper will be used by default if nothing else is specified using the command-line arguments.

```bash
pip3 install vosk
# or
pip3 install openai-whisper
```

You also need to have [FFmpeg](https://ffmpeg.org/) installed on your system.

```bash
# debian-based
sudo apt install ffmpeg
```

## Installation

```bash
# clone the repository
git clone https://github.com/dahlo/audiobook-chapter-splitter.git
```

## Usage

```bash
  audiobook-chapter-splitter.sh
  -------------------------------------
  This script splits an audiobook file into chapters.

  Usage:
  audiobook-chapter-splitter.sh -i <input file> -o <output directory> -c <chapter keyword> [-w] [-v] [-a ARGS] [-h]
  ex.
  audiobook-chapter-splitter.sh -i audiobook.mp3 -o chapters -c chapter -w -a "--model medium --language Swedish"

  Options:
    -i: Path to the input file
    -o: Path to the output directory
    -c: Keyword that is used to identify breakpoints between chapters (case-insensitive)
    -w: Use this flag to use OpenAI's Whisper for transcription
    -v: Use this flag to use Vosk for transcription
    -a: Pass any additional arguments to transcriber using this flag
    -h: Print this help message
```










