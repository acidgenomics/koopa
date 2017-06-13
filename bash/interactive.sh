# Default interactive queue
# bsub -Is -q interactive bash

# Improved version that times out after 12 hours
bsub -Is -W 12:00 -q interactive -n 1 bash
