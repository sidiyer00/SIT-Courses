"""
Title:
- 2020 Capstone Project

Author
- Siddharth Iyer

Collaborators:
- None

Date:
- 2020 May 17

Filename:
- bank.py

Description:
- this file combines all the customers and accounts into a Bank
"""



import random
from customer import Customer
import pickle as picklerick

class Bank:
    def __init__(self, fileName = None):
        self.customers = {}
        self.filename = fileName
        if fileName != None:
            try:
                fileObj = open(fileName, 'rb')
            except Exception:
                fileObj = open(fileName, 'wb')
            while True:
                try:
                    cust = picklerick.load(fileObj)
                    self.add(cust)
                except Exception:
                    fileObj.close()
                    break
        self.working_customer = None
    
    def add(self, customer):
        self.customers[hash((customer.name, customer.pin))] = customer

    def authenticateUser(self, name, pin):
        if hash((name, pin)) in self.customers:
            return True
        else:
            return False

    def addCustomer(self, name, overdraft, phone, email, age):
        pin = random.randint(1000,9999)
        a = Customer(name, pin, age, phone, email, overdraft)
        self.customers[hash((name, pin))] = a
        self.working_customer = a
        print("Your new PIN is " + str(pin) + '\n')

    def removeCustomer(self):
        del self.working_customer
        self.save()


    def setWorkingCustomer(self, name, pin):
        self.working_customer = self.customers[hash((name, pin))]
    
    def getWorkingCustomer(self):
        return self.working_customer


    def addAccount(self, type):
        self.working_customer.addAccount(type)

    def removeAccount(self,type):
        self.working_customer.removeAccount(type)

    
    def deposit(self, amount, accounttype):
        self.working_customer.deposit(amount, accounttype)
    
    def withdraw(self, amount, accounttype):
        self.working_customer.withdraw(amount, accounttype)

   
    def computeInterest(self):
        return self.working_customer.computeInterest()

    def chargeMonthlyFee(self):
        for cust in self.customers.values():
            if cust.getAge() >= 24:
                cust.chargeMonthlyFee()

    def save(self, filepath = "bank.txt"):
        fileObj =  open(filepath, 'wb')
        for cust in self.customers.values():
            picklerick.dump(cust, fileObj)
        fileObj.close()

    def customerSummary(self):
        return str(self.working_customer)



    