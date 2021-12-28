/*******************************************************************************
 * Name        : mazesolver.cpp
 * Author      : Siddharth Iyer
 * Date        : May 12th, 2021
 * Pledge      : I pledge my honor that I have abided by the Stevens Honor System. 
 * Description : Uses recursive backtracking to solve a maze.
 ******************************************************************************/
#include <iostream>
#include <fstream>
#include <vector>
#include <cstring>
#include <stdexcept>

using namespace std;

enum direction_t {
    NORTH, EAST, SOUTH, WEST
};

direction_t directions[] = {NORTH, EAST, SOUTH, WEST};

/**
 * Simple struct that represents a cell within the text-based maze.
 */
struct Cell {
    int row, col;

    /**
     * No-args constructor.
     */
    Cell() : row{0}, col{0} { }

    /**
     * Constructor that takes in (row, col) coordinates.
     */
    Cell(int _row, int _col) : row{_row}, col{_col} { }

    /**
     * Checks if two cells are equal.
     */
    bool operator==(const Cell &other) const {
        return row == other.row && col == other.col;
    }

    /**
     * Returns that cell reached from the current cell when moving in the
     * specified direction.
     */
    Cell adjacent_cell(const direction_t direction) const {
        switch (direction) {
            case NORTH:
                return Cell(row - 1, col);
            case EAST:
                return Cell(row, col + 1);
            case SOUTH:
                return Cell(row + 1, col);
            case WEST:
                return Cell(row, col - 1);
            default:
            	// Unknown direction -- just return a cell with the
            	// coordinates of the current cell.
                return Cell(row, col);
        }
    }

    /**
     * Allows for printing a cell from a cout statement.
     */
    friend std::ostream& operator<<(std::ostream& os, const Cell &cell) {
        os << "(" << cell.row << ", " << cell.col << ")";
        os.flush();
        return os;
    }
};

class MazeSolver {
public:
	/**
	 * Constructor for creating a MazeSolver. Takes as argument a string
	 * representing the filename of the text file containing the maze.
	 */
    explicit MazeSolver(const string &filename) :
        filename_{filename}, input_file_{filename.c_str()} {
        if (!input_file_) {
            throw runtime_error("File '" + filename + "' not found.");
        }
        input_file_.exceptions(std::ifstream::badbit);
        parse_file();
    }


    /**
     * Destructor. Used to free up memory allocated inside a MazeSolver.
     */
    ~MazeSolver() {
        delete [] maze_;
    }

    /**
     * Returns the path length of the solution.
     */
    int path_length() const {
        return path_length_;
    }

    /**
     * Attempts to solve the maze and returns whether or not a solution exists.
     */
    bool solve() {
        return solve_helper(start_);
    }

    /**
     * Prints the ASCII maze on the screen with cout statements.
     */
    void display_maze() {
        for(int i = 0; i<num_rows_; i++){
            for(int j = 0; j<num_cols_; j++){
                // converts back from enumerated to chars
                if(maze_[i][j] == SPACE_CHARACTER || maze_[i][j] == TEMP_CHARACTER){
                    cout << ' ';
                } else if(maze_[i][j] == WALL_CHARACTER){
                    cout << '#';
                } else if(maze_[i][j] == MARK_CHARACTER){
                    cout << '.';
                }
            }
            cout << "\n";
        }
    }

    static const int
		WALL_CHARACTER = '#',
		MARK_CHARACTER = '.',
		SPACE_CHARACTER = ' ',
        TEMP_CHARACTER = 'x';       // this is the placeholder for dead_end - could reset to " " but this is better


private:
    string filename_;
    ifstream input_file_;
    int **maze_;
    int num_rows_, num_cols_, path_length_;
    Cell start_, end_;

    /**
     * Parses the text file so that upon successful completion of this method,
     * maze_ is a 2D array of characters, start_ and end_ represent the two
     * open cells in the exterior of the maze, and path_length_ is initialized
     * to 0.
     */
    void parse_file() {
        vector<string> v;
        string line;
        while (getline(input_file_, line)) {
            v.push_back(line);
        }

        num_rows_ = v.size();
        if (num_rows_ == 0) {
            throw runtime_error("File '" + filename_ + "' is empty.");
        }
        num_cols_ = v[0].length();
        if (num_cols_ == 0) {
            throw runtime_error("File '" + filename_ + "' is empty.");
        }

        vector<Cell> points = start_and_end_points(v);

        // changed to int rows
        // dealing with characters and their conversion/compare errors was a pain
        maze_ = new int*[num_rows_];
        for (int row = 0; row < num_rows_; row++) {
            maze_[row] = new int[num_cols_];
            for (int col = 0; col < num_cols_; col++) {
                if((char)v[row][col] == '#'){
                    maze_[row][col] = WALL_CHARACTER;
                } else if ((char) v[row][col] == '.'){
                    maze_[row][col] = MARK_CHARACTER;
                } else if ((char) v[row][col] == ' '){
                    maze_[row][col] = SPACE_CHARACTER;
                }
            }
        }
        start_ = points[0];
        end_ = points[1];
        path_length_ = 0;
    }

    /**
     * Takes as input a vector of strings and returns a vector of exactly two
     * cells, representing the starting and ending points in the exterior walls
     * in the maze.
     */
    vector<Cell> start_and_end_points(const vector<string> &v) const {
        vector<Cell> points;
        unsigned int last_row = num_rows_ - 1, last_col = num_cols_ - 1;

        // top row
        for(unsigned int i=0; i<last_col; i++){
            if(v[0][i] == SPACE_CHARACTER){
                points.push_back(Cell(0,i));
            }
        }

        // bottom row - SPENT 6+ HOURS RECHECKING SOLVE_HELPER ONLY TO FIND TYPO HERE!!!
        for(unsigned int i=0; i<last_col; i++){
            if(v[last_row][i] == SPACE_CHARACTER){
                points.push_back(Cell(last_row,i));
            }
        }

        // left column exclude first and last
        for(unsigned int i=1; i<last_row; i++){
            if(v[i][0] == SPACE_CHARACTER){
                points.push_back(Cell(i,0));
            }
        }

        // right column exclude first and last
        for(unsigned int i=1; i<last_row; i++){
            if(v[i][last_col] == SPACE_CHARACTER){
                points.push_back(Cell(i,last_col));
            }
        }

        size_t num_openings = points.size();
        if (num_openings == 0) {
            throw runtime_error("Maze has no openings.");
        } else if (num_openings == 1) {
            throw runtime_error("Maze has only 1 opening.");
        } else if (num_openings > 2) {
            throw runtime_error(
                    "Ambiguous path. Maze has more than 2 openings.");
        }
        return points;
    }

    // checks if within bounds of array
    bool isValid(int a, int b){
        if(a < num_rows_ && a >= 0 && b < num_cols_ && b >= 0){
            return true;
        }
        return false;
    }

    /**
     * Attempts to solve the maze and mark the path from the starting cell to
     * the ending cell. Uses recursive backtracking to mark the path.
     */
    bool solve_helper(Cell cell) {
        // checks if within bonds of array
        if(!isValid(cell.row, cell.col)){
            return false;
        } 
        // ensures that cell hasn't been visited, isn't a wall, and isn't a dead end
        else if (!(maze_[cell.row][cell.col] == SPACE_CHARACTER)){
            return false;
        } 
        // if reached the final cell, put "." and increment path length
        else if (cell == end_){
            maze_[cell.row][cell.col] = MARK_CHARACTER;
            path_length_++;
            return true;
        } 
        // if not at end yet, mark as "." for potential path
        // if no path found, set as dead end (TEMP CHARACTER)
        // if path found, increment path length and return true (do not set dead end)
        else {
            maze_[cell.row][cell.col] = MARK_CHARACTER;
            if(solve_helper(cell.adjacent_cell(NORTH))
                || solve_helper(cell.adjacent_cell(EAST))
                || solve_helper(cell.adjacent_cell(SOUTH))
                || solve_helper(cell.adjacent_cell(WEST))){
                path_length_++;
                return true;
            } else {
                maze_[cell.row][cell.col] = TEMP_CHARACTER;
                return false;
            }
        }
    } 

};

/**
 * Main function for reading the command line arguments and producing output.
 */
int main(int argc, char *argv[]) {
    if (argc != 2) {
        cerr << "Usage: " << argv[0] << " <maze file>" << endl;
        return 1;
    }
    MazeSolver *maze_solver = NULL;
    try {
        maze_solver = new MazeSolver(argv[1]);
        if (maze_solver->solve()) {
            cout << "Solution exists: YES" << endl
                 << "Total moves:     " << maze_solver->path_length()
                 << endl << endl;
            maze_solver->display_maze();
        } else {
            cout << "Solution exists: NO" << endl;
        }
    } catch (const exception &e) {
        cerr << "Error: " << e.what() << endl;
        return 1;
    }

    // Don't forget to delete the pointer to the maze solver.
    delete maze_solver;
    return 0;
}
