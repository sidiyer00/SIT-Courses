package Hw4;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Stack;

/**
 * Class that solves maze problems with backtracking.
 * @author Koffman and Wolfgang
 **/
public class Maze implements GridColors {

    /** The maze */
    private TwoDimGrid maze;

    public Maze(TwoDimGrid m) {
        maze = m;
    }

    /** Wrapper method. */
    public boolean findMazePath() {
        return findMazePath(0, 0); // (0, 0) is the start point.
    }

    /**
     * Attempts to find a path through point (x, y).
     * @pre Possible path cells are in BACKGROUND color;
     *      barrier cells are in ABNORMAL color.
     * @post If a path is found, all cells on it are set to the
     *       PATH color; all cells that were visited but are
     *       not on the path are in the TEMPORARY color.
     * @param x The x-coordinate of current point
     * @param y The y-coordinate of current point
     * @return If a path through (x, y) is found, true;
     *         otherwise, false
     */
    public boolean findMazePath(int x, int y) {
        if(x < 0 || x > maze.getNCols() - 1 || y < 0 || y > maze.getNRows() - 1){
            // current block is out of grid
            return false;
        } else if (maze.getColor(x, y) != NON_BACKGROUND){
            // current block is blocked
            return false;
        } else if (x == maze.getNCols() - 1 && y == maze.getNRows() - 1){
            // current block is destination
            maze.recolor(x, y, PATH);
            return true;
        }
        // color the current block with temp color
        maze.recolor(x, y, TEMPORARY);
        if(findMazePath(x-1, y) || findMazePath(x+1, y) || findMazePath(x, y-1) || findMazePath(x, y+1)){
            // found a path - color with PATH
            maze.recolor(x, y, PATH);
            return true;
        } else{
            // no path
            return false;
        }
    }

    // ADD METHOD FOR PROBLEM 2 HERE
    public ArrayList<ArrayList<PairInt>> findAllMazePaths(int x, int y){
        ArrayList<ArrayList<PairInt>> result = new ArrayList<ArrayList<PairInt>>();
        Stack<PairInt> trace = new Stack<PairInt>();
        findMazePathStackBased(0,0,result, trace);
        return result;
    }

    public void findMazePathStackBased(int x, int y, ArrayList<ArrayList<PairInt>> result, Stack<PairInt> trace){
        if(x < 0 || x > maze.getNCols() - 1 || y < 0 || y > maze.getNRows() - 1){
            // current block is out of grid - do nothing
        } else if (maze.getColor(x, y) != NON_BACKGROUND){
            // current block is blocked - do nothing
        } else if (x == maze.getNCols() - 1 && y == maze.getNRows() - 1){
            // current block is destination
            trace.push(new PairInt(x, y));
            ArrayList<PairInt> route = new ArrayList<PairInt>();
            route.addAll(trace);
            result.add(route);
            maze.recolor(x, y, NON_BACKGROUND);
            trace.pop();
        } else{
            // route in progress - spawn 4 new directions
            maze.recolor(x, y, TEMPORARY);
            trace.push(new PairInt(x, y));
            findMazePathStackBased(x - 1, y, result, trace);
            findMazePathStackBased(x + 1, y, result, trace);
            findMazePathStackBased(x, y - 1, result, trace);
            findMazePathStackBased(x, y + 1, result, trace);
            maze.recolor(x, y, NON_BACKGROUND);
            trace.pop();
        }
    }
    
    // ADD METHOD FOR PROBLEM 3 HERE
    public ArrayList<PairInt> findMazePathMin(int x, int y){
        ArrayList<ArrayList<PairInt>> paths = findAllMazePaths(x, y);
        if(paths.size() == 0){
            return new ArrayList<PairInt>();
        }
        ArrayList<PairInt> shortest = paths.get(0);
        for (int i = 0; i < paths.size(); i++) {
            if (paths.get(i).size() < shortest.size()) {
                shortest = paths.get(i);
            }
        }
        return shortest;
    }
    /*<exercise chapter="5" section="6" type="programming" number="2">*/
    public void resetTemp() {
        maze.recolor(TEMPORARY, BACKGROUND);
    } 
    /*</exercise>*/

    /*<exercise chapter="5" section="6" type="programming" number="3">*/
    public void restore() {
        resetTemp();
        maze.recolor(PATH, BACKGROUND);
        maze.recolor(NON_BACKGROUND, BACKGROUND);
    }
    /*</exercise>*/
}
/*</listing>*/
