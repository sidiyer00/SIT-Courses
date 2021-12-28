from bank import Bank

def main():
    bank = Bank("bank.txt")
    print("Welcome to Bank of Stevens...where Innovation Matters\n")
    while bank.getWorkingCustomer() == None:
        new_or_naw = input("Login (L) or Create new Account (N): ")
        if new_or_naw == "L":
            un = input("Username: ")
            pw = int(input("PIN:" ))
            if bank.authenticateUser(un, pw):
                bank.setWorkingCustomer(un, pw)
            else:
                print("Incorrect login")
        elif new_or_naw == "N":
            un = input("Username: ")
            phone = input("Phone number: ")
            email = input("Email: ")
            age = int(input("Age: "))
            overdraft = input("Overdraft protocol (standard or decline): ")
            print("New user added!")
            bank.addCustomer(un, overdraft, phone, email, age) 
        else:
            print("Enter L or N...")
    
    print("For list of functions, type: functions")
    while True:
        inp = input()
        inp = inp.split(" ")
        if inp[0] == "exit":
            bank.save() ##
            break
        elif inp[0] == "functions":
            print()
            listFunctions()
            print()
        elif inp[0] == "removecustomer":
            print()
            bank.removeCustomer()
            print()
        elif inp[0] == "addaccount":
            print()
            bank.addAccount(inp[1])
            print("Account added\n")
        elif inp[0] == "removeaccount":
            print()
            bank.removeAccount(inp[1])
            print("Account removed\n")
            break
        elif inp[0] == "summary":
            print()
            print(bank.customerSummary())
            print()
        elif inp[0] == "interest":
            print(bank.computeInterest())
            print()
        elif inp[0] == "deposit":
            bank.deposit(float(inp[2]), inp[1])
            print()
        elif inp[0] == "withdraw":
            bank.withdraw(float(inp[2]), inp[1])
            print()
        else:
            print("That functionality has not been built yet")
            print()


def listFunctions():
    print("Add account (Checking, Relations, Restricted, Savings): addaccount [account type]")
    print("Remove account: removeaccount [account type]")
    print("Customer Summary: summary")
    print("Compute Interest: interest")
    print("Deposit: deposit [account type] [amount]")
    print("Withdraw: withdraw [account type] [amount]")
    print("Remove customer profile: removecustomer")
    print("Exit: exit")

if __name__ == "__main__":
    main()