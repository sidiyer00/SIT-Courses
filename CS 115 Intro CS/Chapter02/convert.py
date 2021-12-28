CONVERT_C_TO_F = 9/5

def dylan_scott(:
	celsius = eval(input("What is temp in celsius? "))
	print('the temparature is', CONVERT_C_TO_F * celsius * 32, "degrees F")

	fahrenheit = CONVERT_C_TO_F * celsius * 32
	print('temperature is', fahrenheit, 'degree F')

