public class ETLPipeline{
    public static void manin(string[] args){
        sparkSession spark = sparkSession.builder()
                        .appName("Java Spark S3 ETL")
                        .config("spark.master", "local")
                        .getOrCreate();

        // Read large dataset (e.g., transaction data) from a local file
        Dataset<Row> transactions = spark.read().option("header", "true").csv("transactions.csv");
        //Dataset<Row> fraudTransactions = spark.read().option("header", "true").csv("s3a://my-bucket/credit_card_transactions.csv");

        // Simple transformation - filter transactions where amount > 100
        Dataset<Row> filtered = transactions.filter(transactions.col("amount").gt(100));

        // Write the result to AWS S3 bucket
        filtered.write().format("parquet").save("s3a://my-bucket/filtered-transactions/");

        // Initialize AWS SDK for S3 client (provide your AWS credentials)
        BasicAWSCredentials awsCredentials = new BasicAWSCredentials("yourAccessKey", "yourSecretKey");

        AmazonS3 s3Client = AmazonS3ClientBuilder.standard()
                .withRegion("us-west-2")
                .withCredentials(new AWSStaticCredentialsProvider(awsCredentials))
                .build();

        // You can further interact with AWS S3 using this s3Client
    }
}