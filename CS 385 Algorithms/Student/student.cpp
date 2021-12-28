/*******************************************************************************
 * Name    : student.cpp
 * Author  : Siddharth Iyer
 * Version : 1.0
 * Date    : February 11, 2021
 * Description : Student Class
 * Pledge : I pledge my honor that I have abided by the Stevens Honor System.
 ******************************************************************************/

#include<iostream>
#include <iomanip>
#include<cstring>
#include<vector>

using namespace std;

class Student{
    private:
        string first_;
        string last_;
        float gpa_;
        int id_;

    public:
        // constructor
        Student(string firstname, string lastname, float gpa, int id): first_{firstname}, last_{lastname}, gpa_{gpa}, id_{id} {}
        
        // Declare public methods
        string full_name(void) const;
        int id(void) const;
        float gpa(void) const;
        void print_info(void) const;

};

string Student::full_name(void) const {
    return first_ + " " + last_;
}

int Student::id(void) const {
    return id_;
}

float Student::gpa(void) const {
    return gpa_;
}

void Student::print_info(void) const {
    cout << full_name() << ", GPA: " <<  fixed << setprecision(2) << gpa()
    << ", ID: " << id() << endl;
}


vector<Student> find_failing_students(const vector<Student> &students) {
    vector<Student> failing_students;

    for(auto student: students){
        if (student.gpa() < 1.0){
            failing_students.push_back(student);
        }
    }

    return failing_students;
}

void print_students(const vector<Student> &students){
    for (auto student: students){
        student.print_info();
    }
}


int main() {
    string first_name, last_name;
    float gpa;
    int id;
    char repeat;
    vector<Student> students;
    do {
        cout << "Enter student's first name: ";
        cin >> first_name;
        cout << "Enter student's last name: ";
        cin >> last_name;
        gpa = -1;
        while (gpa < 0 || gpa > 4) {
            cout << "Enter student's GPA (0.0-4.0): ";
            cin >> gpa;
        }
        cout << "Enter student's ID: ";
        cin >> id;
        students.push_back(Student(first_name, last_name, gpa, id));
        cout << "Add another student to database (Y/N)? ";
        cin >> repeat;
    } while (repeat == 'Y' || repeat == 'y');

    cout << endl << "All students:" << endl;
    print_students(students);

    cout << endl << "Failing students:";

    vector<Student> failing_students = find_failing_students(students);
    if (failing_students.empty()) {
        cout << " None";
    } else {
        cout << endl;
        print_students(failing_students);
    }

    return 0;
}