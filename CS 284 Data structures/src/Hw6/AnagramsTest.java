package Hw6;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Map;

import static org.junit.Assert.assertEquals;

class AnagramsTest {

    public static void main(String[] args){
        test1();
    }

    static void test1() {
        Anagrams a = new Anagrams();
        try {
            a.processFile("C:\\Users\\sidiy\\Documents\\Projects\\CS284\\src\\Hw6\\words_alpha.txt");
        } catch (IOException e1) {
            e1.printStackTrace();
        }
        ArrayList<Map.Entry<Long, ArrayList<String>>> maxEntries = a.getMaxEntries();
        int length = maxEntries.get(0).getValue().size();
        long key = maxEntries.get(0).getKey();
        assertEquals(key, 236204078);
        assertEquals(length, 15);
    }

}