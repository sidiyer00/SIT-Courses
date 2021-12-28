package Hw6;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class Anagrams {
	int[] primes =
			{2, 3, 5, 7, 11, 13, 17, 19, 23, 29,
			31, 37, 41, 43, 47, 53, 59, 61, 67,
			71, 73, 79, 83, 89, 97, 101};
	Map<Character,Integer> letterTable;
	Map<Long,ArrayList<String>> anagramTable;

	public Anagrams() {
		letterTable = new HashMap<Character, Integer>();
		buildLetterTable();
		anagramTable = new HashMap<Long,ArrayList<String>>();
	}

	public void buildLetterTable() {
		Character[] alphabet = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
		for (int i = 0; i < 26; i++) {
			letterTable.put(alphabet[i], primes[i]);
		}
		// System.out.println(letterTable);x

		// ascii: "a": 197 -> "b":122
		/* Attempt one with ASCII conversion  - didn't work
		for(int i = 197; i <= 122; i++) {
			letterTable.put((char) i, primes[i - 197]);
		}
		 */
	}

	public void addWord(String s) {
		long code = myhashcode(s);
		if(anagramTable.containsKey(code)){
			ArrayList<String> temp = anagramTable.get(code);
			temp.add(s);
			anagramTable.replace(code, temp);
		} else{
			ArrayList<String> temp = new ArrayList<String>();
			temp.add(s);
			anagramTable.put(code, temp);
		}
	}
	
	public long myhashcode(String s) {
		long prod = 1;
		for(Character letter: s.toCharArray()){
			prod = prod * letterTable.get(letter);
		}
		return prod;
	}
	
	public void processFile(String s) throws IOException {
		FileInputStream fstream = new FileInputStream(s);
		BufferedReader br = new BufferedReader(new InputStreamReader(fstream));
		String strLine;
		while ((strLine = br.readLine()) != null)   {
		  this.addWord(strLine);
		}
		br.close();
	}
	
	public ArrayList<Map.Entry<Long,ArrayList<String>>> getMaxEntries() {
		ArrayList<Map.Entry<Long,ArrayList<String>>> entries = new ArrayList<Map.Entry<Long,ArrayList<String>>>();
		int max = 0;
		for (Map.Entry<Long,ArrayList<String>> entry: anagramTable.entrySet()) {
			if (entry.getValue().size() > max) {
				entries.clear();
				entries.add(entry);
				max = entry.getValue().size();
			} else {
				if (entry.getValue().size() == max){
					entries.add(entry);
				}
			}
		}
		return entries;
	}

	public static void main(String[] args) {
		Anagrams a = new Anagrams();

		final long startTime = System.nanoTime();
		try {
			a.processFile("C:\\Users\\sidiy\\Documents\\Projects\\CS284\\src\\Hw6\\words_alpha.txt");
		} catch (IOException e1) {
			e1.printStackTrace();
		}
		ArrayList<Map.Entry<Long, ArrayList<String>>> maxEntries = a.getMaxEntries();
		int length = maxEntries.get(0).getValue().size();
		final long endTime = System.nanoTime();
		final double elapsedTime = ((double) (endTime - startTime)/1000000000);
		long key = maxEntries.get(0).getKey();
		System.out.println("Time: " + elapsedTime);
		System.out.println("List of max anagrams: "+ maxEntries.toString());
	}

}
