"""
File: bank.py
This module defines the Bank class.
"""
import pickle
import random

from customer import Customer

class Bank:
    """This class represents a bank as a collection of savnings accounts.
    An optional file name is also associated
    with the bank, to allow transfer of accounts to and
    from permanent file storage."""

    # The state of the bank is a dictionary of accounts and
    # a file name.  If the file name is None, a file name
    # for the bank has not yet been established.

    def __init__(self, fileName = None):
        """Creates a new dictionary to hold the customers.
        If a file name is provided, loads the accounts from
        a file of pickled accounts."""
        # customers format - {(name, pin): Customer(...)}
        # self.customers = []
        self.accounts = {}

        self.fileName = fileName
        # if fileName != None:
        #     fileObj = open(fileName, 'rb')
        #     while True:
        #         try:
        #             account = pickle.load(fileObj)
        #             self.add(account)
        #         except Exception:
        #             fileObj.close()
        #             break
    
    def addCustomer(self, name):
        """Adds customer to bank records and customer list; 
        key as tuple with name and pin, value as Customer object

        Arguments:
            name {String} -- name of customer
            pin {int} -- 4 digit randomly generated PIN 
        """
        pin = random.randint(1000,9999)
        a = Customer(name, pin)
        self.accounts[name] = a

    def removeCustomer(self, name, pin):
        self.accounts.pop(name)

    def getCustomers(self):
        output = ""
        for cust in self.accounts.values():
            output += str(cust)
        return output

    def save(self, fileName = None):
        """Saves pickled accounts to a file.  The parameter
        allows the user to change file names."""
        if fileName != None:
            self.fileName = fileName
        elif self.fileName == None:
            return
        fileObj = open(self.fileName, 'wb')
        for account in self.accounts.values():
            pickle.dump(account, fileObj)
        fileObj.close()

    def deposit(self, name, amount, accounttype):
        self.accounts.get(name).deposit(amount, accounttype)
    def withdraw(self, name, amount, accounttype):
        self.accounts.get(name).withdraw(amount, accounttype)
    def addAccount(self, name, accounttype):
        self.accounts.get(name).addAccount(accounttype)


def testAccount():
    bank = Bank()
    # bank.addCustomer("Tom")
    # bank.addCustomer("Jerry")

    # bank.addAccount("Tom", "Checking")
    # bank.deposit("Tom", 345.74, "Checking")

    # bank.addAccount("Jerry", "Savings")
    # bank.deposit("Jerry", 101.9, "Savings")

    # bank.addAccount("Tom", "Savings")
    # bank.deposit("Tom", 200, "Savings")

    # bank.save("test.txt")
    ########### start implementing different accounts
    print(bank.getCustomers())


def main(number = 10, fileName = None):
    """Creates and prints a bank, either from
    the optional file name argument or from the optional
    number."""
    testAccount()

if __name__ == "__main__":
    main()

   
