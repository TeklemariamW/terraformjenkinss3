
from pyspark.sql import SparkSession

# Initialize Spark Session
spark = SparkSession.builder \
    .appName("Create a datafrom") \
    .getOrCreate()

data = [("Alice", 25),("Bob", 18), ("Cathy", 65)]
columns = ["Name", "Age"]

df = spark.createDataFrame(data, columns)
# Or load data from aws s3 into DataFram
# df = spark.read.csv("s3://my-bucket/file-name.csv", header=True, inferSchema=True)
df_tranformed = df.filter(df['age'] > 25)

# Write back to S3
# df_transformed.write.csv("s3://my-bucket/transformed-data.csv")

df.show()
