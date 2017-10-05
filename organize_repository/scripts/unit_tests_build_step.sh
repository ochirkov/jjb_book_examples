#!/bin/bash


if [ $ACTION == "py27" ]; then
    tox -e py27
elif [ $ACTION == "py35" ]; then
    tox -e py35
fi