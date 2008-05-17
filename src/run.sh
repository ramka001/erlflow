#!/bin/sh
/opt/local/bin/erlc erlflow.erl 
/opt/local/bin/erl -noshell -s erlflow start -s init stop 
