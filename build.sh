#!/usr/bin/env bash

set -e

nasm -g -f elf64 cat.asm 
ld cat.o -o cat
