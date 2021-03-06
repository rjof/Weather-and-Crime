#This file will finish any formatting for the website by adding unique ids and creating placeholder values for variables that are missing.

import pandas as pd
df = pd.read_csv('prediction_robbery_count.csv')
df_assault = pd.read_csv('prediction_assault_count.csv')
df_shooting = pd.read_csv('prediction_shooting_count.csv')
df_assault_noweather = pd.read_csv('prediction_noweather_assault_count.csv')
df_shooting_noweather = pd.read_csv('prediction_noweather_shooting_count.csv')
df_robbery_noweather = pd.read_csv('prediction_noweather_robbery_count.csv')

df_accuracy = pd.read_csv('validation_accuracy.csv')

df['dt'] = pd.to_datetime(df['dt'])
df['id'] = df['census_tra'].astype(str)+[dt.strftime('%Y%m%d') for dt in df['dt']]+df['hournumber'].astype(str)
df['ViolentCrime -E'] =df_shooting_noweather['V1'].values.round(decimals=3)
#df['ViolentCrime -S.E.'] = 0
df['Assault -E'] = df_assault_noweather['V1'].values.round(decimals=3)
#df['Assault -S.E.'] = 0
#df['PropertyCrime -E'] = 0
#df['PropertyCrime -S.E.'] = 0
df['Robbery -E'] = df_robbery_noweather['V1'].round(decimals=3)
#df['Robbery -S.E.'] = 0
#df['AllCrimes -E'] = 0
#df['AllCrimes -S.E.'] = 0
df['ViolentCrime|Weather -E'] = df_shooting['V1'].values.round(decimals=3)
#df['ViolentCrime|Weather -S.E.'] = 0
df['Assault|Weather -E'] = df_assault['V1'].values.round(decimals=3)
#df['Assault|Weather -S.E.'] = 0
#df['PropertyCrime|Weather -E'] = 0
#df['PropertyCrime|Weather -S.E.'] = 0
df['Robbery|Weather -E'] = df['prediction'].round(decimals=3)
df = df.drop(['prediction','predictionBinary'],1)

df = pd.merge(df, df_accuracy, on = ['hournumber'])

df['ViolentCrime -S.E.'] = df['ViolentCrime_Accuracy_Rate']
df['Assault -S.E.'] = df['Assault_Accuracy_Rate']
df['Robbery -S.E.'] = df['Robbery_Accuracy_Rate']
import datetime
currentTime = datetime.datetime.now()


cols = ['id','census_tra','dt','hournumber','ViolentCrime -E','Assault -E','Robbery -E','ViolentCrime|Weather -E','Assault|Weather -E','Robbery|Weather -E']
df = df[cols]
df = df.sort(['dt', 'census_tra'], ascending=[1,1])
df.to_csv('Crime Prediction CSV MOCK - revised.csv',index=False)

##Prepare first 24 hrs of prediction data of tomorrow for the use of validation_Jiajun
#Update the 24hrs of prediction for tomorrow only after 23:00:00

#if(currentTime.hour >= 18 and currentTime.hour < 20):
onedayDelta = datetime.timedelta(days = 1)
dateTmr = str(currentTime.date() + onedayDelta)
output_cols = ['census_tra', 'dt', 'hournumber', 'ViolentCrime -E', 'Assault -E', 'Robbery -E']
df_output = df[output_cols]
df_output['date'] = [str(dt.date())for dt in df_output['dt']]  
df_output = df_output[df_output['date'] == dateTmr]
df_output['date'] = [str(dt.date())for dt in df_output['dt']]  
df_output.to_csv('prediction_daily_' + dateTmr + '.csv', index=False)

