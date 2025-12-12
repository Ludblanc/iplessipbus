#!/usr/bin/env python3.11

# Copyright (c) 2025 Ludovic Damien Blanc
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Author : Ludovic Damien Blanc
# Copyright 2025 EPFL

"""
basic_test.py
-------------
Write/read lines of "Romeo and Juliet" to an IPbus-mapped memory block.

This script:
  • Downloads the text from Project Gutenberg
  • Splits it into lines
  • Pads each line to a multiple of 4 bytes
  • Packs bytes into 32-bit words (little-endian)
  • Writes the line to an IPbus memory node
  • Reads it back and prints the raw result
"""

import uhal
import argparse
import urllib.request


def pad_to_32bits(byte_line):
    """
    Pad a bytes object to a multiple of 4 bytes (32 bits).
    Required because IPbus writeBlock uses 32-bit words.
    """
    remainder = len(byte_line) % 4
    if remainder != 0:
        byte_line += bytes(4 - remainder)
    return byte_line


def pack_bytes_to_words(byte_line):
    """
    Convert a byte array into a list of 32-bit words (little-endian).

    Example:
        b0, b1, b2, b3  →  b3<<24 | b2<<16 | b1<<8 | b0
    """
    words = []
    for i in range(0, len(byte_line), 4):
        w = (
            byte_line[i + 3] << 24
            | byte_line[i + 2] << 16
            | byte_line[i + 1] << 8
            | byte_line[i]
        )
        words.append(w)
    return words


def main():
    # -----------------------------
    # Parse command-line arguments
    # -----------------------------
    parser = argparse.ArgumentParser(description="Write/read test for IPbus memory")
    parser.add_argument("--ip", default="192.168.0.3",
                        help="IP address of the board")
    parser.add_argument("--xml", default="address_tables/ipbus_example.xml",
                        help="Address table XML file")
    parser.add_argument("--nb_times", type=int, default=1,
                        help="Number of write/read repetitions per line")
    args = parser.parse_args()

    # -----------------------------
    # Connect to the device
    # -----------------------------
    hw = uhal.getDevice(
        "board",
        f"ipbusudp-2.0://{args.ip}:50001",
        f"file://{args.xml}"
    )

    mem = hw.getNode("ram")

    # -----------------------------
    # Download "Romeo and Juliet"
    # -----------------------------
    url = "https://www.gutenberg.org/files/1513/1513-0.txt"
    print(f"Downloading text from: {url}")

    response = urllib.request.urlopen(url)
    text_lines = response.read().splitlines()   # list of byte strings

    print(f"Downloaded {len(text_lines)} lines.\n")

    # -----------------------------
    # Write + read each line
    # -----------------------------
    for line in text_lines:

        # Convert to bytes (line may already be bytes from splitlines)
        line = bytes(line)

        # Pad and pack into 32-bit words
        padded = pad_to_32bits(line)
        words = pack_bytes_to_words(padded)

        # Write to memory
        mem.writeBlock(words)
        hw.dispatch()

        # Read it back
        readback = mem.readBlock(len(words))
        hw.dispatch()

        # Convert readback 32-bit words back to bytes
        read_bytes = bytes(readback)

        # Print raw output (may contain padding zeros)
        print(read_bytes.rstrip(b"\x00"))


if __name__ == "__main__":
    main()
