-- Create Event
CREATE TABLE umami.website_event
(
    website_id UUID,
    session_id UUID,
    visit_id UUID,
    event_id UUID,
    --sessions
    ip LowCardinality(String),
    hostname LowCardinality(String),
    browser LowCardinality(String),
    os LowCardinality(String),
    device LowCardinality(String),
    screen LowCardinality(String),
    language LowCardinality(String),
    country LowCardinality(String),
    subdivision1 LowCardinality(String),
    subdivision2 LowCardinality(String),
    city String,
    --pageviews
    url_path String,
    url_query String,
    referrer_path String,
    referrer_query String,
    referrer_domain String,
    page_title String,
    --events
    event_type UInt32,
    event_name String,
    created_at DateTime('UTC'),
    job_id Nullable(UUID)
)
    engine = MergeTree
        ORDER BY (website_id, session_id, created_at)
        SETTINGS index_granularity = 8192;

CREATE TABLE umami.website_event_queue (
    website_id UUID,
    session_id UUID,
    visit_id UUID,
    event_id UUID,
    --sessions
    ip LowCardinality(String),
    hostname LowCardinality(String),
    browser LowCardinality(String),
    os LowCardinality(String),
    device LowCardinality(String),
    screen LowCardinality(String),
    language LowCardinality(String),
    country LowCardinality(String),
    subdivision1 LowCardinality(String),
    subdivision2 LowCardinality(String),
    city String,
    --pageviews
    url_path String,
    url_query String,
    referrer_path String,
    referrer_query String,
    referrer_domain String,
    page_title String,
    --events
    event_type UInt32,
    event_name String,
    created_at DateTime('UTC'),
    job_id Nullable(UUID),
    --virtual columns
    _error String,
    _raw_message String
)
ENGINE = Kafka
SETTINGS kafka_broker_list = 'localhost:9092', -- input broker list
       kafka_topic_list = 'event',
       kafka_group_name = 'event_consumer_group',
       kafka_format = 'JSONEachRow',
       kafka_max_block_size = 1048576,
       kafka_handle_error_mode = 'stream';

CREATE MATERIALIZED VIEW umami.website_event_queue_mv TO umami.website_event AS
SELECT website_id,
    session_id,
    visit_id,
    event_id,
    ip,
    hostname,
    browser,
    os,
    device,
    screen,
    language,
    country,
    subdivision1,
    subdivision2,
    city,
    url_path,
    url_query,
    referrer_path,
    referrer_query,
    referrer_domain,
    page_title,
    event_type,
    event_name,
    created_at,
    job_id
FROM umami.website_event_queue;

CREATE MATERIALIZED VIEW umami.website_event_errors_mv
(
    error String,
    raw String
)
ENGINE = MergeTree
ORDER BY (error, raw)
SETTINGS index_granularity = 8192 AS
SELECT _error AS error,
    _raw_message AS raw
FROM umami.website_event_queue
WHERE length(_error) > 0;

CREATE TABLE umami.event_data
(
    website_id UUID,
    session_id UUID,
    event_id UUID,
    url_path String,
    event_name String,
    data_key String,
    string_value Nullable(String),
    number_value Nullable(Decimal64(4)),
    date_value Nullable(DateTime('UTC')),
    data_type UInt32,
    created_at DateTime('UTC'),
    job_id Nullable(UUID)
)
    engine = MergeTree
        ORDER BY (website_id, event_id, data_key, created_at)
        SETTINGS index_granularity = 8192;

CREATE TABLE umami.event_data_queue (
    website_id UUID,
    session_id UUID,
    event_id UUID,
    url_path String,
    event_name String,
    data_key String,
    string_value Nullable(String),
    number_value Nullable(Decimal64(4)), --922337203685477.5625
    date_value Nullable(DateTime('UTC')),
    data_type UInt32,
    created_at DateTime('UTC'),
    job_id Nullable(UUID),
    --virtual columns
    _error String,
    _raw_message String
)
ENGINE = Kafka
SETTINGS kafka_broker_list = 'localhost:9092', -- input broker list
       kafka_topic_list = 'event_data',
       kafka_group_name = 'event_data_consumer_group',
       kafka_format = 'JSONEachRow',
       kafka_max_block_size = 1048576,
       kafka_handle_error_mode = 'stream';

CREATE MATERIALIZED VIEW umami.event_data_queue_mv TO umami.event_data AS
SELECT website_id,
    session_id,
    event_id,
    url_path,
    event_name,
    data_key,
    string_value,
    number_value,
    date_value,
    data_type,
    created_at,
    job_id
FROM umami.event_data_queue;

CREATE MATERIALIZED VIEW umami.event_data_errors_mv
(
    error String,
    raw String
)
ENGINE = MergeTree
ORDER BY (error, raw)
SETTINGS index_granularity = 8192 AS
SELECT _error AS error,
    _raw_message AS raw
FROM umami.event_data_queue
WHERE length(_error) > 0;

CREATE TABLE umami.session_data
(
    website_id UUID,
    session_id UUID,
    data_key String,
    string_value Nullable(String),
    number_value Nullable(Decimal64(4)),
    date_value Nullable(DateTime('UTC')),
    data_type UInt32,
    created_at DateTime('UTC'),
    job_id Nullable(UUID)
)
    engine = MergeTree
        ORDER BY (website_id, session_id, data_key, created_at)
        SETTINGS index_granularity = 8192;

CREATE TABLE umami.session_data_queue (
    website_id UUID,
    session_id UUID,
    data_key UUID,
    string_value Nullable(String),
    number_value Nullable(Decimal64(4)),
    date_value Nullable(DateTime('UTC')),
    data_type UInt32,
    created_at DateTime('UTC'),
    job_id Nullable(UUID),
    --virtual columns
    _error String,
    _raw_message String
)
ENGINE = Kafka
SETTINGS kafka_broker_list = 'localhost:9092', -- input broker list
       kafka_topic_list = 'session_data',
       kafka_group_name = 'session_data_consumer_group',
       kafka_format = 'JSONEachRow',
       kafka_max_block_size = 1048576,
       kafka_handle_error_mode = 'stream';

CREATE MATERIALIZED VIEW umami.session_data_queue_mv TO umami.event_data AS
SELECT website_id,
    session_id,
    data_key,
    string_value,
    number_value,
    date_value,
    data_type,
    created_at,
    job_id
FROM umami.session_data_queue;

CREATE MATERIALIZED VIEW umami.session_data_errors_mv
(
    error String,
    raw String
)
ENGINE = MergeTree
ORDER BY (error, raw)
SETTINGS index_granularity = 8192 AS
SELECT _error AS error,
    _raw_message AS raw
FROM umami.session_data_queue
WHERE length(_error) > 0;

