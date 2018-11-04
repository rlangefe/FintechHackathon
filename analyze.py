import pandas
from sklearn.neighbors import KNeighborsClassifier
import datetime
from sklearn.externals import joblib

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


class TrainCharge(Charge):
        sub = 0

        def __init__(self, n, c, d, s):
            self.name = n
            self.cost = c
            self.date = d
            self.sub = s


#################################

def analyze(file):
    neigh = joblib.load('finalized_model.sav')

    data = pandas.read_csv(file, usecols=['AccountID','Name','Date','Amount','Transaction Number','Is Subscription or Not'])

    data['Date'] = pandas.to_datetime(data['Date'])
    data.drop(0)

    chargeList = []

    for i in range(data['Name'].count()):
        if (data.iloc[i]['Name'] != '-'):
            name = data.iloc[i]['Name']
            cost = data.iloc[i]['Amount']
            date = data.iloc[i]['Date']
            sub = data.iloc[i]['Is Subscription or Not']
            added = 0
            for x in chargeList:
                if x.check(name, date, cost):
                    added = 1
            if added != 1:
                chargeList.append(TrainCharge(name, cost, date, sub))

    X_data = []
    y_data = []
    listOfNames = [[]]
    for x in chargeList:
        listOfNames.append([x.name, round(x.cost, 2)])
        X_data.append([float(x.cost), ((x.first_date - x.last_date) / x.count).total_seconds()])
        y_data.append(float(x.sub))

    subscritpionList = []
    result = neigh.predict(X_data)
    for q in range(len(X_data)):
        if result[q] == 1.0:
            subscritpionList.append(listOfNames[q])

    print(neigh.score(X_data, y_data))
    df = pandas.DataFrame(subscritpionList, columns=['Name', 'Amount'])
    df['Amount'] = '$' + round(df['Amount'], 2).astype(str)
    df.drop(df.index[0])
    return df
