pdfExtractorJarPath="/home/muthu/work/Projects/LaravelApplications/Uniqreate/resources/shellscripts/documentprocessor"
testDataPath="/home/muthu/work/Projects/LaravelApplications/Uniqreate/storage/app/contents/files"
#iepyRelationPath="/home/muthu/work/Projects/LaravelApplications/Uniqreate/storage/app/contents/analysis/relation"
pdfExtractorOutPath="/home/muthu/work/Projects/LaravelApplications/Uniqreate/storage/app/contents/analysis/"
dataExtractionPath="/home/muthu/work/Projects/LaravelApplications/dataextraction"
scriptPath="/home/muthu/work/Projects/LaravelApplications/Uniqreate/tests/iepy"
resultsPath="/home/muthu/work/Projects/LaravelApplications/Uniqreate/storage/app/contents/analysis/meta"

resultsFileName="final_results.txt"

echo 'log the test execution date into the result file'
cd $resultsPath

echo "Empty the previous results"

cat /dev/null > $resultsFileName

echo 'write test execution date and time'

(date +%d-%m-%Y-%H:%M) >> $resultsFileName

# write headers in the file

echo "InputFileName | MismatchFieldCount | Result" >> $resultsFileName

cd $scriptPath

ls -l $testDataPath | awk {'print $9'}  | grep '[^[:blank:]]' > inputfilelist.txt

file="$scriptPath/inputfilelist.txt"
while IFS= read line
do
        # display $line or do somthing with $line
        name="$line"
echo "Name read from file - $name"

#file1=$(sed -n 1p inputfilelist.txt)

#java -jar $pdfExtractorJarPath/extractor/TableExtractor.jar -f $testDataPath/$name -o $pdfExtractorOutPath/outputFile1Name1

# Remove file extention from file name:

outputFileName=$(echo $name | cut -f 1 -d '.')

#java -jar $pdfExtractorJarPath/DocumentProcessor.jar -f $testDataPath/$name -o $pdfExtractorOutPath -r  '[{"left_entity_kind":"ORGANIZATION","right_entity_kind":"NUMBER"},{"left_entity_kind":"PERSON","right_entity_kind":"NUMBER"},{"left_entity_kind":"DATE","right_entity_kind":"NUMBER"},{"left_entity_kind":"PERSON","right_entity_kind":"PERCENT"},{"left_entity_kind":"ORGANIZATION","right_entity_kind":"PERCENT"}]'

#future  extract process

 java -jar $pdfExtractorJarPath/DocumentProcessor.jar -f $testDataPath/$name -o $pdfExtractorOutPath -r $pdfExtractorJarPath/extraction_rules.json -m $pdfExtractorJarPath/field_mapping.json

echo "switch to data extraction dir"

cd $dataExtractionPath

#./extract_fields_by_rule.sh $pdfExtractorOutPath/"$outputFileName".evidence.json $resultsPath/$outputFileName.csv

sleep 1

echo 'comparing the csv files'
cd $resultsPath

# grep -v -f $outputFileName.csv "$outputFileName"_expect.csv  > "$outputFileName"_results.csv

python3 csvcompare.py -e "$outputFileName"_expect.csv -a $outputFileName.csv -o "$outputFileName"_results.csv

echo 'comparision of the csv files done'


#field pass count

#fileExpectedCount=$(grep -vc '^\s*$'  "$outputFileName"_expect.csv )

#passcount=$((fileExpectedCount-fileResultsCount))

# clear the results file or write the date 
echo 'writing the results into the file'

# file1Countexp=$(grep -c  $  "$outputFileName"_results.csv )

fileResultsCount=$(grep -vc '^\s*$'  "$outputFileName"_results.csv )

# wc  -l "$outputFileName"_results.csv >> $resultsFileName



if [ -s $outputFileName.csv ] && [ -f "$outputFileName"_expect.csv ]
then

  if [ $fileResultsCount -gt  0 ]
  then
      echo "fail"
      echo "$name | $((fileResultsCount-1)) | Fail" >> $resultsFileName
      else
      echo "pass"
      echo "$name | $fileResultsCount | Pass" >> $resultsFileName
  fi

else

 echo 'The output is empty'
 echo "$name | Expected/Actual-EmptyFile | Fail" >> $resultsFileName
fi

echo 'completed writing the results into the file'

done <"$file"

cd $resultsPath

echo "Sending the test results through email."

# mail -s "SGX-Results-TestMail" -A $resultsFileName muthu@iqreateinfotech.com  < message.txt

echo " Email has been sent to the users"

echo "End of execution"
