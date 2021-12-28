def main():
	print("This program convers a textual message into a sequance")
	print("of numbers representing the underlying Unicode encoding.")

	message = input ( " Please enter the message to encode : " )

	print ( " \nHere are the Unicode codes : " )

	for ch in message :
		print(ord(ch), end=" ")
	print() # blank l ine before prompt

main()