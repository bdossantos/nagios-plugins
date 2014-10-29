#!/usr/bin/env bash
#
# Return last logged in user
#
# (c) 2014, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#

last -i | tac | tail -n 1
exit 0
