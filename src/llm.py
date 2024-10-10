from google.cloud import bigquery
from transformers import pipeline

# Initialize BigQuery Client
client = bigquery.Client()

# Query customer reviews from BigQuery
query = """
SELECT customer_id, review_text 
FROM `project_id.dataset.customer_data`
WHERE review_text IS NOT NULL
"""
reviews = client.query(query).result()

# Load pre-trained LLM sentiment analysis model
sentiment_model = pipeline("sentiment-analysis")

# Function to analyze sentiment
def analyze_sentiment(text):
    result = sentiment_model(text)
    return result[0]['label'], result[0]['score']

# Process each review and analyze sentiment
sentiment_results = []
for row in reviews:
    customer_id = row['customer_id']
    review_text = row['review_text']
    sentiment_label, sentiment_score = analyze_sentiment(review_text)
    sentiment_results.append((customer_id, sentiment_label, sentiment_score))

# Now save the results back to BigQuery
# (assuming you have a BigQuery table to save sentiment data)
sentiment_table = client.get_table('project_id.dataset.sentiment_results')
client.insert_rows(sentiment_table, sentiment_results)
#############################
############################
# Python Code for Summarization:
# Load pre-trained LLM for text summarization
summarizer = pipeline("summarization", model="gpt-2")

# Summarize a review text
summary = summarizer("This product is great, but the battery life is too short.", max_length=50, min_length=25, do_sample=False)
print("Summary:", summary)
###################################
########################################
# BigQuery ML Churn Prediction:
CREATE OR REPLACE MODEL `project_id.dataset.churn_model`
OPTIONS (model_type = 'logistic_reg') AS
SELECT 
    customer_id,
    AVG(sentiment_score) AS avg_sentiment,
    COUNT(product_id) AS purchase_count,
    SUM(spend) AS total_spend,
    CASE WHEN churned = 1 THEN 1 ELSE 0 END AS label
FROM `project_id.dataset.customer_data`
GROUP BY customer_id;
