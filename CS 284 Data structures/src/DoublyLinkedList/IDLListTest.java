package DoublyLinkedList;

import static org.junit.Assert.*;
import org.junit.Test;
import DoublyLinkedList.IDLList;


public class IDLListTest {
    @Test
    public void testConstructor() {
        IDLList<Integer> idll = new IDLList<>();
        assertEquals(0, idll.size());
    }

    @Test
    public void testAddHead(){
        IDLList<Integer> idll = new IDLList<>();
        idll.add(1);
        idll.add(2);
        idll.add(3);
        idll.add(4);
        assertTrue(idll.size() == 4);
        assertTrue(idll.get(0) == 4);
        assertFalse(idll.get(1) == 2);
    }

    @Test
    public void testAddIndex(){
        IDLList<Integer> idll = new IDLList<>();
        idll.add(0, 1);
        idll.add(1, 2);
        idll.add(2, 3);
        idll.add(1, 4);
        assertTrue(idll.size() == 4);
        assertTrue(idll.get(0) == 1);
        assertTrue(idll.get(1) == 4);
        assertTrue(idll.get(2) == 2);
        assertTrue(idll.get(3) == 3);
        System.out.println(idll.indices.toString());
    }

    @Test
    public void testAppend(){
        IDLList<Integer> idll = new IDLList<>();
        idll.append(1);
        idll.append(2);
        idll.append(4);
        assertTrue(idll.size() == 3);
        assertTrue(idll.get(0) == 1);
        assertTrue(idll.get(1) == 2);
    }

    // I am not testing the getters and size() because that are beyond trivial

    @Test
    public void testRemove(){
        IDLList<Integer> idll = new IDLList<>();
        idll.append(1);
        idll.append(2);
        idll.append(4);
        idll.append(5);
        idll.append(5);
        int a = idll.remove();
        assertTrue(idll.size() == 4);
        assertTrue(idll.get(0) == 2);
        assertTrue(a == 1);

    }

    @Test
    public void testRemoveLast(){
        IDLList<Integer> idll = new IDLList<>();
        idll.append(1);
        idll.append(2);
        idll.append(4);
        idll.append(5);
        idll.append(5);
        int a = idll.removeLast();
        assertTrue(idll.size() == 4);
        assertTrue(idll.get(0) == 1);
        assertTrue(a == 5);
    }

    @Test
    public void testRemoveAt(){
        IDLList<Integer> idll = new IDLList<>();
        idll.append(1);
        idll.append(2);
        idll.append(4);
        idll.append(5);
        idll.append(5);
        int a = idll.removeAt(2);
        assertTrue(idll.size() == 4);
        assertTrue(idll.get(0) == 1);
        assertTrue(idll.get(2) == 5);
        assertTrue(a == 4);
    }

    @Test
    public void testRemoveElem(){
        IDLList<Integer> idll = new IDLList<>();
        idll.append(1);
        idll.append(2);
        idll.append(5);
        idll.append(4);
        idll.append(5);

        idll.remove(5);
        assertTrue(idll.size() == 4);
        assertTrue(idll.get(0) == 1);
        assertTrue(idll.get(2) == 4);
        assertTrue(idll.get(3) == 5);
    }

    @Test
    public void testToString(){
        IDLList<Integer> idll = new IDLList<>();
        idll.append(1);
        idll.append(2);
        idll.append(5);
        idll.append(4);
        idll.append(5);
        System.out.println(idll.toString());
        assertEquals(idll.toString(), "[1, 2, 5, 4, 5]");
    }
}