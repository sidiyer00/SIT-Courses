#include <iostream>
#include <vector>
#include <algorithm>
#include <iterator> 
#include <sstream>
#include <iomanip>

using namespace std;

// Struct to represent state of water in the jugs.
struct State {
    int a, b, c;
    string directions;
    State *parent;
    
    State(int _a, int _b, int _c, string _directions) : 
        a{_a}, b{_b}, c{_c}, directions{_directions}, parent{nullptr} { }
    
    // String representation of state in tuple form.
    string to_string() {
        ostringstream oss;
        oss << "(" << a << ", " << b << ", " << c << ")";
        return oss.str();
    }
};


int main(int argc, char * const argv[]) {
    istringstream iss;

    // verify correct number of inputs  
    if(argc != 7){
        cerr << "Usage: " << argv[0] << " <cap A> <cap B> <cap C> <goal A> <goal B> <goal C>";
        return 0;
    }
    
    // verify all inputs are non-negative integers
    for(int i = 1; i < argc; i++){  
        int temp_num;
        iss.str(argv[i]);
        if(!(iss >> temp_num) || temp_num < 0){
            if(i <= 3){
                cerr << "Error: Invalid capacity '" << argv[i] << "' for jug ";
            } else if(i > 3){
                cerr << "Error: Invalid goal '" << argv[i] << "' for jug ";
            }

            if(i == 1 || i == 4){
                cerr << "A." << endl;
            } else if(i == 2 || i == 5){
                cerr << "B." << endl;
            } else if(i == 3 || i == 6){
                cerr << "C." << endl;
            }
            return 0;
        }
        iss.clear();
    }

    // put all numbers into vector for easy manipulation
    vector<int> nums;
    for(int i = 1; i < argc; i++){
        int temp;
        iss.str(argv[i]);
        iss >> temp;
        nums.push_back(temp);
        iss.clear();
    }

    // capacity of jug C cannot be 0
    if(nums.at(2) == 0){
        cerr << "Error: Invalid capacity '0' for jug C." << endl;
        return 0;
    }

    // goal cannot be larger than capacity 
    if(nums.at(0) < nums.at(3)){
        cerr << "Error: Goal cannot exceed capacity of jug A." << endl;
        return 0;
    } else if(nums.at(1) < nums.at(4)){
        cerr << "Error: Goal cannot exceed capacity of jug B." << endl;
        return 0;
    } else if(nums.at(2) < nums.at(5)){
        cerr << "Error: Goal cannot exceed capacity of jug C." << endl;
        return 0;
    }

    // jug C == sum(goal states of A, B, C)
    if(!(nums.at(2) == nums.at(3) + nums.at(4) + nums.at(5))){
        cerr << "Error: Total gallons in goal state must be equal to the capacity of jug C." << endl;
        return 0;
    }



    return 0;

}