import numpy as np
import pandas as pd
from sklearn import svm
import datetime
import time

class Charge:
    name = ''
    cost = 0
    count = 1
    first_date = datetime.datetime.now()
    last_date = datetime.datetime.now()

    def __init__(self, n, c, d):
        self.name = n
        self.cost = c
        self.date = d

    def check(self, n, d, c):
        if(self.name == n) and (self.cost == c):
            self.add(d)
            return True
        else:
            return False

    def add(self, d):
        self.last_date = d
        self.count += 1

    def print(self):
        return self.name + ',' + self.cost + ',' + self.first_date + ',' + self.last_date + ',' + self.count


class TrainCharge(Charge):
        sub = 0

        def __init__(self, n, c, d, s):
            self.name = n
            self.cost = c
            self.date = d
            self.sub = s


#################################
def main():
    data = pd.read_csv("TransData.csv")
    chargeList = []

    for i in range(6067):
        if(data.iloc[i]['Date']!='-'):
            name = data.iloc[i]['Name']
            cost = data.iloc[i]['Amount']
            date = data.iloc[i]['Date']
            sub = data.iloc[i]['Is Subscription or Not']
            added = 0
            for x in chargeList:
                if x.check(name, date, cost):
                    added = 1
            if added != 1:
                chargeList.append(TrainCharge(name, cost, time.strptime(date, '%Y-%m-%d %H:%M:%S'), sub))


    formattedData = pd.DataFrame(columns=['Name', 'Amount', 'Frequency', 'Subscription'])

    for x in chargeList:
        if (x.first_date != '-'):
            formattedData.append([x.name, x.cost, ((x.first_date - x.last_date)/x.count), x.sub])

    clf = svm.SVC()
    clf.train(formattedData[['Name', 'Amount', 'Frequency'], formattedData['Subscription']])

    chargeList = []

    for i in range(6068, 12244):
        if (data.iloc[i]['Name'] != '-'):
            name = data.iloc[i]['Name']
            cost = data.iloc[i]['Amount']
            date = data.iloc[i]['Date']
            sub = data.iloc[i]['Is Subscription Or Not']
            added = 0
            for x in chargeList:
                if x.check(name, date, cost):
                    added = 1
            if added != 1:
                chargeList.append(TrainCharge(name, cost, date, sub))

    print(clf.score(formattedData[['Name', 'Amount', 'Frequency'], formattedData['Subscription']]))


if __name__ == '__main__':
    main()