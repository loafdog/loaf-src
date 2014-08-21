#!/bin/bash

VERBOSE=0
TIME=

msg()
{
    if [ "$VERBOSE" -ne 0 ] ; then
        echo "$*"
    fi
}

#default location to start searching for files.
BASE_DIR=$PWD

PRUNE_FILES='
        -name *~ -prune -o
        -name .git* -prune -o
        -name *.o -prune -o
        -name *.gif -prune -o
        -name *.jpg -prune -o
        -name *.png -prune -o
        -name *.jar -prune -o
        -name *.css -prune -o
        -name *.tgz -prune -o
        -name *.gz -prune -o
        -name *.tar.gz -prune -o
        -name *.pyc -prune -o
        -name *.d -prune'

INCLUDE_FILES='
        -name *.[cshSylxi] -o
        -name *.cc -o
        -name Makefile* -o
        -name GNUmakefile* -o
        -name config.* -o
        -name files.* -o
        -name *.js -o
        -name *.asp -o
        -name *.java -o
        -name *.cpp -o
        -name *.conf -o
        -name *_feature_def -o
        -name *.xml -o
        -name *.xsd -o
        -name *.dict -o
        -name *.sh -o
        -name *.pl -o
        -name *.py -o
        -name *.ft -o
        -name *.ks -o
        -name *.exp -o
        -name *.post -o
        -name *.txt'


# add all files that match find filter starting at BASE_DIR.

find_all_cscope_files()
{
    echo "Creating full index of files."
    set -f
    find $BASE_DIR -type f $PRUNE_FILES -o \
        \( \
        $INCLUDE_FILES \
        \) \
        -exec echo {} \; >> $FIND_FILES

        if [ "$?" -ne 0 ] ; then
            exit 1
        fi
        set +f
        FILE_CNT=`sed -n '$=' $FIND_FILES`
        echo "find cscope files: $FILE_CNT"
}

list_all_files()
{
    echo "Creating list of all files."
    set -f
    find $BASE_DIR -type f $PRUNE_FILES -o -print >> $ALL_FILES
    set +f
    FILE_CNT=`sed -n '$=' $ALL_FILES`
    echo "all files: $FILE_CNT"
}

add_missing_files()
{
    diff -u0 $ALL_FILES $FIND_FILES | grep "^-" | cut -c 2- | tr -d '"' | grep -v "^-" > $MISSED_FILES

    ignored_file_cnt=$(sed -n '$=' $MISSED_FILES)
    echo "diff all/cscope files: $ignored_file_cnt"

    FILES=$(cat $MISSED_FILES)
    for file in $FILES; do
        file "$file" >> $MISSED_FILES_TYPES
    done

    grep ASCII $MISSED_FILES_TYPES > $SUGGESTED_FILES.tmp
    ascii_file_cnt=$(sed -n '$=' $SUGGESTED_FILES.tmp)
    echo "ascii files: $ascii_file_cnt"

    grep -v ASCII $MISSED_FILES_TYPES > $IGNORED_FILES_TYPES
    non_ascii_file_cnt=$(sed -n '$=' $IGNORED_FILES_TYPES)
    echo "non-ascii files: $non_ascii_file_cnt"

    rm -f $SUGGESTED_FILES
    while read file; do
        tmp=$(echo "$file" | sed -e 's/\(.*\):.*/\1/')
        echo $tmp >> $SUGGESTED_FILES
    done < $SUGGESTED_FILES.tmp

    cat $FIND_FILES | sort > $CSCOPE_FILES
    cat $SUGGESTED_FILES | sort >> $CSCOPE_FILES
    cscope_file_cnt=$(sed -n '$=' $CSCOPE_FILES)
    echo "cscope files: $cscope_file_cnt"
}

build_db()
{
    cd $BASE_DIR && eval $TIME cscope -b -q -i $CSCOPE_FILES
}


usage()
{
    prog=$(basename $0)
    echo "$prog [-h] | [-d <BASE DIR>] [-v]"
    echo
    echo "  -h print this help message"
    echo "  -d option allows user to select which dir to start indexing files."
    echo "       Default is to start from $BASE_DIR"
    echo "  -v print extra msgs while indexing files."
    echo ""


}

parseargs()
{
    while getopts  "vhd:" flag
    do
      #echo "flag [$flag]  optind [$OPTIND]  optarg [$OPTARG] "
        case "$flag" in
            v)
                VERBOSE=1
                TIME=time
                ;;

            d) # trim white space before assigning
                BASE_DIR=$(echo $OPTARG | sed -e 's/^[ \t]*//;s/[ \t]*$//')
                ;;

            :) echo "Option $OPTARG missing value"
                usage
                exit 1
                ;;

            h) usage
                exit 0
                ;;

            *) echo "Unknown option $OPTARG"
                usage
                exit 1
                ;;
        esac

    done
}

# #########################################################################
# MAIN
#

ALL_FILES=$BASE_DIR/cscope.all-files.txt
FIND_FILES=$BASE_DIR/cscope.find-files.txt
MISSED_FILES=$BASE_DIR/cscope.missed-files.txt
MISSED_FILES_TYPES=$BASE_DIR/cscope.missed-files-types.txt
IGNORED_FILES_TYPES=$BASE_DIR/cscope.ignored-files-types.txt
SUGGESTED_FILES=$BASE_DIR/cscope.suggested-files.txt
CSCOPE_FILES=$BASE_DIR/cscope.files
CSCOPE_TMP_FILES=$BASE_DIR/cscope.tmp

parseargs $*

rm -f $BASE_DIR/cscope.*

echo "Building file list starting at: [$BASE_DIR]"

eval $TIME list_all_files

eval $TIME find_all_cscope_files

eval $TIME add_missing_files

grep -v cscope $CSCOPE_FILES > $CSCOPE_TMP_FILES
mv $CSCOPE_TMP_FILES $CSCOPE_FILES

echo "Running cscope to build database"
build_db
echo "Created files:"
ls -hs $BASE_DIR/cscope*

