const {parseLogLine} = require('../src/pull-logs-from-s3');

describe('log parsing', () => {
  const testCases = [
    {
      input: '<134>2021-03-29T22:45:30Z cache-dca17776 s3logging[3812]: [29/Mar/2021:22:45:30 +0000] 0 107.190.28.219 157.52.79.76 9808 9808 360606 107.190.28.219 HTTP/1.1 GET 443 ?json GET /music/cu-cases-creep-toward-new-peak?json HTTP/1.1 200 /music/cu-cases-creep-toward-new-peak www.etmtest.com',
      expected: {
        timestamp: Date.UTC(2021, 2, 29, 22, 45, 30),
        message: '<134>2021-03-29T22:45:30Z cache-dca17776 s3logging[3812]: [29/Mar/2021:22:45:30 +0000] 0 107.190.28.219 157.52.79.76 9808 9808 360606 107.190.28.219 HTTP/1.1 GET 443 ?json GET /music/cu-cases-creep-toward-new-peak?json HTTP/1.1 200 /music/cu-cases-creep-toward-new-peak www.etmtest.com'
      }
    },
    {
      input: '<134>2021-03-29T22:46:28Z cache-dca17727 s3logging[3812]: [29/Mar/2021:22:46:28 +0000] 0 107.190.28.219 157.52.79.27 35794 35794 355474 107.190.28.219 HTTP/1.1 GET 443 ?json GET /stations?json HTTP/1.1 200 /stations www.etmtest.com',
      expected: {
        timestamp: Date.UTC(2021, 2, 29, 22, 46, 28),
        message: '<134>2021-03-29T22:46:28Z cache-dca17727 s3logging[3812]: [29/Mar/2021:22:46:28 +0000] 0 107.190.28.219 157.52.79.27 35794 35794 355474 107.190.28.219 HTTP/1.1 GET 443 ?json GET /stations?json HTTP/1.1 200 /stations www.etmtest.com'
      }
    }
  ];
  test.each(testCases)(
    "parsing: %s",
    ({input, expected}) => {
      const result = parseLogLine(input);
      expect(result).toEqual(expected);
    }
  );
});
