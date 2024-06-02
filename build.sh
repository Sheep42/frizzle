#!/bin/bash

pdc source/ builds/frizzle
cd builds
zip -r ./frizzle.pdx.zip ./frizzle.pdx/
