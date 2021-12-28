package Treap;

import Treap.Treap;

import static org.junit.Assert.*;

import java.util.HashSet;
import java.util.Random;

import org.junit.Test;


public class TreapTest <E> {
    @Test
    public void test() throws Exception {
        Treap testTreap = new Treap<Integer>();

        assertEquals(testTreap.addHelper(4, 19), true);
        assertEquals(testTreap.addHelper(2, 31), true);
        assertEquals(testTreap.addHelper(6, 70), true);
        assertEquals(testTreap.addHelper(1, 84), true);
        assertEquals(testTreap.addHelper(3, 12), true);
        assertEquals(testTreap.addHelper(5, 83), true);
        assertEquals(testTreap.addHelper(7, 26), true);
        assertEquals(testTreap.addHelper(4, 19), false);


        assertEquals(testTreap.find(3), true);
        assertEquals(testTreap.find(177013), false);

        assertEquals(testTreap.delete(13), false);
        assertEquals(testTreap.delete(3), true);


        assertEquals(testTreap.addHelper(3, 84), true);
    }
}