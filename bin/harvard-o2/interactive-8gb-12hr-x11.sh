#!/bin/sh

srun -p interactive --pty -c 1 --mem 8G --time 0-12:00 --x11=first /bin/bash
