#!/bin/bash

# This script will list running MUMPS processes. If they are attached to the current user, you should stop them before running the backup or restore scripts.

ps -aux | grep '[m]umps'
