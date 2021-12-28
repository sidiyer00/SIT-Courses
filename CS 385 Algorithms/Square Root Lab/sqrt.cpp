/*******************************************************************************
 * Name    : sqrt.cpp
 * Author  : Siddharth Iyer
 * Version : 1.0
 * Date    : February 5, 2021
 * Description : Computes the square root of argument_1 at a precision of argument_2
 * Pledge : I pledge my honor that I have abided by the Stevens Honor System.
 ******************************************************************************/

#include <iostream>
#include <iomanip>
#include <sstream>
#include <limits>
#include <algorithm>
#include <cmath>

using namespace std;

double sqrt(double num, double epsilon){
    if (num < 0){
        cout << std::numeric_limits<double>::quiet_NaN() << endl;
        return 1;
    } 
    else if (num == 0 || num == 1){
        cout << num << endl;
        return num;
    } 
    else{
        double last_guess = 1;
        double next_guess = (last_guess + num/last_guess)/2;

        while (abs(last_guess - next_guess) > epsilon){
            double temp = next_guess;
            next_guess = (next_guess + num/next_guess)/2;
            last_guess = temp;
        }
        
        cout << next_guess << endl;
        return next_guess;
    }

}

int main(int argc, char* argv[]){
    double n;
    double margin = .00000001;
    istringstream iss;

    std::cout << std::fixed;
    std::cout << std::setprecision(8);


    // too few or too many arguments
    if (argc <= 1 || argc >= 4){
        cerr << "Usage: " << argv[0] << " <value> [epsilon]" << endl;
        return 1;
    }

    // read and store n
    iss.str(argv[1]);
    if (!(iss >> n)){           // throw error if invalid
        cerr << "Error: Value argument must be a double." << endl;
        return 1;
    }
    iss.clear();
    // if a 2nd argument exists, read and store into margin
    if(argc == 3){
        iss.str(argv[2]);
        if (!(iss >> margin)){  // throw error if cannot covert
            cerr << "Error: Epsilon argument must be a positive double." << endl;
            return 1;
        }
        iss.clear();
        if (margin <= 0){
            cerr << "Error: Epsilon argument must be a positive double." << endl;
            return 1;
        }
    }

    return sqrt(n, margin);
    
}



