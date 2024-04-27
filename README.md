# audiobook-chapter-splitter

A tool to split monolithic audiobook files (`mp3` or any format that FFmpeg and Whisper/Vosk can understand) into one file per chapter. Based on speech recognition (whisper or vosk) and finding a user defined keyword to separate chapters. Inspired by Dan Gravell's blog post [Splitting audiobooks into chapters with AI and crossed fingers](https://www.blisshq.com/music-library-management-blog/2021/01/22/splitting-audiobooks-chapters-ai/).

The steps can be summarized as follows:
1. Transcribe the audiobook file to a `srt` file using Whisper or Vosk.
1. Use `grep` to find the keyword that separates chapters and the timestamps they occur at in the `srt` file.
1. Use `ffmpeg` to split the audiobook file into one file per chapter based on the timestamps.

My own use case is to split audiobooks into chapters, but it will work for any type of audio file that has a keyword that separates sections.

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
  audiobook-chapter-splitter.sh -i audiobook.mp3 -o chapters -c kapitel -w -a "--model medium --language Swedish"

  Options:
    -i: Path to the input file
    -o: Path to the output directory
    -c: Keyword that is used to identify breakpoints between chapters (case-insensitive)
    -w: Use this flag to use OpenAIs Whisper for transcription
    -v: Use this flag to use Vosk for transcription
    -a: Pass any additional arguments to transcriber using this flag
    -h: Print this help message
```










