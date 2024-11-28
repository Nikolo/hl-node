#!/bin/bash

nginx &

$HOME/hl-visor run-non-validator --serve-eth-rpc &
#$HOME/hl-visor run-non-validator &

wait -n

echo "Exited $?"

exit $?
