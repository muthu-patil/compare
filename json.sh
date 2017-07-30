pdfExtractorJarPath="/home/muthu/work/Projects/LaravelApplications/Uniqreate/resources/shellscripts/documentprocessor"
testDataPath="/home/muthu/work/Projects/LaravelApplications/Uniqreate/storage/app/contents/files"
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


# Remove file extention from file name:

outputFileName=$(echo $name | cut -f 1 -d '.')

#field  extract process

# java -jar $pdfExtractorJarPath/DocumentProcessor.jar -f $testDataPath/$name -o $pdfExtractorOutPath -r $pdfExtractorJarPath/extraction_rules.json -m $pdfExtractorJarPath/field_mapping.json

java -jar $pdfExtractorJarPath/DocumentProcessor.jar -f $testDataPath/$name -o $pdfExtractorOutPath -r $pdfExtractorJarPath/extraction_rules.json

sleep 1

echo 'comparing the json files'

cd $pdfExtractorOutPath

jsondiff  "$outputFileName".fields.json "$outputFileName"_expect.json > "$outputFileName"_results.csv

echo 'comparision of the json files done'

echo 'writing the results into the file'

 #  only with comma fileResultsCount=$(awk -F '[\t,]' '{print NF-1}' "$outputFileName"_results.csv)

fileResultsCount=$(awk -F\},  '{print NF-1}' "$outputFileName"_results.csv )


if [ -s "$outputFileName".fields.json ] && [ -s "$outputFileName"_expect.json ]
then

  if [ $fileResultsCount -gt  0 ]
  then
      echo "fail"
      echo "$name | $((fileResultsCount + 1)) | Fail" >> $resultsPath/$resultsFileName
      else
      echo "pass"
      echo "$name | $fileResultsCount | Pass" >> $resultsPath/$resultsFileName
  fi

else

 echo 'The output is empty'
 echo "$name | Expected/Actual-EmptyFile | Fail" >> $resultsPath/$resultsFileName
fi

echo 'completed writing the results into the file'

done <"$file"

cd $resultsPath

echo "Sending the test results through email."

# mail -s "SGX-Results-TestMail" -A $resultsFileName muthu@iqreateinfotech.com  < message.txt

echo "Email has been sent to the users"

echo "End of execution"

