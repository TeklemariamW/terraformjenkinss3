from pyspark.sql import SparkSession

# Initialize SparkSession
spark = SparkSession.builder \
    .appName("S3 Data Load") \
    .config("spark.hadoop.fs.s3a.access.key", "your-access-key-id") \
    .config("spark.hadoop.fs.s3a.secret.key", "your-secret-access-key") \
    .config("spark.hadoop.fs.s3a.endpoint", "s3.us-east-1.amazonaws.com") \
    .getOrCreate()

# Create a sample DataFrame
data = [
    ("John", 28),
    ("Jane", 33),
    ("Mike", 45)
]

columns = ["Name", "Age"]
df = spark.createDataFrame(data, columns)

# Show the DataFrame
df.show()

# Define S3 path
s3_path = "s3a://unique-bankcustomerterraform-bucket-name/silver/sample_data.csv"

# Write DataFrame to S3 as CSV
df.write.mode("overwrite").csv(s3_path, header=True)

# Confirm the write operation
print(f"Data successfully uploaded to {s3_path}")
