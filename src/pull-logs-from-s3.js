const aws = require('aws-sdk');
const crypto = require("crypto");

const s3 = process.env.S3_URL
  ? new aws.S3({ endpoint: process.env.S3_URL, s3ForcePathStyle: true, apiVersion: '2006-03-01' })
  : new aws.S3({ apiVersion: '2006-03-01' });

const cloudwatchLogs = process.env.CLOUDWATCH_LOGS_URL
  ? new aws.CloudWatchLogs({ endpoint: process.env.CLOUDWATCH_LOGS_URL, apiVersion: '2014-03-28'})
  : new aws.CloudWatchLogs({ apiVersion: '2014-03-28'});

function convertS3LogToCloudwatchLogs(logContents, bucket, key) {
  return logContents.split('\n')
    .filter(x => x !== undefined && x !== null && x !== '')
    .map(logLine => parseLogLine(logLine, bucket, key));
}

const logPattern = /<\d+>(?<timestamp>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z).*/;
const parseLogLine = (logLine, bucket, key) => {
  const parsedText = logPattern.exec(logLine);
  return {
    timestamp: Date.parse(parsedText.groups.timestamp),
    message: JSON.stringify({original: logLine, sourceBucket: bucket, sourceKey: key})
  };
}
exports.parseLogLine = parseLogLine;

exports.handler = async (event, context) => {
  // Get the bucket/key from the event so that we can fetch the actual contents from S3
  const bucket = event.Records[0].s3.bucket.name;
  const key = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, ' '));
  try {
    // Get the contents from S3 (assuming utf-8 encoding here)
    const s3Object = await s3.getObject({ Bucket: bucket, Key: key }).promise();
    const s3ObjectContents = s3Object.Body.toString('utf-8');
    // Parse log messages
    const logLines = convertS3LogToCloudwatchLogs(s3ObjectContents, bucket, key);
    // Write log messages to CloudWatch
    const logGroupName = process.env.CLOUDWATCH_LOG_GROUP;
    const logStreamName = crypto.randomBytes(16).toString("hex");
    await cloudwatchLogs.createLogStream({logGroupName, logStreamName}).promise();
    const cloudWatchRequest = {
      logEvents: logLines,
      logGroupName: logGroupName,
      logStreamName: logStreamName,
      sequenceToken: undefined // TODO - get and use the sequence token
    };
    await cloudwatchLogs.putLogEvents(cloudWatchRequest).promise();
    console.log('Successfully logged to CloudWatch');
  } catch (err) {
    const message = `Error moving logs to CloudWatch. Bucket: ${bucket}, Object: ${key}. See more error details in the logs`;
    console.log(message);
    console.error(err);
    throw new Error(message);
  }
};