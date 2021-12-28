"""
Title:
- 2020 Capstone Project

Author
- Siddharth Iyer

Collaborators:
- Noneq

Date:
- 2020 May 17

Filename:
- main.py

Description:
- this file allows the user to interact with the bank
- the user enters terminal-like commands
"""

from bank import Bank

def main():
    """main.py - user interacts with the Bank
    """
    # create a bank using bank.txt stored data
    bank = Bank("bank.txt")
    print("Welcome to Bank of Stevens...where Innovation Matters\n")

    # login / create new user functionality - need a Username and PIN to login
    # sets current user in Bank
    while bank.getWorkingCustomer() == None:
        new_or_naw = input("Login (L) or Create new profile (N): ")
        if new_or_naw == "L":
            un = input("Username: ")
            pw = int(input("PIN:" ))
            if bank.authenticateUser(un, pw):
                bank.setWorkingCustomer(un, pw)
            else:
                print("Incorrect login")
        elif new_or_naw == "N":
            un = input("Username: ")
            age = int(input("Age: "))
            phone = input("Phone number: ")
            email = input("Email: ")
            overdraft = input("Overdraft protocol (standard or decline): ")
            print("New user added!")
            bank.addCustomer(un, overdraft, phone, email, age) 
        else:
            print("Enter L or N...")
    
    # listFunctions prints list of commands user can execute 
    print("For list of functions, type: functions")
    listFunctions()

    # ################### TEST CASES  ########################

    # # prints summary of customer's account
    # print(bank.customerSummary())
    # # adds Checking and Savings Account 
    # bank.addAccount("Checking")
    # bank.addAccount("Savings")
    # print(bank.customerSummary())

    # # despoits $500 into checking & $300 into savings
    # bank.deposit(500, "Checking")
    # bank.deposit(300, "Savings")
    # print(bank.customerSummary())
    # # withdraws $600 from checking, $300 from Checking goes through
    # # $200 from Savings also goes through 
    #  # there isn't enough so transactions are declined
    # bank.withdraw(600, "Checking")  
    # bank.withdraw(300, "Checking")
    # bank.withdraw(200, "Savings")
    # print(bank.customerSummary())

    # # removes checking account
    # bank.addAccount("Restricted")  # tries to add multiple types of checking accnts (error)
    # bank.removeAccount("Checking")
    # print(bank.customerSummary())

    # # computes interest at end of year (rate taken from BoA's rates <- simple Google search)
    # print(bank.computeInterest())
    
    # # try other types of checking accounts (Relations, Restricted)
    # bank.addAccount("Restricted")
    # print(bank.customerSummary())

    # # add $4000 to new checking account (Restricted)
    # bank.deposit(4000, "Checking")
    # bank.withdraw(200, "Checking")
    # bank.withdraw(200, "Checking")
    # bank.withdraw(200, "Checking")
    # bank.withdraw(200, "Checking")  # withdraw more than 3 times \
    #                                 # this should handle an error gracefully
    # print(bank.customerSummary())

    # bank.removeAccount("Checking")
    # bank.addAccount("Relations")
    # bank.deposit(4000, "Checking")
    # bank.deposit(300, "Savings")

    # # proof of concept for monthly fee 
    # for i in range(12):
    #     bank.chargeMonthlyFee()
    #     print(bank.customerSummary())
    
    # bank.save()

    ##################### END TEST CASES ########################
    #this code handles live user interaction
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
            break
        elif inp[0] == "addaccount":
            print()
            bank.addAccount(inp[1])
            print()
        elif inp[0] == "removeaccount":
            print()
            bank.removeAccount(inp[1])
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
    print("\nAdd account (Checking, Relations, Restricted, Savings): addaccount [account type]")
    print("Remove account (Checking or Savings): removeaccount [account type]")
    print("Customer Summary: summary")
    print("Compute Interest: interest")
    print("Deposit: deposit [account type] [amount]")
    print("Withdraw: withdraw [account type] [amount]")
    print("Remove customer profile: removecustomer")
    print("Exit: exit\n")

if __name__ == "__main__":
    main()