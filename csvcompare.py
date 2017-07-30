import csv
import argparse

DESIRED_COLUMNS = ['Entity', 'Relation', 'Value']

def compare_two_csv(csv1_filename,csv2_filename):

    csv1 = csv.DictReader(open(csv1_filename, "r"), delimiter='|')
    csv2 = csv.DictReader(open(csv2_filename, "r"), delimiter='|')

    csv1_list=[]
    csv2_list=[]
    miss_data=[]

    for row1 in csv1:
        rows1 = []
        for i in DESIRED_COLUMNS:
            rows1.append(row1[i])
        csv1_list.append(rows1)

    for row2 in csv2:
        rows2 = []
        for i in DESIRED_COLUMNS:
            rows2.append(row2[i])
        csv2_list.append(rows2)

    for element in csv1_list:
        if element not in csv2_list:
             miss_data.append(element)

    count =len(csv1_list) - len(miss_data)

    if (len(miss_data) is 0):
        return ("Pass",count,None)
    else:
        return ("Fail",count,miss_data)

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('-e', '--Expected_csv_file', help='Expected Output csv')
    parser.add_argument('-a', '--Actual_csv_file', help='Testing Output csv')
    parser.add_argument('-o', '--Miss_data_csv_file', help='Missing Data csv')

    args = parser.parse_args()

    expected_filename = args.Expected_csv_file
    actual_filename = args.Actual_csv_file
    output_filename = args.Miss_data_csv_file


    result,match_count,list_of_missing_data=compare_two_csv(expected_filename,actual_filename)
    if result is 'Pass':
        print(result,match_count)
    else:
        print(result,match_count)

        with open(output_filename, 'w') as csvfile:
            missed_data_writer = csv.writer(csvfile, delimiter='|')
            missed_data_writer.writerow(DESIRED_COLUMNS)
            for miss in list_of_missing_data:
                missed_data_writer.writerow(miss)
