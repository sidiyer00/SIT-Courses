/*******************************************************************************
 * Name        : unique.cpp
 * Author      : Siddharth Iyer and Leonid Maksymenko
 * Date        : February 27, 2021
 * Description : Determining uniqueness of chars with int as bit vector.
 * Pledge      : I pledge my honor that I have abided by the Stevens Honor System.
 ******************************************************************************/
#include <iostream>
#include <cctype>

using namespace std;

bool is_all_lowercase(const string &s) {
    int len = s.length();
    for(int i = 0; i < len; i++){
        if(isupper(s[i])){          // checks if character is uppercase
            return false;           // returns false immediately when discovered
        }
    }
    return true;
}

bool is_all_letter(const string &s){
    int len = s.length();
    for(int i = 0; i < len; i++){
        if(isdigit(s[i])){          // checks if character is a digit
            return false;           // returns false immediately when discovered
        }
    }
    return true;
}

bool all_unique_letters(const string &s) {
    // in C++ 97 to 122 ASCII correspond to "a" to "z" / int k = (int) mychar;
    // map "a" to --> 00000...001, "b" --> 00000...010, c --> ...100 etc

    // keeps track of which bits have been encountered by      
    unsigned int bit_tracker = 0;

    for(const auto c: s){
        // moves 1 bit to corresponding index based on input character's distance from "a"
        unsigned int chr = 1 << (c - 'a');    

        // chr OR bit_tracker is > bit_tracker is chr is unique, it is unchanged otherwise   
        if(bit_tracker == (chr | bit_tracker)){
            return false;       // return false immediately when duplicate found
        }
        // since this chr is unique, update bit_tracker
        bit_tracker = bit_tracker | chr;
    }
    // if all are unique, return true
    return true;
}

int main(int argc, char * const argv[]) {
    // if fewer or greater than 1 argument supplied, throw error
    if(argc != 2){
        cerr << "Usage: " << argv[0] << " <string>" << endl;
        return 0;
    }
    // if all lowercase and letter, proceed with program, else throw error
    if(is_all_lowercase(argv[1]) && is_all_letter(argv[1])){
        if(all_unique_letters(argv[1])){
            cout << "All letters are unique." << endl;
        } else {
            cout << "Duplicate letters found." << endl;
        }
    } else{
        cerr << "Error: String must contain only lowercase letters." << endl;
    }
    return 0;

}
