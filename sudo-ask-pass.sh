#!/bin/sh

#echo $($HOME/scripts/guipin.sh) || exit 1
echo $(guipin.sh -T 60 -p "Password" -d "Superpowers required..." -t "Sudo Prompt" -o "Yep" -c "Njet" -3 "WHAT" -e "Gib Passwort") || exit 1
exit 0
