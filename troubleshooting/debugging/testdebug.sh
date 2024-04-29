#!/bin/sh

if nc -z -w 3 termbin.com 9299; then
    echo "termbin OK"
else
    echo "termbin NOK"
fi

if nc -z -w 3 foobar.com 9999; then
    echo "foobar OK"
else
    echo "foobar NOK"
fi
