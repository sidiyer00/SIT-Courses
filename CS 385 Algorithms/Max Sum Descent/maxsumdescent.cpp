/*******************************************************************************
 * Name        : maxsumdescent.cpp
 * Author      : Siddharth Iyer and Leonid Maksymenko
 * Version     : 1.0
 * Date        : April 27, 2021
 * Description : Dynamic programming solution to max sum descent problem.
 * Pledge      : I pledge my honor that I have abided by the Stevens Honor System.
 ******************************************************************************/
#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <sstream>
#include <vector>
#include <algorithm>

using namespace std;

const char DELIMITER = ' ';

int **values, // This is your 2D array of values, read from the file.
    **sums;   // This is your 2D array of partial sums, used in DP.

int num_rows; // num_rows tells you how many rows the 2D array has.
              // The first row has 1 column, the second row has 2 columns, and
              // so on...
int max_value;

/**
 * helper method for display table - gets num digits in largest value in table ]'
 * for alignment n stuff
*/
int num_digits(int num) {
    if (num / 10 == 0){
        return 1;
    } else{
        return 1 + num_digits(num / 10);
    }
}


/**
 * Displays the 2D array of values read from the file in the format of a table.
 */
void display_table() {

    int width = num_digits(max_value);
    for (int i = 0; i < num_rows; i++) {
        cout << values[i][0];
        for (int j = 1; j < i + 1; j++) {
            cout << setw(width + 1) << values[i][j];
        }
        cout << "\n";
    }
}

/**
 * Returns the maximum sum possible in the triangle of values.
 * By starting at the top of the triangle and moving to adjacent numbers on the
 * row below, this function uses dynamic programming to build up another table
 * of partial sums.
 */
int compute_max_sum() {
    // Populate the 2D array of partial sums. It should still work even if
    // num_rows is 0 (i.e. the file was blank).
    // Loop over the last row to find the max sum.

    // set last row equal to the last row of values (we will work upward)
    for(int i = num_rows; i > 1; --i){
        for(int j = 0; j < i-1; ++j){
            sums[i-2][j] = max(values[i-1][j], values[i-1][j+1]) + sums[i-2][j];
        }
    }

    // Return the max sum.
    return sums[0][0];
}

/**
 * Returns a vector of ints with the values from the top to the bottom of the
 * triangle that comprise the maximum sum.
 */
vector<int> backtrack_solution() {
    vector<int> solution;
    int tracker_index = 0;

    // we always start from the first row, first value
    solution.push_back(values[0][tracker_index]);

    for(int i = 1; i < num_rows; ++i){
        if(sums[i][tracker_index] >= sums[i][tracker_index + 1]){
            solution.push_back(values[i][tracker_index]);
        } else {
            solution.push_back(values[i][tracker_index + 1]);
            tracker_index++;
        }
    }

    for(int i = 0; i < num_rows - 1; i++){
        solution[i] = solution[i] - solution[i+1];
    }

    return solution;
}

/**
 * Reads the contents of the file into the global 2D array 'values'. If
 * successful, the function also allocates memory for the 2D array 'sums'.
 */
bool load_values_from_file(const string &filename) {
    // stores raw file in input_file
    ifstream input_file(filename.c_str());
    // if file doesn't exist, throw error and terminate
    if (!input_file) {
        cerr << "Error: Cannot open file '" << filename << "'." << endl;
        return false;
    }

    // if badbit exception, throw it 
    input_file.exceptions(ifstream::badbit);

    // store each line as a string in data
    string line;
    vector<string> data;
    try {
        while (getline(input_file, line)) {
            data.push_back(line);
        }
        input_file.close();
    } catch (const ifstream::failure &f) {
        cerr << "Error: An I/O error occurred reading '" << filename << "'.";
        return false;
    }

    // set the num_rows global variable
    num_rows = data.size();

    // initialize the matrices
    values = new int * [num_rows];
    sums = new int *[num_rows];

    int nums;

    // split the string vector into 2D array of int values
    for(int i = 0; i < num_rows; ++i){
        istringstream row_stream(data[i]);
        string temp;

        // get next char in row based on DELIMITER (default is \n but here it is " ")
        // also annoyingly, it's not a square matrix because the length grows by 1 each row
        int *row = new int[i+1];
        int j = 0;
        while(getline(row_stream, temp, DELIMITER)){
            nums = stoi(temp);
            max_value = max(max_value, nums);
            row[j] = nums;
            j++;
        }
        
        values[i] = row;
        sums[i] = row;
    }

    return true;
}

/**
 * Frees up the memory allocated for the 2D array of values and the 2D array of
 * partial sums.
 */
void cleanup() {
    // loop through values, sums - delete all the pointers
    for (int i = 0; i < num_rows; i++) {
        delete [] values[i];
    }
    // delete the values, sums pointers themselves
    delete [] values;
}

int main(int argc, char * const argv[]) {
    // checks number of arguments supplied 
    if (argc != 2) {
        cerr << "Usage: " << argv[0] << " <filename>" << endl;
        return 1;
    }
    // checks whether file actually exists
    string filename(argv[1]);
    if (!load_values_from_file(filename)) {
        return 1;
    }

    // if file is empty, display output and return 0
    if(num_rows == 0){
        cout << "Max sum: 0\n" << "Values: []" << endl;
        return 0;
    }
    
    // display table and max sum
    display_table();
    cout << "Max sum: " << compute_max_sum() << endl;

    // loop through solution path and print it 
    vector<int> soln = backtrack_solution();
    cout << "Values: [";
    for (int i = 0; i < num_rows - 1; i++) {
        cout << soln[i] << ", ";
    }
    cout << soln[num_rows-1] << "]" << endl;

    cleanup();  // clears all them filthy pointers

    return 0;
}
