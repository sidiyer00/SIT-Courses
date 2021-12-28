/*******************************************************************************
 * Name        : sieve.cpp
 * Author      : Siddharth Iyer
 * Date        : February 14, 2021
 * Description : Sieve of Eratosthenes
 * Pledge      : I pledge my honor that I have abided by the Stevens Honor System.
 ******************************************************************************/
#include <cmath>
#include <iomanip>
#include <iostream>
#include <sstream>

using namespace std;

class PrimesSieve {
public:
    PrimesSieve(int limit);

    // clearing the heap memory
    ~PrimesSieve() {
        delete [] is_prime_;
    }

    int num_primes() const {
        return num_primes_;
    }

    void display_primes() const;

private:
    // Instance variables
    bool * const is_prime_;
    const int limit_;
    int num_primes_, max_prime_;

    // Method declarations
    int count_num_primes() const;
    void sieve();
    static int num_digits(int num);
};

PrimesSieve::PrimesSieve(int limit) : is_prime_{new bool[limit + 1]}, limit_{limit} {
    // set all values in boolean array to true (except 0 and 1)
    is_prime_[0] = false;
    is_prime_[1] = false;
    for(int i = 2; i < limit + 1; i++){
        is_prime_[i] = true;
    }
    // run sieve
    sieve();
}

void PrimesSieve::display_primes() const {
    // header of output
    cout << "Number of primes found: " << num_primes_ << endl;
    cout << "Primes up to " << limit_ << ":" << endl;

    const int max_prime_width = num_digits(max_prime_), primes_per_row = 80 / (max_prime_width + 1);
    
    int primes_this_row = 0;        // number of primes printed in this row, so far

    // loop through bool array 2 -> n+1
    for(int i = 2; i < limit_ + 1; i++){

        // if the numbers per row limit reached
        if(primes_per_row == primes_this_row){
            primes_this_row = 0;        // reset
            cout << endl;               // start new row
        }

        // if prime found
        if(is_prime_[i]){
            // when starting a new row, don't add a space
            if(primes_this_row != 0){
                cout << " ";
            }

            // if won't fit on one line
            if(num_primes_ > primes_per_row){
                cout << setw(max_prime_width) << i;
            } else {
                cout << i;
            }

            primes_this_row++;
        }
    }
    cout << endl;
}

int PrimesSieve::count_num_primes() const {
    // after sieve is run, count number of True in boolean array
    int num_primes = 0;
    for(int i = 2; i < limit_ + 1; i++){
        if(is_prime_[i] == true){
            num_primes++;
        }
    } 
    return num_primes;
}

// no comments need - literally copied the pseudo-code provided
void PrimesSieve::sieve() {
    // calculatres sqrt(N) as int
    int sqrtN = static_cast<int>(sqrt(limit_));

    // sieves through boolean array
    for(int i = 2; i <= sqrtN; i++){
        if(is_prime_[i] == true){
            for(int j = static_cast<int>(pow(i,2)); j <= limit_ ; j += i){
                is_prime_[j] = false;
            }
        }
    }

    // catches max prime as the rightmost True in boolean array
    for(int i = limit_; i >= 2; i--){
        if(is_prime_[i]){
            max_prime_ = i;
            break;
        }
    }

    // counts number of primes and stores in private instance var
    num_primes_ = count_num_primes();
}

int PrimesSieve::num_digits(int num) {
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

int main() {
    cout << "**************************** " <<  "Sieve of Eratosthenes" <<
            " ****************************" << endl;
    cout << "Search for primes up to: ";
    string limit_str;
    cin >> limit_str;
    int limit;

    // Use stringstream for conversion
    istringstream iss(limit_str);

    // Check for error.
    if ( !(iss >> limit) ) {
        cerr << "Error: Input is not an integer." << endl;
        return 1;
    }
    if (limit < 2) {
        cerr << "Error: Input must be an integer >= 2." << endl;
        return 1;
    }

    cout << endl;
    PrimesSieve sieve(limit);
    sieve.display_primes();

    return 0;
}
