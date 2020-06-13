#!/bin/bash

source /environment.sh

# initialize launch file
dt-launchfile-init

# YOUR CODE BELOW THIS LINE
# ----------------------------------------------------------------------------



# ----------------------------------------------------------------------------
# YOUR CODE ABOVE THIS LINE

# run base entrypoint
dt-exec /entrypoint.sh

# terminate launch file
dt-launchfile-join