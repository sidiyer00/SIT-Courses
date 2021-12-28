package DoublyLinkedList;

import javax.xml.transform.stream.StreamSource;
import java.util.ArrayList;

/***
 * This is a doubly linked list
 * @param <E>
 */
public class IDLList<E> {

    /***
     * creates a Node for use in list
     * @param <F>
     */
    private class Node<F> {
        private F data;
        private Node<F> next;
        private Node<F> prev;

        /***
         * Creates first node in Doubly Linked List
         * @param elem
         */
        Node(F elem) {
            data = elem;
            next = null;
            prev = null;
        }

        /***
         * Creates Node with data = elem, previous node = prev, next node = next
         * @param elem
         * @param prev
         * @param next
         */
        Node(F elem, Node<F> prev, Node<F> next){
            data = elem;
            this.prev = prev;
            this.next = next;
        }
    }

    // instance variables
    private Node<E> head;
    private Node<E> tail;
    private int size;
    public ArrayList<Node<E>> indices;

    /***
     * Creates an empty doubly linked list
     */
    public IDLList(){
        head = null;
        tail = null;
        size = 0;
        indices = new ArrayList<Node<E>>();
    }

    /***
     * Adds a new element anywhere in the list (within bounds), head, tail and middle
     * @param index
     * @param elem
     * @return
     */
    public boolean add(int index, E elem){
        if(index < 0 || index > size){
            throw new IndexOutOfBoundsException("That index is out of bounds...index must be in the bounds of the list");
        } else if(index == 0){
            add(elem);
        } else if (index == size){
            append(elem);
        }else {
            Node<E> previous = indices.get(index-1);
            Node<E> next = indices.get(index);
            Node<E> insertNode = new Node<E>(elem, previous, next);
            previous.next = insertNode;
            next.prev = insertNode;
            indices.add(index, insertNode);
            size++;
        }
        return true;
    }

    /***
     * adds new head element, creates one if it doesn't exist
     * @param elem
     * @return
     */
    public boolean add(E elem){
        // if list is empty
        if(head == null){
            head = new Node<E>(elem);
            tail = head;
        }
        // if list has only 1 element (tail must be altered in this one)
        else if (head == tail){
            head = new Node<E>(elem, null, tail);
            tail.prev = head;
        }
        // if list has > 2 elements (previous head is replaced)
        else {
            head = new Node<E>(elem, null, head);
            head.next.prev = head;
        }

        size++;
        indices.add(0, head);
        return true;
    }

    /***
     * adds element to the end of the list, replaces tail
     * @param elem
     * @return
     */
    public boolean append(E elem) {
        if (head == null) {
            return add(elem);
        } else {
            Node<E> appendNode = new Node<E>(elem);
            tail.next = appendNode;
            appendNode.prev = tail;
            appendNode.next = null;
            tail = appendNode;
            indices.add(appendNode);
            size++;
        }
        return true;
    }

    // trivial
    public E get(int index){
        return indices.get(index).data;
    }
    // trivial
    public E getHead(){
        return head.data;
    }
    // trivial
    public E getLast(){
        return tail.data;
    }
    // trivial
    public int size(){
        return size;
    }

    /***
     * removes and returns the first element of the list
     * @return
     */
    public E remove(){
        if(head == null){
            throw new IllegalStateException("This is an empty list...cannot remove ");
        } else if (head == tail){
            E temp = head.data;
            head = null;
            tail = null;
            indices.remove(0);
            size--;
            return temp;
        } else{
            E temp = head.data;
            head = head.next;
            head.prev = null;
            indices.remove(0);
            size--;
            return temp;
        }
    }

    /***
     * Removes the last element in the list - reassigns the head and tails
     * Throws exception in empty list
     * @return
     */
    public E removeLast(){
        if (head == null){
            throw new IllegalStateException("The list is empty");
        } else if (head == tail){
            E temp = tail.data;
            head = null;
            tail = null;
            indices.remove(0);
            size--;
            return temp;
        } else {
            E temp = tail.data;
            tail = tail.prev;
            tail.next = null;
            size--;
            indices.remove(indices.size() - 1);
            return temp;
        }
    }

    /***
     * removes the term at index; checks for invalid values
     * and adjusts head, tail
     * @param index
     * @return
     */
    public E removeAt(int index){
        if (index < 0 || index > size){
            throw new IllegalStateException("Index can only be between 0 and " + size);
        } else if (index == 0){
            return remove();
        } else if (index == size-1){
            return removeLast();
        } else {
            E temp = indices.get(index).data;
            Node<E> previous = indices.get(index-1);
            Node<E> next = indices.get(index+1);
            previous.next = next;
            next.prev = previous;
            indices.remove(index);
            size--;
            return temp;
        }
    }

    /***
     * if element exists in the list, remove first instance of it
     * @param elem
     * @return
     */
    public boolean remove(E elem){
        // if list is empty, return false
        if(head == null){
            return false;
        }
        // if the element is the head, remove first element
        if(elem == head.data){
            remove();
            return true;
        }

        // iterate through the linked list
        // if you encounter elem, decouple it from the other nodes and stop searching
        // else, return false because elem is not in the list
        Node<E> current = head;
        int index = 0;
        while (current != null){
            if(current.data == elem){
                current.prev.next = current.next;
                current.next.prev = current.prev;
                indices.remove(index);
                size--;
                return true;
            }
            current = current.next;
            index++;
        }
        return false;

    }

    /***
     * converts this list to printable String
     * @return
     */
    public String toString(){
        String returnString = "[";
        Node<E> current = head;
        while(current.next != null) {
            returnString = returnString.concat(current.data.toString() + ", ");
            current = current.next;
        }
        returnString = returnString.concat(current.data.toString() + "]");
        return returnString;
    }

    public static void main(String[] args) {
        /*DoublyLinkedList.IDLList<Integer> a = new DoublyLinkedList.IDLList<Integer>();
        a.append(3);
        a.append(2);
        a.append(4);
        a.add(3, 6);
        System.out.println(a);
        System.out.println(a.remove(2));
        System.out.println(a);*/
    }

}
