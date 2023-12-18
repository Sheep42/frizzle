#!/bin/bash

pdc source/ builds/tamagochi-game
cd builds
zip -r ./tamagochi-game.pdx.zip ./tamagochi-game.pdx/