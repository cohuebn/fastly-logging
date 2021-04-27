exports.handler = (event) => {
  event.Records.forEach(function(record) {
      var payload = Buffer.from(record.kinesis.data, 'base64').toString('utf-8');
      console.log('Decoded payload', payload);
  });
};