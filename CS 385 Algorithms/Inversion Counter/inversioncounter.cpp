/*******************************************************************************
 * Name        : inversioncounter.cpp
 * Author      : Siddharth Iyer
 * Version     : 1.0
 * Date        : March 29th, 2021
 * Description : Counts the number of inversions in an array.
 * Pledge      : I pledge my honor that I have abided by the Stevens Honor System.
 ******************************************************************************/
#include <iostream>
#include <algorithm>
#include <sstream>
#include <vector>
#include <cstdio>
#include <cctype>
#include <cstring>

using namespace std;


// Function prototype.
static long mergesort(int array[], int scratch[], int low, int high);

/**
 * Counts the number of inversions in an array in theta(n^2) time.
 */
long count_inversions_slow(int array[], int length) {
    long count = 0L;
    if(length == 1){
        return 0;
    }
    for(int i = 0; i < length - 1; i++){
        int temp = array[i];
        for(int j = i + 1; j < length; j++){
            if(temp > array[j]){
                count++;
            }
        }
    }
    return count;
}

static long mergesort(int array[], int scratch[], int low, int high) {
    long count = 0L;
    if (low < high) {
        int mid = low + (high - low) / 2;
        int new_low = low;
        int new_high = mid + 1;

        count = mergesort(array, scratch, low, mid) + mergesort(array, scratch, mid + 1, high);

        for (int i = low; i <= high; i++) {
            if (new_low <= mid && (new_high > high || array[new_low] <= array[new_high])) {
                scratch[i] = array[new_low++];
            } else {
                scratch[i] = array[new_high++];
                count += mid - new_low + 1;
            }
        }
        for (int i = low; i <= high; i++) {
            array[i] = scratch[i];
        }
    }
    return count;

}


/**
 * Counts the number of inversions in an array in theta(n lg n) time.
 */
long count_inversions_fast(int array[], int length) {
    // TODO
    return 0;
}


int main(int argc, char *argv[]) {
    // type - keeps track of which algo we're using
    string type;

    // command line parsing 
    if(argc == 1){                  // none => fast
        type = "fast";
    } else if (argc == 2){          // 2 => slow (if spelled correctly)
        if(strcmp(argv[1], "slow") == 0){
            type = "slow";
        } else{
            cerr << "Error: Unrecognized option '" << argv[1] << "'." << endl;
            return 0;
        }
    } else {                        // else   =>> error
        cerr << "Usage: " << argv[0] << " [slow]" << endl;
        return 0;
    }

    cout << "Enter sequence of integers, each followed by a space: " << flush;

    istringstream iss;
    int value, index = 0;
    vector<int> values;
    string str;
    str.reserve(11);
    char c;
    while (true) {
        c = getchar();
        const bool eoln = c == '\r' || c == '\n';
        if (isspace(c) || eoln) {
            if (str.length() > 0) {
                iss.str(str);
                if (iss >> value) {
                    values.push_back(value);
                } else {
                    cerr << "Error: Non-integer value '" << str
                         << "' received at index " << index << "." << endl;
                    return 1;
                }
                iss.clear();
                ++index;
            }
            if (eoln) {
                break;
            }
            str.clear();
        } else {
            str += c;   
        }
    }

    // more error handling - no sequence specified
    if(values.size() == 0){
        cerr << "Error: Sequence of integers not received." << endl;
        return 0;
    }

    // call function 
    if(strcmp(type.c_str(), "slow") == 0){
        cout << "Number of inversions: " << count_inversions_slow(&values[0], values.size()) << endl;
    } else if(strcmp(type.c_str(), "fast") == 0){
        cout << "Number of inversions: " << count_inversions_fast(&values[0], values.size()) << endl;
    }

    return 0;
}
