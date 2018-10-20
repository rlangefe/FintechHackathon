import csv
import random
import datetime

def getName():
    num = random.randint(0,675)
    return Name[num]

def getDate():
    year = random.randint(2015,2018)
    month = random.randint(1,12)
    maxDay = 30
    if month == 1 or month == 3 or month == 5 or month == 7 or month == 8 or month == 10 or month == 12:
        maxDay = 31
    elif month == 2:
        maxDay = 27
    day = random.randint(1,maxDay)
    try:
        date = datetime.datetime(year, month, day)
    except ValueError:
        print("Error in Day and Month")
        exit(1)

    return date

def getAmount():
    return random.randint(1,60)

def addPeriodData(sub):
    adv = int(12/sub[2])
    global totalNum

    for year in range(2015,2018):
        for month in range(1,12,adv):
            date = datetime.datetime(year,month,1)
            totalNum = totalNum+1
            data_writer.writerow([sub[0], date, sub[1], totalNum])

totalNum = 0

if __name__ == '__main__':
    #name array with all random company names
    Name = []
    for i in range(97,123):
        for j in range(97,123):
            Name.append(chr(i)+chr(j))

    #subscription array with company name, amount, period
    Subscrip = []
    Subscrip.append(["Netflix",10.99,12])
    Subscrip.append(["Amazon Prime",39,4])
    Subscrip.append(["Grocery Delivery",14.99,12])
    Subscrip.append(["Gym membership",21.99,12])
    Subscrip.append(["Cell Phone Plan",45,12])
    Subscrip.append(["iCloud",0.99,12])
    Subscrip.append(["ESPN",4.99,12])
    Subscrip.append(["ebay",21.95,12])



    with open("TransData.csv", mode='w') as data:
        data_writer = csv.writer(data, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)

        data_writer.writerow(["Name", "Date", "Amount", "Transaction Number"])

        numRandom = 6000
        #write random part of the data in
        for i in range(1,numRandom):
            data_writer.writerow([getName(), getDate(), getAmount(), i])
            totalNum += 1

        #write periodic part of the data in
        for i in range(0,len(Subscrip)):
            addPeriodData(Subscrip[i])

    data.close()