#!/bin/bash

# Script to use the dlt_template subdirectory to create a new DLT plugin


try() {
    eval $*
    if [ $? -ne 0 ]; then
        echo >&2 
        echo '!!! '"ERROR: the $1 command did not complete successfully." >&2
        echo '!!! '"(\"$*\")" >&2
        echo '!!! '"Since this is a critical task, I'm stopping." >&2
        echo >&2
        exit 1
    fi
}
                                                                                

if [ -z "$1" ]; then
    echo "Error: Please provide a name for your plugin";
    exit 1;
fi

PLUGIN=$1

PLUGINDIR="dlt_${PLUGIN}"

if [ ! -d $PLUGINDIR ]; then 
    try mkdir $PLUGINDIR
fi


# Files to not change their name
for i in Makefile.am ; do
    if [ -f ${PLUGINDIR}/$i ]; then
        echo "Skipping ${PLUGINDIR}/$i"
        continue;
    fi
    try sed -E "s/%{plugin}/$PLUGIN/g" dlt_template/$i >${PLUGINDIR}/$i
done

# Files to have their name changed
for i in plugin.c plugin.h plugin_opts.def plugin_stub.def ; do
    OUTFILE=`echo $i | sed -E "s/plugin/${PLUGIN}/"`
    OUTFILE="${PLUGINDIR}/${OUTFILE}"
    if [ -f $OUTFILE ]; then
        echo "Skipping $OUTFILE"
        continue;
    fi

    try sed -E "s/%{plugin}/${PLUGIN}/g" dlt_template/$i >$OUTFILE
done

# tell the user what to do now
echo "Plugin template created in: $PLUGINDIR"
echo "Pleased be sure to modify ./Makefile.am and add the line to the END OF THE FILE:"
echo "include \$(srcdir)/${PLUGINDIR}/Makefile.am"
echo ""
echo "You will then need to re-run automake and ./configure to build your new plugin"
exit 0
