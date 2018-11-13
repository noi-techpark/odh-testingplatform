if [ $# -ne 1 ]
   then
      echo 'Usage: ./script.sh <configfile>'
      exit 1
fi;

# import config variables

. $1

set -x
set -e

cd /tmp

TMPDIR=odh$$

echo $TMPDIR

mkdir $TMPDIR

cd $TMPDIR

#
# test session timestamp
#
SESSION_ID=$(PGPASSWORD=$PGPASSWORD psql -q -t -h $PGHOST -U $PGUSER -c 'insert into test_session values (default, default) returning id')

echo ">$SESSION_ID<"

# exit 1

curl -H 'Content-Type: application/json' -H "Authorization: bearer ${AUTHORIZATIONBEARER} " -X POST -d "{\"query\": \"query { organization(login: \\\"${USERLOGIN}\\\") {repositories (first:${REPOSITORYSIZE}) { nodes { url } } } }\"}" $APIURL | grep -o -E 'http[^"]+' | while read L
do
    cd /tmp
    cd $TMPDIR
    echo $L
    GIT_TERMINAL_PROMPT=0 git clone --depth 1 $L
    timestamp=$(date +"%F %H:%M")
    echo $timestamp
    REPOID=$(PGPASSWORD=$PGPASSWORD psql -h $PGHOST -U $PGUSER -d $PGDBNAME -c "INSERT INTO repositories VALUES (DEFAULT, '$L', '$timestamp', $SESSION_ID)")
    REPOID=$(PGPASSWORD=$PGPASSWORD psql -h $PGHOST -U $PGUSER -d $PGDBNAME -c "SELECT id FROM repositories WHERE name = '$L' ORDER BY TIMESTAMP DESC LIMIT 1")
    var=$(echo $REPOID | tr -dc '0-9')
    REPOID=${var::-1}
    echo $REPOID

    basename=$(basename $L)
    cd $basename
        for F in `find . -type f -name "*soapui*.xml"`
        do
            echo $F
            prefix="./";
            F=${F#$prefix}; 
            TMPDIR2=/tmp/$TMPDIR/$basename/$F
            cd $TESTRUNNER_DIR
            ./testrunner.sh -a -M -I /tmp/$TMPDIR/$basename/$F
            value=`cat soapui.log`
            xmltxt=$(cat test_case_run_log_report.xml)
            PGPASSWORD=$PGPASSWORD psql -h $PGHOST -U $PGUSER -d $PGDBNAME -c "INSERT INTO log VALUES ('$value', '$xmltxt', $((REPOID)), DEFAULT )"
        done
done

exit 0
