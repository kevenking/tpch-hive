#!/usr/bin/env bash

# TPC-H Scale factor
SCALE=1

_DIR=`pwd`

RESULT_FILE=$_DIR/result-tpch-hive.txt

# cleanup
echo "Cleanup ..."
${HADOOP_HOME}/bin/hadoop fs -rmr -skipTrash /tpch
echo "Done."

# compile dbgen
cd ${_DIR}/tpch/dbgen
make -f makefile.suite

# generate *.tbl data
./dbgen -v -f -s ${SCALE}

mv *.tbl ${_DIR}/TPC-H_on_Hive/data/

echo "Copying data into HDFS ..."
cd ${_DIR}/TPC-H_on_Hive/data/
sh tpch_prepare_data.sh
echo "Done."

if [ -e "$RESULT_FILE" ]; then
    ts=`date "+%F-%R" --reference=$RESULT_FILE`
    backup="$RESULT_FILE.$timestamp"
    mv $RESULT_FILE $backup
fi

echo "-- Hadoop Configurations" | tee -a $RESULT_FILE
echo "-- core-site.xml" | tee -a $RESULT_FILE
cat ${HADOOP_HOME}/conf/core-site.xml | tee -a $RESULT_FILE
echo "-- hdfs-site.xml" | tee -a $RESULT_FILE
cat ${HADOOP_HOME}/conf/hdfs-site.xml | tee -a $RESULT_FILE
echo "-- mapred-site.xml" | tee -a $RESULT_FILE

echo "-- Hive configurations" | tee -a $RESULT_FILE
cat ${HIVE_HOME}/conf/hive-site.xml | tee -a $RESULT_FILE
echo ""

cd ${_DIR}/TPC-H_on_Hive/

sh tpch_benchmark.sh | tee -a $RESULT_FILE