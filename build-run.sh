#!/bin/bash

pdc source/ builds/frizzle
cd builds
pdsim frizzle.pdx
