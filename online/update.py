import time, datetime
import requests
import csv
from io import StringIO
import pandas as pd

def watch_for_updates():
    """
    Waits until 6pm every day and updates the 
    data in the server.
    """
    pass

def update():
    """
    Updates the data in the server.
    """
    # get data from the server
    # repo 
    # https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series
    
    US_confirmed = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv"
    US_deaths = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
    global_confirmed = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv"
    global_deaths = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"
    #global_recovered = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv"   
   
    r = requests.get(url = US_confirmed)
    csv_string = r.content.decode('utf-8')
    df = pd.read_csv(StringIO(csv_string))

    # change data into the correct json form
    renamed_filters = ['uid', 'fips', 'combined_key', 'country', 'state', 'county', 'latitude', 'longitude']
    filtered_df = filter_df(df)

    filtered_df.to_json('data/timeseries.json', orient='records')

    # save the data to the file

def filter_df(df):
    filters = ['UID', 'FIPS', 'Combined_Key', 'Country_Region', 'Province_State', 'Admin2', 'Lat', 'Long_']
    confirmed_cases = 'confirmed_cases'
    try:
        current_date_raw = datetime.datetime.now()
        day_before_raw = current_date_raw - datetime.timedelta(days = 1) 
    
        current_date = current_date_raw.strftime("%-m/%-d/%y")
        day_before = day_before_raw.strftime("%-m/%-d/%y")

        filters_with_current = list(filters)
        filters_with_current.append(day_before)
        filters_with_current.append(current_date)
        slice_df = df[filters_with_current]
        filtered_df = pd.DataFrame(slice_df)

        filtered_df['daily_change'] = filtered_df[current_date] - filtered_df[day_before]  
        filtered_df.rename(columns={current_date : confirmed_cases}, inplace = True)


    except KeyError:
        yesterday = current_date_raw - datetime.timedelta(days = 1) 
        two_days_ago = current_date_raw - datetime.timedelta(days = 2) 

        yesterday = yesterday.strftime("%-m/%-d/%y")
        two_days_ago = two_days_ago.strftime("%-m/%-d/%y")

        filters_with_yesterday = list(filters)
        filters_with_yesterday.append(two_days_ago)
        filters_with_yesterday.append(yesterday)
        slice_df = df[filters_with_yesterday]
        filtered_df = pd.DataFrame(slice_df)
        
        filtered_df['daily_change'] = filtered_df[yesterday] - filtered_df[two_days_ago]  
        filtered_df.rename(columns={yesterday : confirmed_cases}, inplace = True)

    rename = {  "UID" : "uid",
                "FIPS": "fips",
                "Combined_Key": "combined_key",
                "Country_Region":  "country",
                "Province_State": "state",
                "Admin2": "county",
                "Lat": "latitude",
                "Long_": "longitude",
                "daily_change": "daily_change_cases"
             }

    filtered_df['deaths'] = 0
    filtered_df['daily_change_deaths'] = 0
    filtered_df['population'] = 0
    filtered_df.rename(columns=rename, inplace=True)
    return filtered_df


    # [{"UID":16,"FIPS":60.0,"Combined_Key":"American Samoa, US","Country_Region":"US","Province_State":"American Samoa","Admin2":null,"Lat":-14.271,"Long_":-170.132,"4\/7\/20":0,"confirmed_cases":0,"daily_change":0},
    # Json format we need
    # [
    #   { 
    #     "uid" : 0,
    #     "fips" : 0.0,
    #     "combined_key" : "",
    #     "country": "",
    #     "state": "",
    #     "county" : "",
    #     "latitude": 0.0,
    #     "longitude": 0.0,
    #     "confirmed_cases" : 0,
    #     "deaths" : 0,
    #     "daily_change_cases" : 0,
    #     "daily_change_deaths" : 0,
    #     "population" : 0
    #   }
    # ]

if __name__ == '__main__':
    update()