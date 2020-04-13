import time, datetime
import requests
import csv
from io import StringIO
import pandas as pd

def sleep(hour, minute):
    t = datetime.datetime.today()
    future = datetime.datetime(t.year,t.month,t.day,hour,minute)
    if t.hour >= hour:
        future += datetime.timedelta(days=1)
        time.sleep((future-t).seconds)

def watch_for_updates():
    """
    Waits until 8pm every day and updates the 
    data in the server.
    """
    while True:
        sleep(20, 30)
        update()
        time.sleep(60) 

def update():
    """
    Updates the data in the server.
    """
    # get data from the server
    # repo 
    # https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series
    
    US_confirmed = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv"
    global_confirmed = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
    US_deaths = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv"
    global_deaths = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"
    #global_recovered = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv"   
   
    US_confirmed_df = pd.read_csv(StringIO(requests.get(url = US_confirmed).content.decode('utf-8')))
    US_deaths_df = pd.read_csv(StringIO(requests.get(url = US_deaths).content.decode('utf-8')))

    # change data into the correct json form
    
    merged_df = pd.merge(filter_df(US_confirmed_df), \
            filter_df(US_deaths_df, deaths=True), \
            on=[ 'uid', 'fips', 'combined_key', 'country', 'state', 'state_abbr', 'county', 'longitude', 'latitude' ], \
            how='left')

    #filtered_df = filter_df(US_deaths_df, deaths=True)

    merged_df.to_json('data/timeseries.json', orient='records')

    # save the data to the file

def filter_df(df, deaths=False, worldwide=False):

    if worldwide == True: 
        ### For Global confirmed cases and confirmed deaths dataframes 
        return filter_df_global(df, deaths)
        
    else:
        ### For US confirmed cases and confirmed death dataframes 
        return filter_df_US(df, deaths)


def filter_df_US(df, deaths):
    filters = ['UID', 'FIPS', 'Combined_Key', 'Country_Region', 'Province_State', 'Admin2', 'Lat', 'Long_']

    if deaths == True:
        filters.append('Population')
    try:
        current_date_raw = datetime.datetime.now()
        day_before_raw = current_date_raw - datetime.timedelta(days = 1) 
        week_before_raw = current_date_raw - datetime.timedelta(days = 7) 
    
        current_date = current_date_raw.strftime("%-m/%-d/%y")
        day_before = day_before_raw.strftime("%-m/%-d/%y")
        week_before = week_before_raw.strftime("%-m/%-d/%y")

        filters_with_current = list(filters)
        filters_with_current.append(week_before)
        filters_with_current.append(day_before)
        filters_with_current.append(current_date)
        slice_df = df[filters_with_current]
        filtered_df = pd.DataFrame(slice_df)
    
        filtered_df['daily_change'] = filtered_df[current_date] - filtered_df[day_before]  
        filtered_df['weekly_change'] = filtered_df[current_date] - filtered_df[week_before]
        if deaths == True:
            filtered_df.rename(columns={current_date : 'confirmed_deaths'}, inplace = True)
        else:
            filtered_df.rename(columns={current_date : 'confirmed_cases'}, inplace = True)  
        filtered_df.drop([day_before, week_before], axis=1, inplace=True)
    

    except KeyError:
        yesterday = current_date_raw - datetime.timedelta(days = 1) 
        two_days_ago = current_date_raw - datetime.timedelta(days = 2) 
        week_before_raw = current_date_raw - datetime.timedelta(days = 8) 


        yesterday = yesterday.strftime("%-m/%-d/%y")
        two_days_ago = two_days_ago.strftime("%-m/%-d/%y")
        week_before = week_before_raw.strftime("%-m/%-d/%y")

        filters_with_yesterday = list(filters)
        filters_with_yesterday.append(week_before)
        filters_with_yesterday.append(two_days_ago)
        filters_with_yesterday.append(yesterday)
        slice_df = df[filters_with_yesterday]
        filtered_df = pd.DataFrame(slice_df)
        
        filtered_df['daily_change'] = filtered_df[yesterday] - filtered_df[two_days_ago]  
        filtered_df['weekly_change'] = filtered_df[yesterday] - filtered_df[week_before]  
        if deaths == True:
            filtered_df.rename(columns={yesterday : 'confirmed_deaths'}, inplace = True)
        else:
            filtered_df.rename(columns={yesterday : 'confirmed_cases'}, inplace = True)

        filtered_df.drop([two_days_ago, week_before], axis=1, inplace=True)

    if deaths == True:
        rename = {  "UID" : "uid",
                    "FIPS": "fips",
                    "Combined_Key": "combined_key",
                    "Country_Region":  "country",
                    "Province_State": "state",
                    "Admin2": "county",
                    "Lat": "latitude",
                    "Long_": "longitude",
                    "Population": "population",
                    "daily_change": "daily_change_deaths",
                    "weekly_change": "weekly_change_deaths"
                }
    else: 
        rename = {  "UID" : "uid",
                    "FIPS": "fips",
                    "Combined_Key": "combined_key",
                    "Country_Region":  "country",
                    "Province_State": "state",
                    "Admin2": "county",
                    "Lat": "latitude",
                    "Long_": "longitude",
                    "daily_change": "daily_change_cases",
                    "weekly_change": "weekly_change_cases"
                }
    
    filtered_df.rename(columns=rename, inplace=True)
    filtered_df['state_abbr'] = filtered_df['state'].map(lambda name: us_state_abbrev[name], na_action='ignore')
    return filtered_df


# https://gist.github.com/rogerallen/1583593
us_state_abbrev = {
    'Alabama': 'AL',
    'Alaska': 'AK',
    'American Samoa': 'AS',
    'Arizona': 'AZ',
    'Arkansas': 'AR',
    'California': 'CA',
    'Colorado': 'CO',
    'Connecticut': 'CT',
    'Delaware': 'DE',
    'District of Columbia': 'DC',
    'Florida': 'FL',
    'Georgia': 'GA',
    'Guam': 'GU',
    'Hawaii': 'HI',
    'Idaho': 'ID',
    'Illinois': 'IL',
    'Indiana': 'IN',
    'Iowa': 'IA',
    'Kansas': 'KS',
    'Kentucky': 'KY',
    'Louisiana': 'LA',
    'Maine': 'ME',
    'Maryland': 'MD',
    'Massachusetts': 'MA',
    'Michigan': 'MI',
    'Minnesota': 'MN',
    'Mississippi': 'MS',
    'Missouri': 'MO',
    'Montana': 'MT',
    'Nebraska': 'NE',
    'Nevada': 'NV',
    'New Hampshire': 'NH',
    'New Jersey': 'NJ',
    'New Mexico': 'NM',
    'New York': 'NY',
    'North Carolina': 'NC',
    'North Dakota': 'ND',
    'Northern Mariana Islands':'MP',
    'Ohio': 'OH',
    'Oklahoma': 'OK',
    'Oregon': 'OR',
    'Pennsylvania': 'PA',
    'Puerto Rico': 'PR',
    'Rhode Island': 'RI',
    'South Carolina': 'SC',
    'South Dakota': 'SD',
    'Tennessee': 'TN',
    'Texas': 'TX',
    'Utah': 'UT',
    'Vermont': 'VT',
    'Virgin Islands': 'VI',
    'Virginia': 'VA',
    'Washington': 'WA',
    'West Virginia': 'WV',
    'Wisconsin': 'WI',
    'Wyoming': 'WY', 
    'Diamond Princess': 'DP', 
    'Grand Princess': 'GP',
}

if __name__ == '__main__':
    update()