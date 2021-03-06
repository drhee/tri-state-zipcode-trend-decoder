# ZIPy!

ZIPy! provides historical and real-time ZIP code analytics on simulated user activities of real estate webapps such as Zillow and Trulia.

webapp: [www.zipy.work](http://zipy.work)

slides: [Slides](http://www.slideshare.net/DavidBRhee/zipy-all-things-zip-code-related)

demo:   [Demo](https://youtu.be/tcQ7AAlkNbM)

# What can you do with ZIPy!?

ZIPy! allows real estate agents and potential home buyers to quickly analyze simulated historical and real-time user activities on webapps
such as Zillow and Trulia. The user has the capacity to look at historical data on the state level maps which is powered by Highcharts.

![batch map demo] (images/popular.png)

Historical data can be displayed at different granularities in time, either hourly or daily.

![batch chart demo] (images/hourly.png)

ZIPy! also provides an interface to search for patterns of originating user ZIP codes and their target ZIP code.

![batch search demo] (images/user_search.png)
![batch map user demo] (images/user_result.png)

As an analytics platform, ZIPy! also provides set of APIs that Data Scientist can consume for further analysis.

![batch api demo] (images/json.png)

ZIPy! also provides real-time feed of user activities every 2 seconds.

![batch map demo] (images/real_time.png)

# Data Workflow

ZIPy! utilizes the following technology stack for its data pipeline: Kafka as a message broker, hadoop HDFS for data storage,
Spark for batch processing, Spark Streaming for real-time processing, Cassandra as a database, and flask for UI.

![batch pipeline demo] (images/pipeline.png)

# Data Ingestion

ZIPy! uses historical sales data provided by Zillow.com to randomly generate its engineered data. Custom Python scripts were written
to emulate potential user activity based on distribution of historical sales data per ZIP codes i.e. ZIP codes with higher sales records
have higher likelihood to be randomly picked during simulation. Python scripts then sends packaged message to message broker Kafka.

As a message broker, Kafka continuously absorbs messages generated by producers. For consumption, cron job periodically (hourly and daily)
executes Camus to push the messages to HDFS data storage for batch processing.

![batch map demo] (images/ingestion.png)

# Batch/Real-time Processing

After messages were pushed onto HDFS, codes written in pyspark was used to perform batch processing. At this stage, cron was used to execute
different batch processes where each batch processes were responsible for producing historical batch views per query. For example, batch_trending_zipcode_by_hour.py
performs map/reduce jobs to calculate number of user views per ZIP codes per hour and writes it to corresponding Cassandra table.

![batch map demo] (images/batch.png)

Unlike batch processing, real-time processing consumes messages directly off of Kafka for its map/reduce job. For this part, Spark streaming was
used to performs map/reduce jobs to calculate number of user views per ZIP codes per second. Subsquently, the resulting data was written to
corresponding Cassandra table.

# Database

For both batch and real-time processing, resulting data were stored on Cassandra database. The following schema was used to populate the database.

```
CREATE TABLE trending_zipcode_by_hour (house_zipcode varchar, date int, count int, PRIMARY KEY (house_zipcode, date)) WITH CLUSTERING ORDER BY (date ASC);
CREATE TABLE trending_zipcode_by_day (house_zipcode varchar, date int, count int, PRIMARY KEY (house_zipcode, date)) WITH CLUSTERING ORDER BY (date ASC);
CREATE TABLE active_user_by_hour (house_zipcode varchar, user_zipcode varchar, date int, count int, PRIMARY KEY ((user_zipcode), date, house_zipcode)) WITH CLUSTERING ORDER BY (date ASC, house_zipcode ASC);
CREATE TABLE active_user_by_day (house_zipcode varchar, user_zipcode varchar, date int, count int, PRIMARY KEY ((user_zipcode), date, house_zipcode)) WITH CLUSTERING ORDER BY (date ASC, house_zipcode ASC);
CREATE TABLE zipcode_by_seconds_streaming (place_holder varchar, house_zipcode varchar, date int, count int, PRIMARY KEY ((place_holder), date, house_zipcode)) WITH CLUSTERING ORDER BY (date DESC, house_zipcode ASC) AND default_time_to_live = 120;
```

# UI/API

The webapp was built using flask and highcharts. ZIPy! also provides an interface for data scientist to gain access to database programmatically
which returns data in JSON format. For example, /history_zipcode_daily/api/ZIPcode/ will retrieve JSON formatted historical daily data for given ZIP code.
