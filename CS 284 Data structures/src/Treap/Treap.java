package Treap;

import java.util.Random;
import java.util.Stack;

public class Treap<E extends Comparable> {

    /**
     * Node: private inner class
     * @param <E> - must be comparable
     */
    private static class Node<E>{

        // instance variables
        public E data;
        public int priority;
        public Node<E> left;
        public Node<E> right;

        // constructor
        public Node(E data, int priority) throws Exception {
            if(data == null){
                throw new Exception("Data param cannot be null");
            }
            this.data = data;
            this.priority = priority;
            this.left = null;
            this.right = null;
        }

        // rotates tree right and returns new head
        public Node<E> rotateRight(){
            Node<E> oldHead = this;
            Node<E> oldLeft = this.left;

            oldHead.left = oldLeft.right;
            oldLeft.right = oldHead;

            return oldLeft;
        }

        // rotates tree left and returns new head
        public Node<E> rotateLeft(){
            Node<E> oldHead = this;
            Node<E> oldRight = this.right;

            oldHead.right = oldRight.left;
            oldRight.left = oldHead;
            return oldRight;
        }
    }

    // instance variables
    private Random priorityGenerator;
    private Node<E> root;

    // constructor
    public Treap(){
        this.priorityGenerator = new Random();
        this.root = null;
    }

    // constructor (param: seed)
    public Treap(long seed){
        this.priorityGenerator = new Random(seed);
        this.root = null;
    }

    /**
     * adds new (E key, priority) pair to Treap
     * priority is randomly generated
     *
     * @param key
     * @return
     * @throws Exception
     */
    public boolean add(E key) throws Exception {
        return addHelper(key, priorityGenerator.nextInt());
    }

    /**
     * adds new (E key, priority) pair, priority predefined
     * @param key
     * @param priority
     * @return
     * @throws Exception
     */
    public boolean addHelper(E key, int priority) throws Exception {
        // if no root, add key at root
        if(root == null){
            root = new Node(key, priority);
            return true;
        }
        Node<E> current = root;     // keeps track of current node
        boolean added = false;      // terminates when added == true
        Stack<Node<E>> stacc = new Stack<Node<E>>();        // stack for storing past tree nodes

        // keep running until key is added to tree
        while(added == false){
            if(key.compareTo(current.data) == 0){ // key == current
                break; // goes to reheap and returns added (which is false rn)
            }

            if(key.compareTo(current.data) < 0){ // key < current, look left
                stacc.push(current);    // every node you visit, add to Stack so you can manipulate later
                if(current.left == null){ // can't look left? add to left
                    current.left = new Node<E>(key, priority);
                    current = current.left;
                    added = true;
                } else { current = current.left;}

            } else { // key > current, look right
                stacc.push(current);
                if (current.right == null){ // can't look right, add to right
                    current.right = new Node<E>(key, priority);
                    current = current.right;
                    added = true;
                } else { current = current.right;}
            }
        }

        reheap(current, stacc);
        return added;
    }

    private void reheap(Node<E> current, Stack<Node<E>> stacc){
        // while there is still stuff int he stacc
        while (!stacc.isEmpty()) {
            Node<E> parent = stacc.pop();
            if (parent.priority < current.priority){ // violation, parent must have greater priority
                if (current.data.compareTo(parent.data) < 0) { // current is < parent
                    current = parent.rotateRight();  // rotate right since current is to left of parent
                } else {
                    current = parent.rotateLeft();   // rotate left since current is to right of parent
                                                     // makes parents child of current
                }

                if (!stacc.isEmpty()) {
                    if (stacc.peek().left == parent) { // grandparent.left == parent?
                        stacc.peek().left = current;  // grandparent.left = current (w/child parent)
                    } else {
                        stacc.peek().right = current; // same thing for right
                    }
                } else {
                    root = current;                   // if stacc is empty after pop, root = current (last node visisted)
                }
            } else { // everything is cool...nothing to do
                break;
            }
        }
    }

    public boolean delete(E key){
        if(find(key) == false){ // if tree doesn't contain key, return false, else continue
            return false;
        }
        if(root.left == null && root.right == null){ // if key is root node & no children nodes
            root = null;        // delete root
            return true;
        }

        // root == key
        if (root.data.equals(key)){
            // tree has more branches
            if (root.left != null && root.right != null){
                // left priority, rotateRight, else rotateLeft
                if (root.left.priority > root.right.priority) {
                    root.rotateRight();
                } else {
                    root.rotateLeft();
                }
            }
            // left is branch and right is null
            if (root.left != null && root.right == null) {
                root = root.rotateRight();
            }

            // right is branch and left is null
            if (root.right != null && root.left == null) {
                root = root.rotateLeft();
            }
        }

        //the object is in the tree
        Stack<Node<E>> stacc = new Stack<Node<E>>();
        return delete(key, root, stacc);

    }

    private boolean delete(E key, Node<E> node, Stack<Node<E>> stacc) {
        boolean deleted = false;

        int compareResult = key.compareTo(node.data);
        if (compareResult < 0) { // key < node, so look on left branch
            stacc.push(node);
            return delete(key, node.left, stacc);
        }
        if (compareResult > 0) { // key > node, so look on right branch
            stacc.push(node);
            return delete(key, node.right, stacc);
        }
        if (compareResult == 0) { // key == node (node to be deleted found)
            while (true) {
                if (node.left == null && node.right == null) { // if leaf, break and jump to end
                    break;
                }
                if (node.left != null && node.right != null) { // if full node (with two branches)
                    Node<E> parent = stacc.pop();  // get parent from stacks
                    if (node.left.priority > node.right.priority) { // left priority, remove by overwriting
                        if (parent.right.equals(node)) {
                            parent.right = node.rotateRight();
                            stacc.push(parent.right);
                        } else {
                            parent.left = node.rotateRight();
                            stacc.push(parent.left);
                        }
                    } else {    // right priority, remove by overwriting
                        if (parent.right.equals(node)) {
                            parent.right = node.rotateLeft();
                            stacc.push(parent.right);
                        } else {
                            parent.left = node.rotateLeft();
                            stacc.push(parent.left);
                        }
                    }
                }

                if (node.left != null && node.right == null) { // if incomplete branch, rotate and unrotate accordingly
                    Node<E> parent = stacc.pop();
                    if (parent.right != null && parent.right.equals(node)) {
                        parent.right = node.rotateRight();
                        stacc.push(parent.right);
                    } else {
                        parent.left = node.rotateRight();
                        stacc.push(parent.left);
                    }
                }
                if (node.right != null && node.left == null) {
                    Node<E> parent = stacc.pop();
                    if (parent.right != null && parent.right.equals(node)) {
                        parent.right = node.rotateLeft();
                        stacc.push(parent.right);
                    } else {
                        parent.left = node.rotateLeft();
                        stacc.push(parent.left);
                    }
                }
            }

            // peek to see parent, and remove node from parent's children
            Node<E> parent = stacc.peek();
            if (parent.left != null && parent.left.equals(node)) {
                parent.left = null;
                deleted = true;
                return deleted;
            } else {
                parent.right = null;
                deleted = true;
                return deleted;
            }
        }
        return true;
    }

    public boolean find(E key){
        return findHelper(key, root);
    }

    private boolean findHelper(E key, Node<E> current){
        if (current == null) {
            return false;
        }
        int compareResult = current.data.compareTo(key);

        if (compareResult == 0) {
            return true;
        }
        if (compareResult < 0) {
            return findHelper(key, current.right);
        } else {
            return findHelper(key, current.left);
        }
    }

    public String toString(){
        return toStringHelper(root, 0);
    }

    public String toStringHelper(Node<E> current, int i){
        String result = "";

        for (int j = 0; j < i; j++) {
            result += "\t";
        }

        if (current == null) {
            result += "null";
            return result;
        }

        result += current.toString() + "\n";
        result += toStringHelper(current.left, i+1) + "\n";
        result += toStringHelper(current.right, i+1);

        return result;
    }




}