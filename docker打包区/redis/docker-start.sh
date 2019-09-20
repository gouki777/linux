#!/bin/bash
ARGS=""
if [[ ! -z $MAXMEMORY ]]
then
    ARGS=$ARGS" --maxmemory "$MAXMEMORY
fi
if [[ ! -z $MAXMEMORY_POLICY ]]
then 
     ARGS=$ARGS" --maxmemory-policy "$MAXMEMORY_POLICY
fi
if [[ ! -z $APPENDONLY ]]
then 
   ARGS=$ARGS" --appendonly "$APPENDONLY
fi 
if [[ ! -z $REQUIREPASS ]]
then
     ARGS=$ARGS" --requirepass $REQUIREPASS"
fi
if [[ ! -z $PROTECTED_MODE ]]
then
     ARGS=$ARGS" --protected-mode $PROTECTED_MODE"
fi
if [[ ! -z $SAVE ]]
then
     ARGS=$ARGS" --save $SAVE"
fi
echo $ARGS
exec redis-server $ARGS
