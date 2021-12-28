import random
from customer import Customer
import pickle as picklerick

class Bank:

    CHECKING_MONTHLY_FEE = 12
    RELATIONSHIP_MONTHLY_FEE = 25
    SAFE_MONTHLY_FEE = 4.95
    SAVINGS_MONTHLY_FEE = 8

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
        print("Your new PIN is " + str(pin))

    def removeCustomer(self):
        del self.working_customer


    def setWorkingCustomer(self, name, pin):
        self.working_customer = self.customers[hash((name, pin))]
    
    def getWorkingCustomer(self):
        return self.working_customer


    def addAccount(self, type):
        if self.working_customer == None:
            print("You have not selected a customer")
        self.working_customer.addAccount(type)

    def removeAccount(self,type):
        if self.working_customer == None:
            print("You have not selected a customer")
        self.working_customer.removeAccount(type)

    
    def deposit(self, amount, accounttype):
        self.working_customer.deposit(amount, accounttype)
    
    def withdraw(self, amount, accounttype):
        self.working_customer.withdraw(amount, accounttype)

   
    def computeInterest(self):
        if self.working_customer == None:
            print("You have not selected a customer")
        return self.working_customer.computeInterest()
    
    def monthlyFee(self):
        for cust in self.customers.values():
            if cust.age >= 24:
                withdraw()

    def save(self, filepath = "bank.txt"):
        fileObj =  open(filepath, 'wb')
        for cust in self.customers.values():
            picklerick.dump(cust, fileObj)
        fileObj.close()

    def customerSummary(self):
        if self.working_customer == None:
            print("You have not selected a customer")
        return str(self.working_customer)


    