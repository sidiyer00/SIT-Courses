/*******************************************************************************
 * Name        : stairclimber.cpp
 * Author      : Siddharth Iyer and Leonid Maksymenko
 * Date        : March 6, 2021
 * Description : Lists the number of ways to climb n stairs.
 * Pledge      : I pledge my honor that I have abided by the Stevens Honor System.
 ******************************************************************************/
#include <iostream>
#include <vector>
#include <algorithm>
#include <iterator> 
#include <sstream>
#include <iomanip>

using namespace std;

// nothing to comment - literally copied from Python example script
vector< vector<int> > get_ways(int num_stairs) {
    vector<vector<int>> ways;
    if(num_stairs <= 0){
        vector<int> a;
        ways.push_back(a);
    } else{
        for(int i = 1; i < 4; i++){
            if(num_stairs >= i){
                vector<vector<int>> result = get_ways(num_stairs - i);
                for(unsigned int j = 0; j < result.size();j++){
                    result[j].insert(result[j].begin(), i);
                }
                ways.insert(ways.end(), result.begin(), result.end());
            }
        }
    }

    return ways;
}

// stole from Sieve Project
int num_digits(int num) {
    // keeps track of number of digits
    int digits = 0;
    // keep taking off digits from right
    while(num >= 1){
        // cast to integer (should floor by default)
        num = static_cast<int>(num/10);
        digits += 1;
    }
    return digits;
}

void display_ways(const vector< vector<int> > &ways) {
    // number of ways
    int len = ways.size();
    // width of the max number
    int width = num_digits(len);

    // loop through all ways and display them
    for(int i = 0; i < len; i++){
        ostringstream oss;
        vector<int> temp = ways[i];

        // converts vector<int> to string
        copy(temp.begin(), temp.end()-1, ostream_iterator<int>(oss, ", "));
        oss << temp.back();
        
        // calculates the indent for single digits nums
        int indent = width - num_digits(i+1);

        // indents
        for (int j = 0; j < indent; j++){
            cout << " ";
        }

        // prints
        cout << i+1 << ". " << "[" << oss.str() << "]" << endl;
    }
}


int main(int argc, char * const argv[]) {
    int num_stairs;
    istringstream iss;

    // Too many/few inputs?
    if(argc != 2){
        cerr << "Usage: " << argv[0] << " <number of stairs>" << endl;
        return 0;
    }
    // input isn't positive integer?
    iss.str(argv[1]);
    if(!(iss >> num_stairs) || num_stairs <= 0){
        cerr << "Error: Number of stairs must be a positive integer." << endl;
        return 0;
    }
    
    // nested vector with all ways 
    vector<vector<int>> ways = get_ways(num_stairs);
    int len = ways.size();

    // handle plural form of way/stair
    if(len == 1){
        cout << "1 way to climb 1 stair." << endl;
    } else{
        cout << len << " ways to climb " << num_stairs << " stairs." << endl;
    }

    // displays all ways to screen
    display_ways(ways);

    return 1;
}



