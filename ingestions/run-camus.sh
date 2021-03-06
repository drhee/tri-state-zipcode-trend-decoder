#!/bin/bash
#hadoop jar camus-example-0.1.0-SNAPSHOT-shaded.jar com.linkedin.camus.etl.kafka.CamusJob -P /usr/local/camus/camus-example/src/main/resources/camus.properties >> $log
log="/home/ubuntu/tri-state-zipcode-trend-decoder/ingestions/camus.log"
workdir="/usr/local/hadoop/etc/hadoop/"
HADOOP="/usr/local/hadoop/bin/hadoop"
JAR="camus-example-0.1.0-SNAPSHOT-shaded.jar"
CLASS="com.linkedin.camus.etl.kafka.CamusJob"
PROPERTIES="/usr/local/camus/camus-example/src/main/resources/camus.properties"
echo `date` >> $log
cd $workdir
$HADOOP jar $JAR $CLASS -P $PROPERTIES
echo "\n-- -- -- -- -- --\n" >> $log