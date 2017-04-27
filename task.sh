#!/bin/bash
ifconfig $(ifconfig | fgrep encap:Ethernet | awk '{print $1}') down
set -ex

abort() {
  echo "NG (~_~);" >> ${OUTPUT}
  exit 1
}
trap "abort" ERR HUP INT KILL QUIT TERM

PWD=$(pwd)
CODE="code"
INDIR="input/${CODEID}" # @TODO chown user:root
ANSDIR="${PWD}/answer/${CODEID}"
TRACE="${ANSDIR}/tracefile"
OUTPUT="${PWD}/output/${CODEID}"
echo "### TESTS START BY ${LANG}." > $OUTPUT

cd $INDIR
case "${LANG}" in
  "c")
    mv $CODE main.c
    gcc main.c
    COMMAND="./a.out"
    ;;
  "cpp")
    mv $CODE main.cpp
    g++ main.cpp
    COMMAND="./a.out"
    ;;
  "go")
    mv $CODE main.go
    go build main.go
    COMMAND="./main"
    ;;
  "java")
    mv $CODE Main.java
    javac Main.java
    COMMAND="java Main"
    ;;
  *)
    COMMAND="${LANG} $CODE"
esac

for file in `ls -1 hole*`
do
  echo "$ ${COMMAND} < ${file}" >> $OUTPUT
  ans=$(cat "${ANSDIR}/${file}")
  chmod 0000 ${ANSDIR}/${file}
  #out=$(strace -f -e execve ${COMMAND} < $file 2>> ${TRACE}) # @TODO su user
  out=$(${COMMAND} < $file 2>> ${TRACE})

  if [ "$out" != "$ans" ]
  then
    echo "NG (~_~);" >> $OUTPUT
    exit 1
  fi
  echo "OK (^_^)v" >> $OUTPUT
done

## check for execve  @TODO restrict will be removed
process=$(fgrep execve $TRACE | fgrep pid | wc -l)
restrict=$(fgrep execve $TRACE | fgrep apk | wc -l)
if ([ "$LANG" != "bash" ] && [ $process -ne 0 ]) || [ $restrict -ne 0 ]
then
  echo "!!! DO NOT USE EXTERNAL COMMAND !!!" >> $OUTPUT
  exit 1
fi

echo "ALL TESTS PASSED!!!" >> $OUTPUT
exit 0
