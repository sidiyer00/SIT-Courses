/*******************************************************************************
 * Name          : commonwordfinder.cpp
 * Author        : Siddharth Iyer
 * Version       : 1.0
 * Date          : April 30, 2021
 * Description   : Counts frequency of words in a file.
 ******************************************************************************/
#include "rbtree.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <algorithm>
#include <bits/stdc++.h>         // this is for ::tolower
#include <cctype>
#include <iostream>
#include <cstring>

using namespace std;

bool pair_rank(const pair<string, int> &first_pair, const pair<string, int> &second_pair){
    return first_pair.second > second_pair.second;
}

// split function found on stackoverflow
vector<string> split(const string& str, const string& delim)
{
    vector<string> tokens;
    size_t prev = 0, pos = 0;
    do
    {
        pos = str.find(delim, prev);
        if (pos == string::npos) pos = str.length();
        string token = str.substr(prev, pos-prev);
        if (!token.empty()) tokens.push_back(token);
        prev = pos + delim.length();
    }
    while (pos < str.length() && prev < str.length());
    return tokens;
}

void display_table(Tree *tree, vector< pair<string,int> > vec, unsigned int limit){
    cout << "Total unique words: " << tree->size() << endl;

    if(limit > vec.size()){
      limit = vec.size();
    }

    int temp = limit;
    int max_digits = 0; 

    while (temp != 0) { 
        temp /= 10; max_digits++;
    }

    unsigned int max_word = 0;
    for(size_t i = 0; i < limit; ++i){
      if(vec[i].first.size() > max_word){
        max_word = vec[i].first.size();
      }
    }

    for(size_t i = 0; i < limit; ++i){
      cout << setw(max_digits) << right << i+1 << ". "
           << setw(max_word) << left << vec[i].first << " "
           << vec[i].second << endl;
    }

}


int main(int argc, char *argv[]){
    // invalid number of arguments handling
    if(!(argc == 3 || argc == 2)){
        cerr << "Usage: ./commonwordfinder <filename> [limit]" << endl;
        return 0;
    }

    // stores filepath for later
    const char * filepath = argv[1];

    // opens the file & checks if exists
    ifstream file(filepath);
    if(!file){
        cerr << "Error: Cannot open file '" << filepath << "' for input." << endl;
        return 0;
    }

    // limit is set by default
    int limit = 10;
    // check validity of supplied limit (must be > 0 and int)
    if(argc == 3){
        istringstream stream(argv[2]);
        if(!(stream >> limit) || limit <= 0){ 
            cerr << "Error: Invalid limit '" << stream.str() << "' received.\n";
            return 0;
        }
    }

    // if badbit exception, throw it 
    file.exceptions(ifstream::badbit);

    // read data from file and store it in string data
    auto oss = ostringstream{};
    oss << file.rdbuf();                    // no idea what this does, found on stackoverflow
    string file_contents = oss.str();

    // makes it lowercase
    transform(file_contents.begin(), file_contents.end(), file_contents.begin(), ::tolower);

    /*
    // remove all \n 
    //file_contents.erase(remove(file_contents.begin(), file_contents.end(), '\n'), file_contents.end());

    // split string into vector<string>
  
    string DELIMITER = " ";
    vector<string> data_vec = split(file_contents, DELIMITER);

    for(auto thing: data_vec){
        cout << thing << " ";
    }
    */

    // only lowercase letters, single quotes, hyphens - remove \n as well
    // ASCII: 39 - quote, 45 - hyphen, 97 to 122 - letters 
    RedBlackTree<string, int> *rbt = new RedBlackTree<string, int>();
    string temp_word;

    for(unsigned int i = 0; i < file_contents.size(); i++){
        int asci = int(file_contents[i]);        // convert letter to ascii
        if(asci == 39 || asci == 45 || (asci >= 97 && asci <= 122)){   
            temp_word += file_contents[i];       // add letter to word if meets conditions
        } else if (isspace(asci) || asci == 10){ // if " " or "\n" (the two dividers possible between words)
            // if non-zero len word (as per instructions)
            if(temp_word.size() != 0){
                RedBlackTree< string, int >::iterator it = rbt->find(temp_word);     // find location of word
                // if at end and still not found, add pair to rbt
                if(it == rbt->end()){
                    pair<string, int> temp_pair(temp_word,1);
                    rbt->insert(it, temp_pair);
                }
                else{
                    // if found before end is reached, increment value
                    // indicates duplicate found in tree
                    int a = (*it).value();
                    it->set_value(a + 1);
                }
            }
            temp_word = "";
        }
    }

    // we have a Red Black tree now with all the data in it - now we just need to sort the pairs
    // why we needed a red black tree only God and Dr. B know   
    // load all (words, frequency) pairs into vector
    vector<pair<string, int>> pairs;
    RedBlackTree<string, int>::iterator new_it = rbt->begin();
    while (new_it != rbt->end()) {
        pairs.push_back(make_pair((*new_it).key() , (*new_it).value()));
        ++new_it;
    }

    // sort vector according to pair_rank function (equality conditions are already specified in rbtree)
    stable_sort(pairs.begin(), pairs.end(), pair_rank);

    // still need to implement
    display_table(rbt, pairs, limit);

    // for the valgrind 
    delete rbt;
    return 1;

}